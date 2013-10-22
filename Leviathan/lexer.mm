//
//  token.cpp
//  Leviathan
//
//  Created by Steven on 10/19/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#include "lexer.h"

#include "token.h"

namespace Leviathan {
    
    std::pair<std::vector<Token*>, ParserError> lex(std::string const& raw) {
        std::vector<Token*> tokens;
        ParserError error = ParserError{ParserError::NoError};
        
        tokens.push_back(new Token{Token::FileBegin, ""});
        
        static std::string endAtomCharSet = "()[]{}, \"\r\n\t;";
        
        size_t i = 0;
        
        while (i < raw.length()) {
            
            char c = raw.at(i);
            
            switch (c) {
                case '(': tokens.push_back(new Token{Token::LParen, raw.substr(i, 1)}); break;
                case ')': tokens.push_back(new Token{Token::RParen, raw.substr(i, 1)}); break;
                case '[': tokens.push_back(new Token{Token::LBracket, raw.substr(i, 1)}); break;
                case ']': tokens.push_back(new Token{Token::RBracket, raw.substr(i, 1)}); break;
                case '{': tokens.push_back(new Token{Token::LBrace, raw.substr(i, 1)}); break;
                case '}': tokens.push_back(new Token{Token::RBrace, raw.substr(i, 1)}); break;
                    
                case '\'': tokens.push_back(new Token{Token::Quote, raw.substr(i, 1)}); break;
                case '`': tokens.push_back(new Token{Token::SyntaxQuote, raw.substr(i, 1)}); break;
                case '^': tokens.push_back(new Token{Token::TypeOp, raw.substr(i, 1)}); break;
                    
                case ',': tokens.push_back(new Token{Token::Comma, raw.substr(i, 1)}); break;
                case '\n': tokens.push_back(new Token{Token::Newline, raw.substr(i, 1)}); break;
                    
                case '~': {
                    if (i + 1 < raw.length() && raw[i+1] == '@') {
                        tokens.push_back(new Token{Token::Splice, raw.substr(i++, 2)});
                        i++;
                    }
                    else {
                        tokens.push_back(new Token{Token::Unquote, raw.substr(i, 1)});
                    }
                    break;
                }
                    
                case ' ': {
                    size_t n = raw.find_first_not_of(" ", i);
                    tokens.push_back(new Token{Token::Spaces, raw.substr(i, n - i)});
                    i = n-1;
                    break;
                }
                    
                case '1': case '2': case '3': case '4': case '5': case '6': case '7': case '8': case '9': case '0': {
                    size_t n = raw.find_first_of(endAtomCharSet, i);
                    tokens.push_back(new Token{Token::Number, raw.substr(i, n - i)});
                    i = n-1;
                    break;
                }
                    
                case ':': {
                    size_t n = raw.find_first_of(endAtomCharSet, i);
                    tokens.push_back(new Token{Token::Keyword, raw.substr(i, n - i)});
                    i = n-1;
                    break;
                }
                    
                case ';': {
                    size_t n = raw.find('\n', i);
                    tokens.push_back(new Token{Token::Comment, raw.substr(i, n - i)});
                    i = n-1;
                    break;
                }
                    
                case '\t': tokens.push_back(new Token{Token::Spaces, std::string(2, ' ')}); break;
                    
                case '"': {
                    size_t look_from = i;
                    
                    do {
                        look_from = raw.find('"', look_from + 1);
                        if (look_from == std::string::npos) {
                            error.type = ParserError::UnclosedString;
                            error.pos = i;
                            error.len = raw.length() - i;
                            return std::make_pair(tokens, error);
                        }
                    } while (raw[look_from - 1] == '\\');
                    
                    tokens.push_back(new Token{Token::String, raw.substr(i, look_from - i + 1)});
                    i = look_from;
                    
                    break;
                }
                    
                case '#': {
                    if (i + 1 == raw.length()) {
                        error.type = ParserError::UnclosedDispatch;
                        error.pos = i;
                        error.len = raw.length() - i;
                        return std::make_pair(tokens, error);
                    }
                    
                    char next = raw[i + 1];
                    
                    switch (next) {
                        case '"': {
                            size_t look_from = i + 2;
                            
                            do {
                                look_from = raw.find('"', look_from + 1);
                                if (look_from == std::string::npos) {
                                    error.type = ParserError::UnclosedRegex;
                                    error.pos = i;
                                    error.len = raw.length() - i;
                                    return std::make_pair(tokens, error);
                                }
                            } while (raw[look_from - 1] == '\\');
                            
                            tokens.push_back(new Token{Token::Regex, raw.substr(i, look_from - i + 1)});
                            i = look_from;
                            
                            break;
                        }
                            
                        case '\'': {
                            size_t n = raw.find_first_of(endAtomCharSet, i);
                            tokens.push_back(new Token{Token::Var, raw.substr(i, n - i)});
                            i = n-1;
                            break;
                        }
                            
                        case '(': tokens.push_back(new Token{Token::AnonFnStart, raw.substr(i++, 2)}); break;
                        case '{': tokens.push_back(new Token{Token::SetStart, raw.substr(i++, 2)}); break;
                        case '_': tokens.push_back(new Token{Token::ReaderCommentStart, raw.substr(i++, 2)}); break;
                            
                        default:
                            size_t n = raw.find_first_of(endAtomCharSet, i);
                            tokens.push_back(new Token{Token::ReaderMacro, raw.substr(i, n - i)});
                            i = n-1;
                            break;
                    }
                    
                    break;
                }
                    
                default: {
                    // TODO: dont make the parser always have to do string-comparison! for things like (startswith "def"), we can figure that out here.
                    //       so we need to do that calculation here, and somehow store it on a token. should every token have that info? maybe its just a new TokenType.
                    
                    size_t n = raw.find_first_of(endAtomCharSet, i);
                    tokens.push_back(new Token{Token::Symbol, raw.substr(i, n - i)});
                    i = n-1;
                    
                    break;
                }
            }
            
            i++;
        }
        
        tokens.push_back(new Token{Token::FileEnd, ""});
        
        return std::make_pair(tokens, error);
    }
    
}
