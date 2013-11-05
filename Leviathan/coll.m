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

#import "storage.h"

@implementation LVDefinition
@end

#define LV_COLL_CHUNK_SIZE (20)

LVColl* LVCollCreate(LVStorage* storage) {
    LVColl* coll = storage->colls + storage->collCount++;
    coll->isAtom = NO;
    
    coll->childrenCap = LV_COLL_CHUNK_SIZE;
    coll->childrenLen = 0;
    coll->children = malloc(sizeof(LVElement*) * coll->childrenCap);
    
    return coll;
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
    for (NSUInteger i = 0; i < coll->childrenLen; i++) {
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

NSInteger LVGetElementIndexInSiblings(LVElement* child) {
    NSInteger len = child->parent->childrenLen;
    LVElement** children = child->parent->children;
    for (int i = 0; i < len; i++) {
        if (children[i] == child)
            return i;
    }
    return -1;
}

void LVGetSemanticDirectChildren(LVColl* parent, NSUInteger startingPos, LVElement** array, NSUInteger* count) {
    *count = 0;
    for (NSUInteger i = startingPos; i < parent->childrenLen; i++) {
        LVElement* child = parent->children[i];
        
        if (LVElementIsSemantic(child))
            array[(*count)++] = child;
    }
}
