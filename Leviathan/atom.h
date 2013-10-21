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

#include <memory>

#include "lexer.h"

namespace leviathan {
    
    char const* const atom_strs[] = {
#define X(a) #a,
#include "atom_types.h"
#undef X
    };
    
    struct atom {
        
        enum AtomType {
#define X(a) a,
#include "atom_types.h"
#undef X
        };
        
//        std::unique_ptr<<#class _Tp#>>
//        
        AtomType atomType;
        lexer::token token;
        
    };
    
    std::ostream& operator<<(std::ostream& os, atom::AtomType t);
    
}

// element will have:
//   - parent (coll)
//   - idx

// coll will have:
//   - collType
//   - openToken
//   - closeToken
//   - children


#endif /* defined(__Leviathan__atom__) */
