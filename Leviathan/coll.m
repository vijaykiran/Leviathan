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

#define LV_COLL_CHUNK_SIZE (20)

LVColl* LVCollCreate() {
    LVColl* coll = malloc(sizeof(LVColl));
    coll->isAtom = NO;
    
    coll->children.cap = LV_COLL_CHUNK_SIZE;
    coll->children.len = 0;
    coll->children.elements = malloc(sizeof(LVElement*) * coll->children.cap);
    
    return coll;
}

void LVCollDestroy(LVColl* coll) {
    for (int i = 0; i < coll->children.len; i++) {
        LVElement* child = coll->children.elements[i];
        LVElementDestroy(child);
    }
    
    free(coll->children.elements);
    LVTokenDelete(coll->open_token);
    LVTokenDelete(coll->close_token);
    free(coll);
}

void LVElementListAppend(LVColl* coll, LVElement* child) {
    if (coll->children.len == coll->children.cap) {
        coll->children.cap += LV_COLL_CHUNK_SIZE;
        coll->children.elements = realloc(coll->children.elements, sizeof(LVElement*) * coll->children.cap);
    }
//    printf("adding child %p to %p at %lu\n", child, coll, coll->children.len);
    coll->children.elements[coll->children.len] = child;
//    printf("child added: child %p, should == %p which is at index %lu\n", child, coll->children.elements[coll->children.len], coll->children.len);
    coll->children.len++;
}



static void appendToString(LVColl* coll, bstring str) {
    bconcat(str, coll->open_token->val);
    
    for (size_t i = 0; i < coll->children.len; i++) {
        LVElement* child = coll->children.elements[i];
        if (child->isAtom) {
            LVAtom* atom = (void*)child;
            bconcat(str, atom->token->val);
        }
        else {
            appendToString((void*)child, str);
        }
    }
    
    bconcat(str, coll->close_token->val);
}

bstring LVStringForColl(LVColl* coll) {
    bstring str = bfromcstr("");
    appendToString(coll, str);
    return str;
}


LVColl* LVFindDeepestColl(LVColl* coll, size_t offset, size_t pos, size_t* childsIndex) {
    
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
    
    
    
    size_t open_tok_len = coll->open_token->val->slen;
    
    size_t coll_inner_offset = offset + open_tok_len;
    
    if (pos < coll_inner_offset) {
        *childsIndex = coll->index;
        return coll->parent;
    }
    
    size_t cumulative_child_offset = 0;
    
    for (size_t i = 0; i < coll->children.len; i++) {
        LVElement* child = coll->children.elements[i];
        
        size_t this_child_len = LVElementLength(child);
        
        if (pos < coll_inner_offset + cumulative_child_offset + this_child_len) {
            if (child->isAtom) {
                *childsIndex = child->index;
                return child->parent;
            }
            else {
                return LVFindDeepestColl((void*)child, coll_inner_offset + cumulative_child_offset, pos, childsIndex);
            }
        }
        
        cumulative_child_offset += this_child_len;
    }
    
    *childsIndex = coll->children.len;
    return coll;
}

//- (void) findDefinitions:(NSMutableArray*)defs {
//    for (id<LVElement> child in self.childElements) {
//        if ([child isKindOfClass:[LVDefinition self]]) {
//            [defs addObject:child];
//        }
//        
//        if ([child isColl]) {
//            [[child asColl] findDefinitions:defs];
//        }
//    }
//}

LVColl* LVCollHighestParent(LVColl* coll) {
    while (coll->parent->parent)
        coll = coll->parent;
    
    if (coll->collType == LVCollType_TopLevel)
        return NULL;
    else
        return coll;
}
