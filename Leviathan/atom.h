//
//  atom.h
//  Leviathan
//
//  Created by Steven on 10/20/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#ifndef __Leviathan__atom__
#define __Leviathan__atom__

#include <iostream>

#include "element.h"
#include "token.h"

namespace Leviathan {
    
    char const* const atom_strs[] = {
#define X(a) #a,
#include "atom_types.def"
#undef X
    };
    
    struct atom: public element {
        
        enum AtomType {
#define X(a) a,
#include "atom_types.def"
#undef X
        };
        
        AtomType atomType; // TODO: this should actually be an OR'd list of types, so that it can be both Symbol and Deflike, or Symbol and Ns (or something)
        Token* token; // TODO: we should probably use reference types for *everything* in all these data types.
        
    };
    
    std::ostream& operator<<(std::ostream& os, atom::AtomType t);
    
}

#endif /* defined(__Leviathan__atom__) */
