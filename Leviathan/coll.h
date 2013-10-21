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
#include "lexer.h"

namespace leviathan {
    
    char const* const coll_type_strs[] = {
#define X(a) #a,
#include "coll_types.def"
#undef X
    };
    
    struct coll: element {
        
        enum CollType {
#define X(a) a,
#include "coll_types.def"
#undef X
        };
        
        CollType listType;
        lexer::token open_token;
        lexer::token close_token;
        std::list<element> children;
        
    };
    
}

#endif /* defined(__Leviathan__coll__) */
