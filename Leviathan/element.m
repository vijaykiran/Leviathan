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
    if (element->elementType & LVElementType_Coll) {
        LVColl* coll = (LVColl*)element;
        size_t len = coll->open_token->val->slen + coll->close_token->val->slen;
        for (int i = 0; i < coll->children.len; i++) {
            LVElement* child = coll->children.elements[i];
            len += LVElementLength(child);
        }
        return len;
    }
    else if (element->elementType & LVElementType_Atom) {
        LVAtom* atom = (LVAtom*)element;
        return atom->token->val->slen;
    }
    printf("asking element length for bad element.\n");
    exit(1);
}

void LVElementDestroy(LVElement* element) {
    if (element->elementType & LVElementType_Coll) {
        LVCollDestroy((LVColl*)element);
    }
    else if (element->elementType & LVElementType_Atom) {
        LVAtomDestroy((LVAtom*)element);
    }
}
