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
    
    LVToken** tokens = malloc(sizeof(LVToken*) * (input_string_length + 2));
    
    static bstring endAtomCharSet;
    if (!endAtomCharSet) endAtomCharSet = bfromcstr("()[]{}, \"\r\n\t;");
    
    tokens[num_tokens++] = LVTokenCreate(LVTokenType_FileBegin, bfromcstr(""));
    
    size_t i = 0;
    while (i < input_string_length) {
        
        unsigned char c = raw->data[i];
        
        switch (c) {
                
            case '(': tokens[num_tokens++] = LVTokenCreate(LVTokenType_LParen, bmidstr(raw, (int)i, 1)); break;
            case ')': tokens[num_tokens++] = LVTokenCreate(LVTokenType_RParen, bmidstr(raw, (int)i, 1)); break;
                
            case '[': tokens[num_tokens++] = LVTokenCreate(LVTokenType_LBracket, bmidstr(raw, (int)i, 1)); break;
            case ']': tokens[num_tokens++] = LVTokenCreate(LVTokenType_RBracket, bmidstr(raw, (int)i, 1)); break;
                
            case '{': tokens[num_tokens++] = LVTokenCreate(LVTokenType_LBrace, bmidstr(raw, (int)i, 1)); break;
            case '}': tokens[num_tokens++] = LVTokenCreate(LVTokenType_RBrace, bmidstr(raw, (int)i, 1)); break;
                
            case '\'': tokens[num_tokens++] = LVTokenCreate(LVTokenType_Quote, bmidstr(raw, (int)i, 1)); break;
            case '^': tokens[num_tokens++] = LVTokenCreate(LVTokenType_TypeOp, bmidstr(raw, (int)i, 1)); break;
            case '`': tokens[num_tokens++] = LVTokenCreate(LVTokenType_SyntaxQuote, bmidstr(raw, (int)i, 1)); break;
                
            case ',': tokens[num_tokens++] = LVTokenCreate(LVTokenType_Comma, bmidstr(raw, (int)i, 1)); break;
            case '\n': tokens[num_tokens++] = LVTokenCreate(LVTokenType_Newline, bmidstr(raw, (int)i, 1)); break;
                
            case '\t': tokens[num_tokens++] = LVTokenCreate(LVTokenType_Newline, bfromcstr("  ")); break;
                
            case '~': {
                if (i + 1 < raw->slen && raw->data[i+1] == '@') {
                    tokens[num_tokens++] = LVTokenCreate(LVTokenType_Splice, bmidstr(raw, (int)i, 2));
                    i++;
                }
                else {
                    tokens[num_tokens++] = LVTokenCreate(LVTokenType_Unquote, bmidstr(raw, (int)i, 1));
                }
                break;
            }
                
            case ' ': {
                bstring spaces = bfromcstr(" ");
                size_t n = bninchr(raw, (int)i, spaces);
                if (n == BSTR_ERR) n = input_string_length;
                tokens[num_tokens++] = LVTokenCreate(LVTokenType_Spaces, bmidstr(raw, (int)i, (int)(n - i)));
                i = n-1;
                break;
            }
                
            case ':': {
                size_t n = binchr(raw, (int)i, endAtomCharSet);
                if (n == BSTR_ERR) n = input_string_length;
                tokens[num_tokens++] = LVTokenCreate(LVTokenType_Keyword, bmidstr(raw, (int)i, (int)(n - i)));
                i = n-1;
                break;
            }
                
            case '"': {
                int look_from = (int)i;
                
                do {
                    look_from = bstrchrp(raw, '"', look_from + 1);
                    
                    if (look_from == BSTR_ERR) {
                        printf("error: unclosed string\n");
                        exit(1);
                    }
                } while (raw->data[look_from - 1] == '\\');
                
                bstring substring = bmidstr(raw, (int)i, (int)(look_from - i + 1));
                LVToken* tok = LVTokenCreate(LVTokenType_String, substring);
                tokens[num_tokens++] = tok;
                i = look_from;
                
                break;
            }
                
            default: {
                size_t n = binchr(raw, (int)i, endAtomCharSet);
                if (n == BSTR_ERR) n = input_string_length;
                
                bstring substring = bmidstr(raw, (int)i, (int)(n - i));
                LVToken* tok = LVTokenCreate(LVTokenType_Symbol, substring);
                
                static bstring trueConstant; if (!trueConstant) trueConstant = bfromcstr("true");
                static bstring falseConstant; if (!falseConstant) falseConstant = bfromcstr("false");
                static bstring nilConstant; if (!nilConstant) nilConstant = bfromcstr("nil");
                static bstring defConstant; if (!defConstant) defConstant = bfromcstr("def");
                
                if (biseq(substring, trueConstant)) tok->type |= LVTokenType_TrueSymbol;
                if (biseq(substring, falseConstant)) tok->type |= LVTokenType_FalseSymbol;
                if (biseq(substring, nilConstant)) tok->type |= LVTokenType_NilSymbol;
                
                struct tagbstring def_prefix_substr;
                bmid2tbstr(def_prefix_substr, substring, 0, 3);
                if (biseq(&def_prefix_substr, defConstant)) tok->type |= LVTokenType_Deflike;
                
                tokens[num_tokens++] = tok;
                i = n-1;
                
                break;
            }
        }
        
        i++;
        
    }
    
    tokens[num_tokens++] = LVTokenCreate(LVTokenType_FileEnd, bfromcstr(""));
    
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
//            }
//            
//            i++;
