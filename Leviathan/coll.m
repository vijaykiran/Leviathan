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
    coll->isAtom = NO;
    
    coll->childrenCap = LV_COLL_CHUNK_SIZE;
    coll->childrenLen = 0;
    coll->children = malloc(sizeof(LVElement*) * coll->childrenCap);
    
    return coll;
}

void LVCollDestroy(LVColl* coll) {
    for (int i = 0; i < coll->childrenLen; i++) {
        LVElement* child = coll->children[i];
        LVElementDestroy(child);
    }
    
    free(coll->children);
    free(coll);
}

void LVElementListAppend(LVColl* coll, LVElement* child) {
    if (coll->childrenLen == coll->childrenCap) {
        coll->childrenCap += LV_COLL_CHUNK_SIZE;
        coll->children = realloc(coll->children, sizeof(LVElement*) * coll->childrenCap);
    }
    
    child->parent = coll;
    
    coll->children[coll->childrenLen] = child;
    coll->childrenLen++;
}



static void appendToString(LVColl* coll, CFMutableStringRef str) {
    for (size_t i = 0; i < coll->childrenLen; i++) {
        LVElement* child = coll->children[i];
        if (child->isAtom) {
            LVAtom* atom = (void*)child;
            CFStringAppend(str, atom->token->string);
        }
        else {
            appendToString((void*)child, str);
        }
    }
}

CFStringRef LVStringForColl(LVColl* coll) {
    CFMutableStringRef str = CFStringCreateMutable(NULL, 0);
    appendToString(coll, str);
    return str;
}

size_t LVGetElementIndexInSiblings(LVElement* child) {
    size_t len = child->parent->childrenLen;
    LVElement** children = child->parent->children;
    for (int i = 0; i < len; i++) {
        if (children[i] == child)
            return i;
    }
    return -1;
}

//LVColl* LVCollHighestParent(LVColl* coll) {
//    while (coll->parent->parent)
//        coll = coll->parent;
//    
//    if (coll->collType == LVCollType_TopLevel)
//        return NULL;
//    else
//        return coll;
//}

void LVGetSemanticDirectChildren(LVColl* parent, size_t startingPos, LVElement** array, size_t* count) {
    *count = 0;
    for (size_t i = startingPos; i < parent->childrenLen; i++) {
        LVElement* child = parent->children[i];
        
        if (LVElementIsSemantic(child))
            array[(*count)++] = child;
    }
}
