//
//  doc.h
//  Leviathan
//
//  Created by Steven on 10/27/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "coll.h"
#import "token.h"

typedef struct __LVDoc {
    LVColl* topLevelColl;
    
    LVToken** tokens;
    size_t tokens_len;
} LVDoc;

LVDoc* LVDocCreate(const char* raw);
void LVDocDestroy(LVDoc* doc);
