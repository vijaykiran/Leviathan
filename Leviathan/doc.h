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

typedef struct __LVDocStorage {
    CFStringRef wholeString;
    
    LVToken* tokens;
    LVAtom* atoms;
    LVColl* colls;
    
    NSUInteger tokenCount;
    NSUInteger atomCount;
    NSUInteger collCount;
} LVDocStorage;

typedef struct __LVDoc {
    LVColl* topLevelColl;
    LVToken* firstToken;
    LVDocStorage storage;
} LVDoc;

LVDoc* LVDocCreate(NSString* raw);
void LVDocDestroy(LVDoc* doc);

void LVFindDefinitions(LVDoc* doc, NSMutableArray* defs);


LVColl* LVFindElementAtPosition(LVDoc* doc, NSUInteger pos, NSUInteger* childIndex);

LVElement* LVFindNextSemanticChildStartingAt(LVDoc* doc, NSUInteger idx);







// new and good

LVAtom* LVFindAtomPrecedingIndex(LVDoc* doc, NSUInteger pos);
LVAtom* LVFindAtomFollowingIndex(LVDoc* doc, NSUInteger pos);
