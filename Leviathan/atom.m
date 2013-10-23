//
//  atom.cpp
//  Leviathan
//
//  Created by Steven on 10/20/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "atom.h"

LVAtom* LVAtomCreate() {
    LVAtom* atom = malloc(sizeof(LVAtom));
    atom->elementType = LVElementType_Atom;
    return atom;
}

void LVAtomDestroy(LVAtom* atom) {
    LVTokenDelete(atom->token);
    free(atom);
}
