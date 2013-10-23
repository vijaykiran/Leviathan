//
//  parse_error.h
//  Leviathan
//
//  Created by Steven on 10/20/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#ifndef __Leviathan__parse_error__
#define __Leviathan__parse_error__

#include <iostream>

namespace Leviathan {
    
    struct ParserError {
        
        enum Type {
            NoError,
            
            // lexer errors
            UnclosedString,
            UnclosedRegex,
            UnclosedDispatch,
            
            // parser errors
            UnclosedColl,
            UnopenedCollClosed,
        };
        
        Type type;
        size_t pos;
        size_t len;
        
    };
    
}

#endif /* defined(__Leviathan__parse_error__) */
