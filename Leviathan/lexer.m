////
////  token.cpp
////  Leviathan
////
////  Created by Steven on 10/19/13.
////  Copyright (c) 2013 Steven Degutis. All rights reserved.
////

#include "lexer.h"

LVToken** LVLex(char* input_str, size_t* n_tok) {
    bstring raw = bfromcstr(input_str);
    
    size_t input_string_length = raw->slen;
    size_t num_tokens = 0;
    
    LVToken** tokens = malloc(sizeof(LVToken*) * input_string_length);
    
    static bstring endAtomCharSet;
    if (!endAtomCharSet) endAtomCharSet = bfromcstr("()[]{}, \"\r\n\t;");
    
    tokens[num_tokens++] = LVTokenCreate(LVTokenType_FileBegin, "", 0);
    
    size_t i = 0;
    while (i < input_string_length) {
        
        unsigned char c = raw->data[i];
        
        switch (c) {
                
            case '(': tokens[num_tokens++] = LVTokenCreate(LVTokenType_LParen, &raw->data[i], 1); break;
            case ')': tokens[num_tokens++] = LVTokenCreate(LVTokenType_RParen, &raw->data[i], 1); break;
                
            case '[': tokens[num_tokens++] = LVTokenCreate(LVTokenType_LBracket, &raw->data[i], 1); break;
            case ']': tokens[num_tokens++] = LVTokenCreate(LVTokenType_RBracket, &raw->data[i], 1); break;
                
            case '{': tokens[num_tokens++] = LVTokenCreate(LVTokenType_LBrace, &raw->data[i], 1); break;
            case '}': tokens[num_tokens++] = LVTokenCreate(LVTokenType_RBrace, &raw->data[i], 1); break;
                
            case '\'': tokens[num_tokens++] = LVTokenCreate(LVTokenType_Quote, &raw->data[i], 1); break;
            case '^': tokens[num_tokens++] = LVTokenCreate(LVTokenType_TypeOp, &raw->data[i], 1); break;
            case '`': tokens[num_tokens++] = LVTokenCreate(LVTokenType_SyntaxQuote, &raw->data[i], 1); break;
                
            case ',': tokens[num_tokens++] = LVTokenCreate(LVTokenType_Comma, &raw->data[i], 1); break;
            case '\n': tokens[num_tokens++] = LVTokenCreate(LVTokenType_Newline, &raw->data[i], 1); break;
                
            case '\t': tokens[num_tokens++] = LVTokenCreate(LVTokenType_Newline, "  ", 2); break;
                
            case '~': {
                if (i + 1 < raw->slen && raw->data[i+1] == '@') {
                    tokens[num_tokens++] = LVTokenCreate(LVTokenType_Splice, &raw->data[i], 2);
                    i++;
                }
                else {
                    tokens[num_tokens++] = LVTokenCreate(LVTokenType_Unquote, &raw->data[i], 1);
                }
                break;
            }
                
            case ' ': {
                bstring spaces = bfromcstr(" ");
                size_t n = bninchr(raw, (int)i, spaces);
                if (n == BSTR_ERR) n = input_string_length;
                tokens[num_tokens++] = LVTokenCreate(LVTokenType_Spaces, &raw->data[i], (int)(n - i));
                i = n-1;
                break;
            }
                
            case ':': {
                size_t n = binchr(raw, (int)i, endAtomCharSet);
                if (n == BSTR_ERR) n = input_string_length;
                tokens[num_tokens++] = LVTokenCreate(LVTokenType_Keyword, &raw->data[i], (int)(n - i));
                i = n-1;
                break;
            }
                
            default:
                break;
        }
        
        i++;
        
    }
    
    tokens[num_tokens++] = LVTokenCreate(LVTokenType_FileEnd, "", 0);
    
    *n_tok = num_tokens;
    return tokens;
}

