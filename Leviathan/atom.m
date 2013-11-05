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
    atom->isAtom = YES;
    atom->atomType = typ;
    atom->token = tok;
    tok->atom = atom;
    return atom;
}

BOOL LVAtomIsSemantic(LVAtom* atom) {
    return !((atom->atomType & LVAtomType_Comma)
             || (atom->atomType & LVAtomType_Newlines)
             || (atom->atomType & LVAtomType_Comment)
             || (atom->atomType & LVAtomType_CollDelim)
             || (atom->atomType & LVAtomType_Spaces));
}
