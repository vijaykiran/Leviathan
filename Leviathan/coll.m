//
//  coll.mm
//  Leviathan
//
//  Created by Steven on 10/20/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "coll.h"
#import "token.h"
#import "atom.h"

@implementation LVDefinition
@end

#define LV_COLL_CHUNK_SIZE (20)

LVColl* LVCollCreate() {
    LVColl* coll = malloc(sizeof(LVColl));
    coll->is_atom = NO;
    
    coll->children_cap = LV_COLL_CHUNK_SIZE;
    coll->children_len = 0;
    coll->children = malloc(sizeof(LVElement*) * coll->children_cap);
    
    return coll;
}

void LVCollDestroy(LVColl* coll) {
    for (int i = 0; i < coll->children_len; i++) {
        LVElement* child = coll->children[i];
        LVElementDestroy(child);
    }
    
    free(coll->children);
    LVTokenDelete(coll->open_token);
    LVTokenDelete(coll->close_token);
    free(coll);
}

void LVElementListAppend(LVColl* coll, LVElement* child) {
    if (coll->children_len == coll->children_cap) {
        coll->children_cap += LV_COLL_CHUNK_SIZE;
        coll->children = realloc(coll->children, sizeof(LVElement*) * coll->children_cap);
    }
    
    coll->children[coll->children_len] = child;
    coll->children_len++;
}



static void appendToString(LVColl* coll, bstring str) {
    bconcat(str, coll->open_token->string);
    
    for (size_t i = 0; i < coll->children_len; i++) {
        LVElement* child = coll->children[i];
        if (child->is_atom) {
            LVAtom* atom = (void*)child;
            bconcat(str, atom->token->string);
        }
        else {
            appendToString((void*)child, str);
        }
    }
    
    bconcat(str, coll->close_token->string);
}

bstring LVStringForColl(LVColl* coll) {
    bstring str = bfromcstr("");
    appendToString(coll, str);
    return str;
}

size_t LVGetElementIndexInSiblings(LVElement* child) {
    size_t len = child->parent->children_len;
    LVElement** children = child->parent->children;
    for (int i = 0; i < len; i++) {
        if (children[i] == child)
            return i;
    }
    return -1;
}

LVColl* LVFindDeepestColl(LVColl* coll, size_t offset, size_t pos, size_t* childsIndex, size_t* relativePos) {
    
    // "|"        -->   top level, index = 0
    // "|foo"     -->   top level, index = 0
    // "|(foo)"   -->   top level, index = 0
    // "(|foo)"   -->   list,      index = 0
    // "|#(foo)"  -->   top level, index = 0
    // "#|(foo)"  -->   top level, index = 0
    // "#(|foo)"  -->   list,      index = 0
    // "#(foo|)"  -->   list,      index = 1
    // "#(foo)|"  -->   top level, index = 1
    
    // "(foo| bar)"   -->   list, index = 1
    // "(foo |bar)"   -->   list, index = 2
    // "(foo b|ar)"   -->   list, index = 2
    // "(foo bar|)"   -->   list, index = 3
    
    // we know we're in this coll somewhere, but where?
    
    
    
    size_t open_tok_len = coll->open_token->string->slen;
    
    size_t coll_inner_offset = offset + open_tok_len;
    
    if (pos < coll_inner_offset) {
        *relativePos = 0;
        *childsIndex = LVGetElementIndexInSiblings((void*)coll);
        return coll->parent;
    }
    
    size_t cumulative_child_offset = 0;
    
    for (size_t i = 0; i < coll->children_len; i++) {
        LVElement* child = coll->children[i];
        
        size_t this_child_len = LVElementLength(child);
        
        if (pos < (coll_inner_offset + cumulative_child_offset + this_child_len)) {
            if (child->is_atom) {
                *relativePos = pos - (coll_inner_offset + cumulative_child_offset);
                *childsIndex = i;
                return child->parent;
            }
            else {
                return LVFindDeepestColl((void*)child, coll_inner_offset + cumulative_child_offset, pos, childsIndex, relativePos);
            }
        }
        
        cumulative_child_offset += this_child_len;
    }
    
    *relativePos = 0;
    *childsIndex = coll->children_len;
    return coll;
}

LVColl* LVCollHighestParent(LVColl* coll) {
    while (coll->parent->parent)
        coll = coll->parent;
    
    if (coll->coll_type == LVCollType_TopLevel)
        return NULL;
    else
        return coll;
}

void LVFindDefinitions(LVColl* coll, NSMutableArray* defs) {
    for (int i = 0; i < coll->children_len; i++) {
        LVColl* child = (void*)coll->children[i];
        
        if (child->is_atom)
            continue;
        
        if (child->coll_type & LVCollType_Definition) {
            LVDefinition* def = [[LVDefinition alloc] init];
            
            for (int ii = 0; ii < child->children_len; ii++) {
                LVAtom* grandchild = (void*)child->children[ii];
                
                if (!grandchild->is_atom)
                    continue;
                
                if (grandchild->atom_type & LVAtomType_DefType) {
                    def.defType = grandchild;
                    continue;
                }
                
                if (grandchild->atom_type & LVAtomType_DefName) {
                    def.defName = grandchild;
                    break;
                }
            }
            
            [defs addObject: def];
        }
        
        LVFindDefinitions(child, defs);
    }
}

void LVGetSemanticDirectChildren(LVColl* parent, size_t startingPos, LVElement** array, size_t* count) {
    *count = 0;
    for (size_t i = startingPos; i < parent->children_len; i++) {
        LVElement* child = parent->children[i];
        
        if ((!child->is_atom) || (child->is_atom && LVAtomIsSemantic((void*)child)))
            array[(*count)++] = child;
    }
}
