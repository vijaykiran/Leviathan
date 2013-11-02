//
//  element.m
//  Leviathan
//
//  Created by Steven Degutis on 10/23/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "element.h"

#import "coll.h"
#import "atom.h"

NSUInteger LVElementLength(LVElement* element) {
    if (element->isAtom) {
        LVAtom* atom = (LVAtom*)element;
        return CFStringGetLength(atom->token->string);
    }
    else {
        LVColl* coll = (LVColl*)element;
        NSUInteger len = 0;
        for (int i = 0; i < coll->childrenLen; i++) {
            LVElement* child = coll->children[i];
            len += LVElementLength(child);
        }
        return len;
    }
}

void LVElementDestroy(LVElement* element) {
    if (element->isAtom)
        LVAtomDestroy((LVAtom*)element);
    else
        LVCollDestroy((LVColl*)element);
}

LVColl* LVGetTopLevelElement(LVElement* any) {
    LVColl* iter = (void*)any;
    
    while (iter->parent)
        iter = iter->parent;
    
    return iter;
}

LVElement* LVFindPreviousSemanticElement(LVElement* needle) {
    // if needle is semantic, return it
    // otherwise, find its previous sibling and loop again
    
    LVColl* needleParent = needle->parent;
    
    for (NSInteger needleIndex = LVGetElementIndexInSiblings(needle); needleIndex >= 0; needleIndex--) {
        LVElement* needle = needleParent->children[needleIndex];
        if (LVElementIsSemantic(needle))
            return needle;
    }
    
    return NULL;
}

BOOL LVElementIsSemantic(LVElement* el) {
    return (!el->isAtom || LVAtomIsSemantic((LVAtom*)el));
}

NSUInteger LVGetAbsolutePosition(LVElement* el) {
    if (el->isAtom) {
        LVAtom* atom = (void*)el;
        return atom->token->pos;
    }
    else {
        LVColl* coll = (void*)el;
        LVAtom* openChild = (void*)coll->children[0];
        return openChild->token->pos;
    }
}

NSUInteger LVGetElementDepth(LVElement* needle) {
    NSUInteger i = 0;
    
    LVElement* iter = needle;
    
    while (iter->parent) {
        i++;
        iter = (LVElement*)iter->parent;
    }
    
    return i - 2; // one for top-level-coll, one because delims are children of the coll
}

CFStringRef LVStringForElement(LVElement* element) {
    if (element->isAtom)
        return CFStringCreateCopy(NULL, ((LVAtom*)element)->token->string);
    else
        return LVStringForColl((void*)element);
}
