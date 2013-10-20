//
//  token.cpp
//  Leviathan
//
//  Created by Steven on 10/19/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#include "lexer.h"

namespace leviathan {
    
    namespace lexer {
        
        std::vector<token> lex(std::string &raw) {
            std::vector<token> tokens;
            
            tokens.push_back(token{Begin, ""});
            
            static std::string endAtomCharSet = "()[]{}, \"\r\n\t;";
            
            NSUInteger i = 0;
            
            while (i < raw.length()) {
                
                char c = raw.at(i);
                
                switch (c) {
                    case '(': tokens.push_back(token{LParen, raw.substr(i, 1)}); break;
                    case ')': tokens.push_back(token{RParen, raw.substr(i, 1)}); break;
                    case ' ': break;
                        
                    default:
                        size_t n = raw.find_first_of(endAtomCharSet, i);
                        tokens.push_back(token{Symbol, raw.substr(i, n - i)});
                        i = n-1;
                        
                        break;
                }
                
                i++;
            }
            
            tokens.push_back(token{End, ""});
            
            return tokens;
        }
        
        std::ostream& operator<<(std::ostream& os, TokenType c) {
            if (c >= TokensCount || c < 0) return os << "???";
            return os << tokens_strs[c];
        }
        
        std::ostream& operator<<(std::ostream& os, token& t) {
            return os << "{" << t.type << ",'" << t.val << "'}";
        }
        
    }
    
}
