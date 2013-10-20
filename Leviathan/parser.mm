//
//  parser.mm
//  Leviathan
//
//  Created by Steven on 10/19/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#include "parser.h"

namespace leviathan {
    
    std::pair<LVParseError*, std::vector<token>> lex(std::string &raw) {
        std::pair<LVParseError*, std::vector<token>> retVal;
        
        std::vector<token> tokens;
        
        tokens.push_back(token{Begin, ""});
        
        static std::string endAtomCharSet = "()[]{}, \"\r\n\t;";
        
        NSUInteger i = 0;
        
        while (i < raw.length()) {
            
            char c = raw.at(i);
            
            switch (c) {
                case '(': tokens.push_back(token{LParen, raw.substr(i, 1)}); break;
                case ')': tokens.push_back(token{RParen, raw.substr(i, 1)}); break;
                    
                default:
                    break;
            }
            
            i++;
        }
        
        tokens.push_back(token{End, ""});
        
        retVal.first = nil;
        retVal.second = tokens;
        return retVal;
    }
    
    std::ostream& operator<<(std::ostream& os, Tokens c) {
        if (c >= TokensCount || c < 0) return os << "???";
        return os << tokens_strs[c];
    }
    
}
