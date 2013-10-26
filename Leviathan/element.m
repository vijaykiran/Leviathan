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
        size_t len = coll->open_token->string->slen + coll->close_token->string->slen;
        for (int i = 0; i < coll->children_len; i++) {
            LVElement* child = coll->children[i];
            len += LVElementLength(child);
        }
        return len;
    }
}

void LVElementDestroy(LVElement* element) {
    if (element->is_atom) {
        LVAtomDestroy((LVAtom*)element);
    }
    else {
        LVCollDestroy((LVColl*)element);
    }
}
