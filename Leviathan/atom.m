//
//  atom.cpp
//  Leviathan
//
//  Created by Steven on 10/20/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "atom.h"

LVAtom* LVAtomCreate(LVAtomType typ, LVToken* tok) {
    LVAtom* atom = malloc(sizeof(LVAtom));
    atom->is_atom = YES;
    atom->atom_type = typ;
    atom->token = tok;
    tok->atom = atom;
    return atom;
}

void LVAtomDestroy(LVAtom* atom) {
    LVTokenDelete(atom->token);
    free(atom);
}

BOOL LVAtomIsSemantic(LVAtom* atom) {
    return !((atom->atom_type & LVAtomType_Comma)
             || (atom->atom_type & LVAtomType_Newlines)
             || (atom->atom_type & LVAtomType_Comment)
             || (atom->atom_type & LVAtomType_CollDelim)
             || (atom->atom_type & LVAtomType_Spaces));
}
