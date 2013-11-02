//
//  token.mm
//  Leviathan
//
//  Created by Steven on 10/21/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "token.h"

LVToken* LVTokenCreate(NSUInteger pos, LVTokenType type, CFStringRef val) {
    LVToken* tok = malloc(sizeof(LVToken));
    tok->tokenType = type;
    tok->string = val;
    tok->pos = pos;
    return tok;
}

void LVTokenDelete(LVToken* tok) {
    CFRelease(tok->string);
    free(tok);
}
