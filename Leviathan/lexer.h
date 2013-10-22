//
//  token.h
//  Leviathan
//
//  Created by Steven on 10/19/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#ifndef __Leviathan__lexer__
#define __Leviathan__lexer__

#include <iostream>
#include <vector>

#include "parse_error.h"
#include "token.h"

namespace Leviathan {
    
    std::pair<std::vector<Token*>, ParserError> lex(std::string const& raw);
    
}

#endif /* defined(__Leviathan__lexer__) */
