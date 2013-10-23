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
    
    struct Token {
        
        enum Type : uint64_t {
            LParen = 1 << 0,
            RParen = 1 << 1,
            
            LBracket = 1 << 2,
            RBracket = 1 << 3,
            
            LBrace = 1 << 4,
            RBrace = 1 << 5,
            
            String =  1 << 6,
            Keyword = 1 << 7,
            Symbol =  1 << 8,
            Number =  1 << 9,
            Regex =   1 << 10,
            
            Quote =       1 << 11,
            Unquote =     1 << 12,
            SyntaxQuote = 1 << 13,
            Splice =      1 << 14,
            TypeOp =      1 << 15,
            
            ReaderCommentStart = 1 << 16,
            ReaderMacro        = 1 << 17,
            AnonFnStart        = 1 << 18,
            SetStart           = 1 << 19,
            Var                = 1 << 20,
            
            Comma   = 1 << 21,
            Spaces  = 1 << 22,
            Newline = 1 << 23,
            
            Comment = 1 << 24,
            
            FileBegin = 1 << 25,
            FileEnd   = 1 << 26,
            
            TrueSymbol  = 1 << 27, // must also be Symbol
            FalseSymbol = 1 << 28, // must also be Symbol
            NilSymbol   = 1 << 29, // must also be Symbol
            
            Deflike     = 1 << 30, // must also be Symbol
        };
        
        uint64_t type;
        std::string val;
        
    };
    
}

#endif /* defined(__Leviathan__token__) */
