//
//  token.mm
//  Leviathan
//
//  Created by Steven on 10/21/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "token.h"

#import "doc.h"

LVToken* LVTokenCreate(struct __LVDocStorage* storage, NSUInteger pos, NSUInteger len, LVTokenType type) {
    LVToken* tok = storage->tokens + storage->tokenCount++;
    tok->tokenType = type;
    tok->pos = pos;
    tok->len = len;
    tok->storage = storage;
    return tok;
}

CFStringRef LVStringForToken(LVToken* token) {
    return CFStringCreateWithSubstring(NULL, token->storage->wholeString, CFRangeMake(token->pos, token->len));
}
