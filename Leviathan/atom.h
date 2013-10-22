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
    
    struct Atom: public Element {
        
        enum Type : uint64_t {
            Symbol  = 1 << 0,
            String  = 1 << 1,
            Number  = 1 << 2,
            
            Spaces  = 1 << 3,
            
            TrueAtom  = 1 << 4, // must also be Symbol
            FalseAtom = 1 << 5, // must also be Symbol
            NilAtom   = 1 << 6, // must also be Symbol
            
            Deflike = 1 << 7, // must also be Symbol
            Ns      = 1 << 8, // must also be Symbol
        };
        
        int atomType; // TODO: this should actually be an OR'd list of types, so that it can be both Symbol and Deflike, or Symbol and Ns (or something)
        Token* token;
        
        Atom(int type, Token* tok) : atomType(type), token(tok) {} ;
        
    };
    
    std::ostream& operator<<(std::ostream& os, Atom::Type t);
    
}

#endif /* defined(__Leviathan__atom__) */
