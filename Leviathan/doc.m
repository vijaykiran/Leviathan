//
//  doc.m
//  Leviathan
//
//  Created by Steven on 10/27/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "doc.h"

#import "lexer.h"
#import "parser.h"

LVDoc* LVDocCreate(const char* raw) {
    LVDoc* doc = malloc(sizeof(LVDoc));
    
    doc->tokens = LVLex(raw, &doc->tokens_len);
    doc->topLevelColl = LVParseTokens(doc->tokens);
    
    return doc;
}

void LVDocDestroy(LVDoc* doc) {
    if (!doc)
        return;
    
    LVCollDestroy(doc->topLevelColl);
    free(doc);
}
