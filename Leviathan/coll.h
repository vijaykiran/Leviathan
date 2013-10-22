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
    
    struct Coll: element {
        
        enum Type {
#define X(a) a,
#include "coll_types.def"
#undef X
        };
        
        Type collType;
        Token* open_token;
        Token* close_token;
        std::list<element*> children;
        
        ~Coll();
        
    };
    
    std::ostream& operator<<(std::ostream& os, Coll::Type t);
    
}

#endif /* defined(__Leviathan__coll__) */
