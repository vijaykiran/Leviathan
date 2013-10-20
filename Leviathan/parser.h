//
//  parser.h
//  Leviathan
//
//  Created by Steven on 10/19/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#ifndef __Leviathan__parser__
#define __Leviathan__parser__

#include <iostream>
#include <vector>

//#import "LVParserError.h"

namespace leviathan {
    
    enum TokenType {
#define X(a) a,
#include "token_types.def"
#undef X
        TokensCount
    };
    
    char const* const tokens_strs[] = {
#define X(a) #a,
#include "token_types.def"
#undef X
        "",
    };
    
    class token {
        
    public:
        
        TokenType type;
        std::string val;
        
    };
    
    std::vector<token> lex(std::string &raw);
    
    std::ostream& operator<<(std::ostream& os, TokenType c);
    std::ostream& operator<<(std::ostream& os, token& t);
    
}

#endif /* defined(__Leviathan__parser__) */



// atom will have:
//   - atomType
//   - token

// coll will have:
//   - collType
//   - openToken
//   - closeToken
//   - children
