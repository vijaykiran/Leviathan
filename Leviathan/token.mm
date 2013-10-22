//
//  token.mm
//  Leviathan
//
//  Created by Steven on 10/21/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#include "token.h"

namespace Leviathan {
    
    std::ostream& operator<<(std::ostream& os, Token::Type c) {
        static char const* const tokens_strs[] = {
#define X(a) #a,
#include "token_types.def"
#undef X
        };
        
        return os << tokens_strs[c];
    }
    
    std::ostream& operator<<(std::ostream& os, Token& t) {
        return os << "(" << t.type << " '" << t.val << "')";
    }
    
    std::ostream& operator<<(std::ostream& os, std::vector<Token*> tokens) {
        for (std::vector<Token*>::iterator i = tokens.begin(); i != tokens.end(); ++i)
            os << **i << ' ';
        return os;
    }
    
}
