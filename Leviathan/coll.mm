//
//  coll.mm
//  Leviathan
//
//  Created by Steven on 10/20/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#include "coll.h"

namespace Leviathan {
    
    Coll::~Coll() {
        delete this->open_token;
        
        if (this->close_token)
            delete this->close_token; // might not be set yet, during parsing
        
        for (Element* e : this->children) {
            delete e;
        }
    }
    
    std::ostream& operator<<(std::ostream& os, Coll::Type t) {
        static char const* const coll_type_strs[] = {
#define X(a) #a,
#include "coll_types.def"
#undef X
        };
        
        return os << coll_type_strs[t];
    }
    
}
