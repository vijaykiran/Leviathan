//
//  atom.cpp
//  Leviathan
//
//  Created by Steven on 10/20/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#include "atom.h"

namespace leviathan {
    
    std::ostream& operator<<(std::ostream& os, atom::AtomType t) {
        return os << atom_strs[t];
    }
    
}
