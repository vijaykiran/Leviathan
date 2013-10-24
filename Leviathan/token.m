//
//  token.mm
//  Leviathan
//
//  Created by Steven on 10/21/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "token.h"

LVToken* LVTokenCreate(LVTokenType type, bstring val) {
    LVToken* tok = malloc(sizeof(LVToken));
    tok->token_type = type;
    tok->string = val;
    return tok;
}

void LVTokenDelete(LVToken* tok) {
    bdestroy(tok->string);
    free(tok);
}
