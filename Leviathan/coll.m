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
    free(coll);
}

void LVElementListAppend(LVColl* coll, LVElement* child) {
    if (coll->children_len == coll->children_cap) {
        coll->children_cap += LV_COLL_CHUNK_SIZE;
        coll->children = realloc(coll->children, sizeof(LVElement*) * coll->children_cap);
    }
    
    child->parent = coll;
    
    coll->children[coll->children_len] = child;
    coll->children_len++;
}



static void appendToString(LVColl* coll, CFMutableStringRef str) {
    for (size_t i = 0; i < coll->children_len; i++) {
        LVElement* child = coll->children[i];
        if (child->is_atom) {
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
    size_t len = child->parent->children_len;
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
//    if (coll->coll_type == LVCollType_TopLevel)
//        return NULL;
//    else
//        return coll;
//}

void LVGetSemanticDirectChildren(LVColl* parent, size_t startingPos, LVElement** array, size_t* count) {
    *count = 0;
    for (size_t i = startingPos; i < parent->children_len; i++) {
        LVElement* child = parent->children[i];
        
        if (LVElementIsSemantic(child))
            array[(*count)++] = child;
    }
}
