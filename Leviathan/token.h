//
//  token.h
//  Leviathan
//
//  Created by Steven on 10/21/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#include "bstrlib.h"

typedef enum __LVTokenType : uint64_t {
    LVTokenType_LParen = 1 << 0,
    LVTokenType_RParen = 1 << 1,
    
    LVTokenType_LBracket = 1 << 2,
    LVTokenType_RBracket = 1 << 3,
    
    LVTokenType_LBrace = 1 << 4,
    LVTokenType_RBrace = 1 << 5,
    
    LVTokenType_String =  1 << 6,
    LVTokenType_Keyword = 1 << 7,
    LVTokenType_Symbol =  1 << 8,
    LVTokenType_Number =  1 << 9,
    LVTokenType_Regex =   1 << 10,
    
    LVTokenType_Quote =       1 << 11,
    LVTokenType_Unquote =     1 << 12,
    LVTokenType_SyntaxQuote = 1 << 13,
    LVTokenType_Splice =      1 << 14,
    LVTokenType_TypeOp =      1 << 15,
    
    LVTokenType_ReaderCommentStart = 1 << 16,
    LVTokenType_ReaderMacro        = 1 << 17,
    LVTokenType_AnonFnStart        = 1 << 18,
    LVTokenType_SetStart           = 1 << 19,
    LVTokenType_Var                = 1 << 20,
    
    LVTokenType_Comma   = 1 << 21,
    LVTokenType_Spaces  = 1 << 22,
    LVTokenType_Newline = 1 << 23,
    
    LVTokenType_CommentLiteral = 1 << 24,
    
    LVTokenType_FileBegin = 1 << 25,
    LVTokenType_FileEnd   = 1 << 26,
    
    LVTokenType_TrueSymbol  = 1 << 27, // must also be Symbol
    LVTokenType_FalseSymbol = 1 << 28, // must also be Symbol
    LVTokenType_NilSymbol   = 1 << 29, // must also be Symbol
    
    LVTokenType_Deflike     = 1 << 30, // must also be Symbol
} LVTokenType;


typedef struct __LVToken {
    LVTokenType type;
    bstring val;
} LVToken;


LVToken* LVTokenCreate(LVTokenType type, void* val, int len);
void LVTokenDelete(LVToken* tok); // TODO: use this later
