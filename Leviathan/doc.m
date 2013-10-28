//
//  doc.m
//  Leviathan
//
//  Created by Steven on 10/27/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "doc.h"

#import "parser.h"

LVDoc* LVDocCreate(const char* raw) {
    LVDoc* doc = malloc(sizeof(LVDoc));
    doc->topLevelColl = LVParse(raw);
    return doc;
}

void LVDocDestroy(LVDoc* doc) {
    if (!doc)
        return;
    
    LVCollDestroy(doc->topLevelColl);
    free(doc);
}
