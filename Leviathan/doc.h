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
    CFStringRef string;
    
    LVColl* top_level_coll;
    
    LVToken** tokens;
    size_t tokens_len;
} LVDoc;

LVDoc* LVDocCreate(NSString* raw);
void LVDocDestroy(LVDoc* doc);

void LVFindDefinitions(LVDoc* doc, NSMutableArray* defs);

LVAtom* LVFindAtomFollowingIndex(struct __LVDoc* doc, size_t pos);

LVColl* LVFindElementAtPosition(LVDoc* doc, size_t pos, size_t* childIndex);

LVElement* LVFindNextSemanticChildStartingAt(LVDoc* doc, size_t idx);







// new and good

LVAtom* LVFindAtomPrecedingIndex(LVDoc* doc, NSUInteger pos);
