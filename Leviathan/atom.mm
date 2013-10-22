//
//  atom.cpp
//  Leviathan
//
//  Created by Steven on 10/20/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#include "atom.h"

namespace Leviathan {
    
    std::ostream& operator<<(std::ostream& os, Atom::Type t) {
        static char const* const atom_strs[] = {
#define X(a) #a,
#include "atom_types.def"
#undef X
        };
        
        return os << atom_strs[t];
    }
    
}
