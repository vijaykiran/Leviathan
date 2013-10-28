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
        return atom->token->string->slen;
    }
    else {
        LVColl* coll = (LVColl*)element;
//        size_t len = coll->open_token->string->slen + coll->close_token->string->slen;
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

static BOOL findAbsolutePosition(LVElement* iter, LVElement* needle, size_t* pos) {
    if (iter == needle)
        return YES;
    
    if (iter->is_atom) {
        *pos += ((LVAtom*)iter)->token->string->slen;
    }
    else {
        LVColl* coll = (void*)iter;
        
        *pos += coll->open_token->string->slen;
        
        for (size_t i = 0; i < coll->children_len; i++) {
            LVElement* child = coll->children[i];
            if (findAbsolutePosition(child, needle, pos))
                return YES;
        }
        
        *pos += coll->close_token->string->slen;
    }
    
    return NO;
}

size_t LVGetAbsolutePosition(LVElement* needle) {
    LVColl* iter = LVGetTopLevelElement(needle);
    size_t pos = 0;
    findAbsolutePosition((void*)iter, needle, &pos);
    return pos;
}

LVColl* LVGetTopLevelElement(LVElement* any) {
    LVColl* iter = (void*)any;
    
    while (iter->parent)
        iter = iter->parent;
    
    return iter;
}

bstring LVStringForElement(LVElement* element) {
    if (element->is_atom)
        return bstrcpy(((LVAtom*)element)->token->string);
    else
        return LVStringForColl((void*)element);
}

size_t LVGetElementDepth(LVElement* needle) {
    size_t i = 0;
    
    LVColl* iter = (void*)needle;
    
    while (iter->parent) {
        i++;
        iter = iter->parent;
    }
    
    return i;
}
