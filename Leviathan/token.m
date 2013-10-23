//
//  token.mm
//  Leviathan
//
//  Created by Steven on 10/21/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "token.h"

LVToken* LVTokenCreate(LVTokenType type, void* val, int len) {
    LVToken* tok = malloc(sizeof(LVToken));
    tok->type = type;
    tok->val = blk2bstr(val, len);
    return tok;
}

void LVTokenDelete(LVToken* tok) {
    bdestroy(tok->val);
    free(tok);
}
