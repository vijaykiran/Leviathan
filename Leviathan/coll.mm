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
        printf("in here %llu\n", this->open_token->type);
        delete this->open_token;
        delete this->close_token;
        
        for (Element* e : this->children) {
            Token* tok = dynamic_cast<Token*>(e);
            Coll* coll = dynamic_cast<Coll*>(e);
            printf("child = %p\n", e);
            printf("child tok = %p\n", tok);
            printf("child coll = %p\n", coll);
            delete e;
        }
        this->children.clear();
    }
    
    size_t Coll::length() {
        size_t len = this->open_token->val.length() + this->close_token->val.length();
        for (Element* child : this->children) {
            len += child->length();
        }
        return len;
    }
    
}
