//
//  coll.h
//  Leviathan
//
//  Created by Steven on 10/20/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#ifndef __Leviathan__coll__
#define __Leviathan__coll__

#include <iostream>

#include <list>
#include "element.h"
#include "token.h"

namespace Leviathan {
    
    struct Coll: public Element {
        
        enum Type : uint64_t {
            TopLevel   = 1 << 0,
            
            List       = 1 << 1,
            Vector     = 1 << 2,
            Map        = 1 << 3,
            
            Def        = 1 << 4,
            Ns         = 1 << 5,
        };
        
        uint64_t collType;
        Token* open_token;
        Token* close_token;
        std::list<Element*> children;
        
        ~Coll();
        
        size_t length();
        
    };
    
}

#endif /* defined(__Leviathan__coll__) */
