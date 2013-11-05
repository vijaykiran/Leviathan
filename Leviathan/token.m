//
//  token.mm
//  Leviathan
//
//  Created by Steven on 10/21/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "token.h"

#import "storage.h"

LVToken* LVTokenCreate(struct __LVStorage* storage, NSUInteger pos, NSUInteger len, LVTokenType type) {
    LVToken* tok = &(storage->tokens[storage->tokenCount++]);
    tok->tokenType = type;
    tok->string = CFStringCreateWithSubstring(NULL, storage->wholeString, CFRangeMake(pos, len));
    tok->pos = pos;
    return tok;
}
