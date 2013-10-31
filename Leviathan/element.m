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

size_t LVElementLength(LVElement* element) {
    if (element->is_atom) {
        LVAtom* atom = (LVAtom*)element;
        return CFStringGetLength(atom->token->string);
    }
    else {
        LVColl* coll = (LVColl*)element;
        size_t len = 0;
        for (int i = 0; i < coll->children_len; i++) {
            LVElement* child = coll->children[i];
            len += LVElementLength(child);
        }
        return len;
    }
}

void LVElementDestroy(LVElement* element) {
    if (element->is_atom)
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

CFStringRef LVStringForElement(LVElement* element) {
    if (element->is_atom)
        return CFStringCreateCopy(NULL, ((LVAtom*)element)->token->string);
    else
        return LVStringForColl((void*)element);
}

size_t LVGetElementDepth(LVElement* needle) {
    size_t i = 0;
    
    LVElement* iter = needle;
    
    while (iter->parent) {
        i++;
        iter = (LVElement*)iter->parent;
    }
    
    return i - 2; // one for top-level-coll, one because delims are children of the coll
}

size_t LVGetAbsolutePosition(LVElement* el) {
    if (el->is_atom) {
        LVAtom* atom = (void*)el;
        return atom->token->pos;
    }
    else {
        LVColl* coll = (void*)el;
        LVAtom* openChild = (void*)coll->children[0];
        return openChild->token->pos;
    }
}
