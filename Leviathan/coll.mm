//
//  coll.mm
//  Leviathan
//
//  Created by Steven on 10/20/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#include "coll.h"

#include "atom.h"

namespace Leviathan {
    
    Coll::~Coll() {
//        printf("destructing a coll... %llu\n", this->collType);
        delete this->open_token;
        delete this->close_token;
        
        for (Element* e : this->children) {
//            Atom* atom = dynamic_cast<Atom*>(e);
//            Coll* coll = dynamic_cast<Coll*>(e);
//            printf("child = %p\n", e);
//            printf("child atom = %p\n", atom);
//            printf("child coll = %p\n", coll);
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
