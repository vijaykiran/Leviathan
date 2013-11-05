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
#import "storage.h"

typedef struct __LVDoc {
    LVColl* topLevelColl;
    LVToken* firstToken;
    LVStorage storage;
} LVDoc;

LVDoc* LVDocCreate(NSString* raw);
void LVDocDestroy(LVDoc* doc);

void LVFindDefinitions(LVDoc* doc, NSMutableArray* defs);

LVAtom* LVFindAtomFollowingIndex(struct __LVDoc* doc, NSUInteger pos);

LVColl* LVFindElementAtPosition(LVDoc* doc, NSUInteger pos, NSUInteger* childIndex);

LVElement* LVFindNextSemanticChildStartingAt(LVDoc* doc, NSUInteger idx);







// new and good

LVAtom* LVFindAtomPrecedingIndex(LVDoc* doc, NSUInteger pos);
