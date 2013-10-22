//
//  token.h
//  Leviathan
//
//  Created by Steven on 10/21/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#ifndef __Leviathan__token__
#define __Leviathan__token__

#include <iostream>
#include <vector>

namespace leviathan {
    
    char const* const tokens_strs[] = {
#define X(a) #a,
#include "token_types.def"
#undef X
    };
    
    struct token {
        
        enum TokenType {
#define X(a) a,
#include "token_types.def"
#undef X
        };
        
        TokenType type;
        std::string val;
        
        bool operator==(const token &other) const { // NOTE: only used for tests!
            return this->type == other.type && this->val == other.val;
        }
        
    };
    
    std::ostream& operator<<(std::ostream& os, token::TokenType c);
    std::ostream& operator<<(std::ostream& os, token& t);
    std::ostream& operator<<(std::ostream& os, std::vector<token*> t);
    
}

#endif /* defined(__Leviathan__token__) */
