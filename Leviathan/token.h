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

namespace Leviathan {
    
    static char const* const TokenStrings[] = {
#define X(a, b) #a,
#include "token_types.def"
#undef X
    };
    
    struct Token {
        
        enum Type : unsigned long long {
#define X(a, b) a = b,
#include "token_types.def"
#undef X
            END_TOKEN_TYPES,
        };
        
        int type;
        std::string val;
        
        bool operator==(const Token &other) const { // NOTE: only used for tests!
            return this->type == other.type && this->val == other.val;
        }
        
    };
    
    std::ostream& operator<<(std::ostream& os, Token& t);
    std::ostream& operator<<(std::ostream& os, std::vector<Token*> t);
    
}

#endif /* defined(__Leviathan__token__) */
