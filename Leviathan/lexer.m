////
////  token.cpp
////  Leviathan
////
////  Created by Steven on 10/19/13.
////  Copyright (c) 2013 Steven Degutis. All rights reserved.
////

#include "lexer.h"

LVToken** LVLex(const char* input_str, size_t* n_tok) {
    bstring raw = bfromcstr(input_str);
    
    size_t input_string_length = raw->slen;
    size_t num_tokens = 0;
    
    LVToken** tokens = malloc(sizeof(LVToken*) * (input_string_length + 2));
    
    static bstring endAtomCharSet;
    if (!endAtomCharSet) endAtomCharSet = bfromcstr("()[]{}, \"\r\n\t;");
    
    tokens[num_tokens++] = LVTokenCreate(0, LVTokenType_FileBegin, bfromcstr(""));
    
    size_t i = 0;
    while (i < input_string_length) {
        
        unsigned char c = raw->data[i];
        
        switch (c) {
                
            case '(': tokens[num_tokens++] = LVTokenCreate(i, LVTokenType_LParen, bmidstr(raw, (int)i, 1)); break;
            case ')': tokens[num_tokens++] = LVTokenCreate(i, LVTokenType_RParen, bmidstr(raw, (int)i, 1)); break;
                
            case '[': tokens[num_tokens++] = LVTokenCreate(i, LVTokenType_LBracket, bmidstr(raw, (int)i, 1)); break;
            case ']': tokens[num_tokens++] = LVTokenCreate(i, LVTokenType_RBracket, bmidstr(raw, (int)i, 1)); break;
                
            case '{': tokens[num_tokens++] = LVTokenCreate(i, LVTokenType_LBrace, bmidstr(raw, (int)i, 1)); break;
            case '}': tokens[num_tokens++] = LVTokenCreate(i, LVTokenType_RBrace, bmidstr(raw, (int)i, 1)); break;
                
            case '\'': tokens[num_tokens++] = LVTokenCreate(i, LVTokenType_Quote, bmidstr(raw, (int)i, 1)); break;
            case '^': tokens[num_tokens++] = LVTokenCreate(i, LVTokenType_TypeOp, bmidstr(raw, (int)i, 1)); break;
            case '`': tokens[num_tokens++] = LVTokenCreate(i, LVTokenType_SyntaxQuote, bmidstr(raw, (int)i, 1)); break;
                
            case ',': tokens[num_tokens++] = LVTokenCreate(i, LVTokenType_Comma, bmidstr(raw, (int)i, 1)); break;
            case '\n': tokens[num_tokens++] = LVTokenCreate(i, LVTokenType_Newline, bmidstr(raw, (int)i, 1)); break;
                
            case '\t': tokens[num_tokens++] = LVTokenCreate(i, LVTokenType_Newline, bfromcstr("  ")); break;
                
            case '~': {
                if (i + 1 < raw->slen && raw->data[i+1] == '@') {
                    tokens[num_tokens++] = LVTokenCreate(i, LVTokenType_Splice, bmidstr(raw, (int)i, 2));
                    i++;
                }
                else {
                    tokens[num_tokens++] = LVTokenCreate(i, LVTokenType_Unquote, bmidstr(raw, (int)i, 1));
                }
                break;
            }
                
            case ' ': {
                bstring spaces = bfromcstr(" ");
                size_t n = bninchr(raw, (int)i, spaces);
                if (n == BSTR_ERR) n = input_string_length;
                tokens[num_tokens++] = LVTokenCreate(i, LVTokenType_Spaces, bmidstr(raw, (int)i, (int)(n - i)));
                i = n-1;
                break;
            }
                
            case ':': {
                size_t n = binchr(raw, (int)i, endAtomCharSet);
                if (n == BSTR_ERR) n = input_string_length;
                tokens[num_tokens++] = LVTokenCreate(i, LVTokenType_Keyword, bmidstr(raw, (int)i, (int)(n - i)));
                i = n-1;
                break;
            }
                
            case '"': {
                int look_from = (int)i;
                
                do {
                    look_from = bstrchrp(raw, '"', look_from + 1);
                    
                    if (look_from == BSTR_ERR) {
                        printf("error: unclosed string\n");
                        abort();
                    }
                } while (raw->data[look_from - 1] == '\\');
                
                bstring substring = bmidstr(raw, (int)i, (int)(look_from - i + 1));
                LVToken* tok = LVTokenCreate(i, LVTokenType_String, substring);
                tokens[num_tokens++] = tok;
                i = look_from;
                
                break;
            }
                
            case ';': {
                size_t n = bstrchrp(raw, '\n', (int)i);
                
                bstring substring = bmidstr(raw, (int)i, (int)(n - i));
                LVToken* tok = LVTokenCreate(i, LVTokenType_CommentLiteral, substring);
                tokens[num_tokens++] = tok;
                i = n-1;
                
                break;
            }
                
            case '1': case '2': case '3': case '4': case '5': case '6': case '7': case '8': case '9': case '0': {
                size_t n = binchr(raw, (int)i, endAtomCharSet);
                if (n == BSTR_ERR) n = input_string_length;
                tokens[num_tokens++] = LVTokenCreate(i, LVTokenType_Number, bmidstr(raw, (int)i, (int)(n - i)));
                i = n-1;
                break;
            }
                
            case '#': {
                if (i + 1 == raw->slen) {
                    printf("error: unclosed dispatch\n");
                    abort();
                }
                
                char next = raw->data[i + 1];
                
                switch (next) {
                    case '"': {
                        int look_from = (int)i + 2;
                        
                        do {
                            look_from = bstrchrp(raw, '"', look_from + 1);
                            
                            if (look_from == BSTR_ERR) {
                                printf("error: unclosed string\n");
                                abort();
                            }
                        } while (raw->data[look_from - 1] == '\\');
                        
                        bstring substring = bmidstr(raw, (int)i, (int)(look_from - i + 1));
                        LVToken* tok = LVTokenCreate(i, LVTokenType_Regex, substring);
                        tokens[num_tokens++] = tok;
                        i = look_from;
                        
                        break;
                    }
                        
                    case '\'': {
                        size_t n = binchr(raw, (int)i, endAtomCharSet);
                        if (n == BSTR_ERR) n = input_string_length;
                        tokens[num_tokens++] = LVTokenCreate(i, LVTokenType_Var, bmidstr(raw, (int)i, (int)(n - i)));
                        i = n-1;
                        break;
                    }
                        
                    case '(': tokens[num_tokens++] = LVTokenCreate(i, LVTokenType_AnonFnStart, bmidstr(raw, (int)i, 2)); i++; break;
                    case '{': tokens[num_tokens++] = LVTokenCreate(i, LVTokenType_SetStart, bmidstr(raw, (int)i, 2)); i++; break;
                    case '_': tokens[num_tokens++] = LVTokenCreate(i, LVTokenType_ReaderCommentStart, bmidstr(raw, (int)i, 2)); i++; break;
                        
                    default: {
                        size_t n = binchr(raw, (int)i, endAtomCharSet);
                        if (n == BSTR_ERR) n = input_string_length;
                        tokens[num_tokens++] = LVTokenCreate(i, LVTokenType_ReaderMacro, bmidstr(raw, (int)i, (int)(n - i)));
                        i = n-1;
                        break;
                    }
                }
                
                break;
            }
                
            default: {
                size_t n = binchr(raw, (int)i, endAtomCharSet);
                if (n == BSTR_ERR) n = input_string_length;
                
                bstring substring = bmidstr(raw, (int)i, (int)(n - i));
                LVToken* tok = LVTokenCreate(i, LVTokenType_Symbol, substring);
                
                static bstring trueConstant; if (!trueConstant) trueConstant = bfromcstr("true");
                static bstring falseConstant; if (!falseConstant) falseConstant = bfromcstr("false");
                static bstring nilConstant; if (!nilConstant) nilConstant = bfromcstr("nil");
                static bstring defConstant; if (!defConstant) defConstant = bfromcstr("def");
                
                if (biseq(substring, trueConstant)) tok->token_type |= LVTokenType_TrueSymbol;
                if (biseq(substring, falseConstant)) tok->token_type |= LVTokenType_FalseSymbol;
                if (biseq(substring, nilConstant)) tok->token_type |= LVTokenType_NilSymbol;
                
                struct tagbstring def_prefix_substr;
                bmid2tbstr(def_prefix_substr, substring, 0, 3);
                if (biseq(&def_prefix_substr, defConstant)) tok->token_type |= LVTokenType_Deflike;
                
                tokens[num_tokens++] = tok;
                i = n-1;
                
                break;
            }
        }
        
        i++;
        
    }
    
    tokens[num_tokens++] = LVTokenCreate(i, LVTokenType_FileEnd, bfromcstr(""));
    
    *n_tok = num_tokens;
    return tokens;
}
