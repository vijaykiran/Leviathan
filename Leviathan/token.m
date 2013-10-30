//
//  token.mm
//  Leviathan
//
//  Created by Steven on 10/21/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "token.h"

LVToken* LVTokenCreate(size_t pos, LVTokenType type, CFStringRef val) {
    LVToken* tok = malloc(sizeof(LVToken));
    tok->token_type = type;
    tok->string = val;
    tok->pos = pos;
    return tok;
}

void LVTokenDelete(LVToken* tok) {
    CFRelease(tok->string);
    free(tok);
}
