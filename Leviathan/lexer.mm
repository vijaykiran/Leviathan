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
            
            tokens.push_back(token{token::Begin, ""});
            
            static std::string endAtomCharSet = "()[]{}, \"\r\n\t;";
            
            size_t i = 0;
            
            while (i < raw.length()) {
                
                char c = raw.at(i);
                
                switch (c) {
                    case '(': tokens.push_back(token{token::LParen, raw.substr(i, 1)}); break;
                    case ')': tokens.push_back(token{token::RParen, raw.substr(i, 1)}); break;
                    case ' ': break;
                        
                    case '"':
                    {
                        size_t look_from = i;
                        
                        do {
                            look_from = raw.find_first_of('"', look_from + 1);
                            if (look_from == std::string::npos) {
                                throw ParserError{ParserError::UnclosedString, NSMakeRange(i, raw.length() - i)};
                            }
                        } while (raw[look_from - 1] == '\\');
                        
                        tokens.push_back(token{token::String, raw.substr(i, look_from - i + 1)});
                        i = look_from;
                        
                        break;
                    }
                        
                    default:
                    {
                        size_t n = raw.find_first_of(endAtomCharSet, i);
                        tokens.push_back(token{token::Symbol, raw.substr(i, n - i)});
                        i = n-1;
                        
                        break;
                    }
                }
                
                i++;
            }
            
            tokens.push_back(token{token::End, ""});
            
            return tokens;
        }
        
        std::ostream& operator<<(std::ostream& os, token::TokenType c) {
            if (c >= token::TokensCount || c < 0) return os << "???";
            return os << tokens_strs[c];
        }
        
        std::ostream& operator<<(std::ostream& os, token& t) {
            return os << "{" << t.type << " '" << t.val << "'}";
        }
        
        std::ostream& operator<<(std::ostream& os, std::vector<token> tokens) {
            for( std::vector<leviathan::lexer::token>::iterator i = tokens.begin(); i != tokens.end(); ++i)
                os << *i << ' ';
            return os;
        }
        
    }
    
}
