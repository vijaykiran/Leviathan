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
    coll->elementType = LVElementType_Coll;
    
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


LVColl* LVFindDeepestColl(LVColl* coll, size_t offset, size_t pos, size_t* childsIndex, int* inWhat) {
    
    printf("so broken :(\n");
    abort();
    
    size_t coll_inner_offset = offset + coll->open_token->val->slen;
    
    if (pos < coll_inner_offset) {
        *inWhat = -1;
        *childsIndex = coll->index;
        return coll->parent;
    }
    
    for (int i = 0; i < coll->children.len; i++) {
        LVElement* child = coll->children.elements[i];
        
        size_t child_len = LVElementLength(child);
        
        if (pos <= offset + child_len) {
            // in the child somewhere
            
            if (child->elementType & LVElementType_Atom) {
                *inWhat = 0;
                *childsIndex = child->index;
                return child->parent;
            }
            else {
                return LVFindDeepestColl((LVColl*)child, offset, pos, childsIndex, inWhat);
            }
        }
        
        offset += child_len;
    }
    
    // it's in the current coll's close-token
    
    *inWhat = 1;
    *childsIndex = coll->index;
    return coll->parent;
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // TODO: uhh...
    
//    int i = 0;
//    
//    if (pos <= offset + coll->open_token->val->slen) {
//        *childsIndex = 0;
//        return coll;
//    }
//    
//    for (; i < coll->children.len; i++) {
//        LVElement* child = coll->children.elements[i];
//        
//        if (pos < offset + LVElementLength(child)) {
//            if ((child->elementType & LVElementType_Atom) || (pos <= offset)) {
//                *childsIndex = i;
//                return coll;
//            }
//            else {
//                return LVFindDeepestColl(child, offset + , pos, childsIndex);
//            }
//        }
//    }
//    
//    *childsIndex = i;
//    return coll;
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
