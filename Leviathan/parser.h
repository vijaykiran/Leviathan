//
//  parser.h
//  Leviathan
//
//  Created by Steven on 10/19/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#ifndef __Leviathan__parser__
#define __Leviathan__parser__

#include <iostream>

typedef enum __LVTokenType {
    LV_TOK_LPAREN,
    LV_TOK_RPAREN,
    LV_TOK_LBRACKET,
    LV_TOK_RBRACKET,
    LV_TOK_LBRACE,
    LV_TOK_RBRACE,
    LV_TOK_SYMBOL,
    LV_TOK_NUMBER,
    LV_TOK_STRING,
    LV_TOK_REGEX,
    LV_TOK_QUOTE,
    LV_TOK_SYNTAXQUOTE,
    LV_TOK_UNQUOTE,
    LV_TOK_KEYWORD,
    LV_TOK_SPLICE,
    LV_TOK_TYPEOP,
    LV_TOK_COMMENT,
    LV_TOK_READER_COMMENT,
    LV_TOK_ANON_FN_START,
    LV_TOK_SET_START,
    LV_TOK_VAR_START,
    LV_TOK_READER_MACRO_START,
    LV_TOK_FILE_BEGIN,
    LV_TOK_FILE_END,
} LVTokenType;

namespace leviathan {
    
    class token {
        LVTokenType type;
        std::string val;
    };
    
}

#endif /* defined(__Leviathan__parser__) */



// atom has:
//   - token
//   - atomType

// coll has:
//   - openToken
//   - closeToken
//   - children
//   - collType
