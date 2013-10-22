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
        return;
        
        delete this->open_token;
        
        if (this->close_token)
            delete this->close_token; // might not be set yet, during parsing
        
        for (Element* e : this->children) {
            delete e;
        }
    }
    
}
