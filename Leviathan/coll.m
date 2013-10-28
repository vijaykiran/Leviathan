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
#import "doc.h"

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
//    LVTokenDelete(coll->open_token);
//    LVTokenDelete(coll->close_token);
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
//    bconcat(str, coll->open_token->string);
//    
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
//    
//    bconcat(str, coll->close_token->string);
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

LVAtom* LVFindAtom(LVDoc* doc, size_t pos) {
    for (int i = 0; i < doc->tokens_len; i++) {
        LVToken* tok = doc->tokens[i];
        if (pos >= tok->pos && pos <= tok->pos + tok->string->slen)
            return tok->atom;
    }
    abort();
    
    // more efficient probably, but breaks with FileEnd token :(
    
//    LVToken** iter = doc->tokens;
//    LVToken* lastToken;
//    for (int i = 0; i < doc->tokens_len; i++) {
//        LVToken* tok = (*iter)++;
//        if (pos < tok->pos)
//            break;
//        lastToken = tok;
//    }
//    return lastToken->atom;
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
