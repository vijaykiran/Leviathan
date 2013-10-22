//
//  token.mm
//  Leviathan
//
//  Created by Steven on 10/21/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#include "token.h"

namespace Leviathan {
    
    std::ostream& operator<<(std::ostream& os, Token& t) {
        os << "(";
        for (int typ = 1, i = 0; typ < Token::END_TOKEN_TYPES; typ <<= 1, i++) {
            if (t.type & typ) {
                os << TokenStrings[i] << " ";
            }
        }
        os << "'" << t.val << "')";
        return os;
    }
    
    std::ostream& operator<<(std::ostream& os, std::vector<Token*> tokens) {
        for (Token* tok : tokens) {
            os << *tok << ' ';
        }
        return os;
    }
    
}