//            switch (c) {
//
//                case '1': case '2': case '3': case '4': case '5': case '6': case '7': case '8': case '9': case '0': {
//                    size_t n = raw.find_first_of(endAtomCharSet, i);
//                    tokens.push_back(new Token{Token::Number, raw.substr(i, n - i)});
//                    i = n-1;
//                    break;
//                }
//                    
//                case ';': {
//                    size_t n = raw.find('\n', i);
//                    tokens.push_back(new Token{Token::Comment, raw.substr(i, n - i)});
//                    i = n-1;
//                    break;
//                }
//                    
//                case '"': {
//                    size_t look_from = i;
//                    
//                    do {
//                        look_from = raw.find('"', look_from + 1);
//                        if (look_from == std::string::npos) {
//                            error.type = ParserError::UnclosedString;
//                            error.pos = i;
//                            error.len = raw.length() - i;
//                            return std::make_pair(tokens, error);
//                        }
//                    } while (raw[look_from - 1] == '\\');
//                    
//                    tokens.push_back(new Token{Token::String, raw.substr(i, look_from - i + 1)});
//                    i = look_from;
//                    
//                    break;
//                }
//                    
//                case '#': {
//                    if (i + 1 == raw.length()) {
//                        error.type = ParserError::UnclosedDispatch;
//                        error.pos = i;
//                        error.len = raw.length() - i;
//                        return std::make_pair(tokens, error);
//                    }
//                    
//                    char next = raw[i + 1];
//                    
//                    switch (next) {
//                        case '"': {
//                            size_t look_from = i + 2;
//                            
//                            do {
//                                look_from = raw.find('"', look_from + 1);
//                                if (look_from == std::string::npos) {
//                                    error.type = ParserError::UnclosedRegex;
//                                    error.pos = i;
//                                    error.len = raw.length() - i;
//                                    return std::make_pair(tokens, error);
//                                }
//                            } while (raw[look_from - 1] == '\\');
//                            
//                            tokens.push_back(new Token{Token::Regex, raw.substr(i, look_from - i + 1)});
//                            i = look_from;
//                            
//                            break;
//                        }
//                            
//                        case '\'': {
//                            size_t n = raw.find_first_of(endAtomCharSet, i);
//                            tokens.push_back(new Token{Token::Var, raw.substr(i, n - i)});
//                            i = n-1;
//                            break;
//                        }
//                            
//                        case '(': tokens.push_back(new Token{Token::AnonFnStart, raw.substr(i++, 2)}); break;
//                        case '{': tokens.push_back(new Token{Token::SetStart, raw.substr(i++, 2)}); break;
//                        case '_': tokens.push_back(new Token{Token::ReaderCommentStart, raw.substr(i++, 2)}); break;
//                            
//                        default:
//                            size_t n = raw.find_first_of(endAtomCharSet, i);
//                            tokens.push_back(new Token{Token::ReaderMacro, raw.substr(i, n - i)});
//                            i = n-1;
//                            break;
//                    }
//                    
//                    break;
//                }
//                    
//                default: {
//                    // TODO: dont make the parser always have to do string-comparison! for things like (startswith "def"), we can figure that out here.
//                    //       so we need to do that calculation here, and somehow store it on a token. should every token have that info? maybe its just a new TokenType.
//                    
//                    size_t n = raw.find_first_of(endAtomCharSet, i);
//                    std::string substring = raw.substr(i, n - i);
//                    Token* tok = new Token{Token::Symbol, substring};
//                    
//                    if (substring == "true") tok->type |= Token::TrueSymbol;
//                    if (substring == "false") tok->type |= Token::FalseSymbol;
//                    if (substring == "nil") tok->type |= Token::NilSymbol;
//                    
//                    if (substring.substr(0, 3) == "def") tok->type |= Token::Deflike;
//                    
//                    tokens.push_back(tok);
//                    i = n-1;
//                    
//                    break;
//                }
//            }
//            
//            i++;
