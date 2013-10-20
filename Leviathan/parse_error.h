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

namespace leviathan {
    
    class ParserError: public std::exception {
        
    public:
        
        enum ParserErrorType {
            UnclosedString,
        };
        
        ParserErrorType type;
        NSRange badRange;
        
        ParserError(ParserErrorType t, NSRange r) : type(t), badRange(r) {}
        
    };
    
}

#endif /* defined(__Leviathan__parse_error__) */
