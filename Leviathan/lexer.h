//
//  token.h
//  Leviathan
//
//  Created by Steven on 10/19/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#ifndef __Leviathan__token__
#define __Leviathan__token__

#include <iostream>
#include <vector>

//#import "LVParserError.h"

namespace leviathan {
    
    namespace lexer {
        
        char const* const tokens_strs[] = {
#define X(a) #a,
#include "token_types.h"
#undef X
            "",
        };
        
        class token {
            
        public:
            
            enum TokenType {
#define X(a) a,
#include "token_types.h"
#undef X
                TokensCount
            };
            
            TokenType type;
            std::string val;
            
        };
        
        std::vector<token> lex(std::string &raw);
        
        std::ostream& operator<<(std::ostream& os, token::TokenType c);
        std::ostream& operator<<(std::ostream& os, token& t);
        std::ostream& operator<<(std::ostream& os, std::vector<token> t);
        
    }
    
}

#endif /* defined(__Leviathan__token__) */



// atom will have:
//   - atomType
//   - token

// coll will have:
//   - collType
//   - openToken
//   - closeToken
//   - children
