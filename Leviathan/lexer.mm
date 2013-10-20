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
        
        std::pair<std::vector<token>, ParserError> lex(std::string &raw) {
            std::vector<token> tokens;
            ParserError error = ParserError{ParserError::NoError};
            
            tokens.push_back(token{token::Begin, ""});
            
            static std::string endAtomCharSet = "()[]{}, \"\r\n\t;";
            
            size_t i = 0;
            
            while (i < raw.length()) {
                
                char c = raw.at(i);
                
                switch (c) {
                    case '(': tokens.push_back(token{token::LParen, raw.substr(i, 1)}); break;
                    case ')': tokens.push_back(token{token::RParen, raw.substr(i, 1)}); break;
                    case '[': tokens.push_back(token{token::LBracket, raw.substr(i, 1)}); break;
                    case ']': tokens.push_back(token{token::RBracket, raw.substr(i, 1)}); break;
                    case '{': tokens.push_back(token{token::LBrace, raw.substr(i, 1)}); break;
                    case '}': tokens.push_back(token{token::RBrace, raw.substr(i, 1)}); break;
                        
                    case '\'': tokens.push_back(token{token::Quote, raw.substr(i, 1)}); break;
                    case '`': tokens.push_back(token{token::SyntaxQuote, raw.substr(i, 1)}); break;
                    case '^': tokens.push_back(token{token::TypeOp, raw.substr(i, 1)}); break;
                        
                    case ',': tokens.push_back(token{token::Comma, raw.substr(i, 1)}); break;
                    case '\n': tokens.push_back(token{token::Newline, raw.substr(i, 1)}); break;
                        
                    case '~': {
                        if (i + 1 < raw.length() && raw[i+1] == '@')
                            tokens.push_back(token{token::Splice, raw.substr(i, 2)});
                        else
                            tokens.push_back(token{token::Unquote, raw.substr(i, 1)});
                        break;
                    }
                        
                    case ' ': {
                        size_t n = raw.find_first_not_of(" ", i);
                        tokens.push_back(token{token::Spaces, raw.substr(i, n - i)});
                        i = n-1;
                        break;
                    }
                        
                    case '1': case '2': case '3': case '4': case '5': case '6': case '7': case '8': case '9': case '0': {
                        size_t n = raw.find_first_of(endAtomCharSet, i);
                        tokens.push_back(token{token::Number, raw.substr(i, n - i)});
                        i = n-1;
                        break;
                    }
                        
                    case ':': {
                        size_t n = raw.find_first_of(endAtomCharSet, i);
                        tokens.push_back(token{token::Keyword, raw.substr(i, n - i)});
                        i = n-1;
                        break;
                    }
                        
                    case ';': {
                        size_t n = raw.find('\n', i);
                        tokens.push_back(token{token::Comment, raw.substr(i, n - i)});
                        i = n-1;
                        break;
                    }
                        
                    case '\t': tokens.push_back(token{token::Spaces, std::string(2, ' ')}); break;
                        
                    case '"': {
                        size_t look_from = i;
                        
                        do {
                            look_from = raw.find('"', look_from + 1);
                            if (look_from == std::string::npos) {
                                error.type = ParserError::UnclosedString;
                                error.badRange = NSMakeRange(i, raw.length() - i);
                                return std::make_pair(tokens, error);
                            }
                        } while (raw[look_from - 1] == '\\');
                        
                        tokens.push_back(token{token::String, raw.substr(i, look_from - i + 1)});
                        i = look_from;
                        
                        break;
                    }
                        
                    default: {
                        // TODO: dont make the parser always have to do string-comparison! for things like (startswith "def"), we can figure that out here.
                        //       so we need to do that calculation here, and somehow store it on a token. should every token have that info? maybe its just a new TokenType.
                        
                        size_t n = raw.find_first_of(endAtomCharSet, i);
                        tokens.push_back(token{token::Symbol, raw.substr(i, n - i)});
                        i = n-1;
                        
                        break;
                    }
                }
                
                i++;
            }
            
            tokens.push_back(token{token::End, ""});
            
            return std::make_pair(tokens, error);
        }
        
        std::ostream& operator<<(std::ostream& os, token::TokenType c) {
            if (c >= token::TokensCount || c < 0) return os << "???";
            return os << tokens_strs[c];
        }
        
        std::ostream& operator<<(std::ostream& os, token& t) {
            return os << "(" << t.type << " '" << t.val << "')";
        }
        
        std::ostream& operator<<(std::ostream& os, std::vector<token> tokens) {
            for( std::vector<leviathan::lexer::token>::iterator i = tokens.begin(); i != tokens.end(); ++i)
                os << *i << ' ';
            return os;
        }
        
    }
    
}
