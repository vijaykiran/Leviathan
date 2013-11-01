//
//  coll.h
//  Leviathan
//
//  Created by Steven on 10/20/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "element.h"
#import "token.h"
#import "atom.h"

@interface LVDefinition : NSObject

@property LVAtom* defType;
@property LVAtom* defName;

@end

typedef enum __LVCollType : uint64_t {
    LVCollType_TopLevel   = 1 << 0,
    
    LVCollType_List       = 1 << 1,
    LVCollType_Vector     = 1 << 2,
    LVCollType_Map        = 1 << 3,
    LVCollType_Set        = 1 << 4,
    
    LVCollType_AnonFn     = 1 << 5,
    
    LVCollType_Definition = 1 << 6,
    LVCollType_Ns         = 1 << 7,
} LVCollType;

struct __LVColl;
typedef struct __LVColl LVColl;

struct __LVColl {
    
    BOOL isAtom;
    LVColl* parent;
    
    LVCollType collType;
    
    LVElement** children;
    size_t childrenLen;
    size_t childrenCap;
    
};

LVColl* LVCollCreate();
void LVCollDestroy(LVColl* coll);

void LVElementListAppend(LVColl* coll, LVElement* child);

//LVColl* LVCollHighestParent(LVColl* coll);

size_t LVGetElementIndexInSiblings(LVElement* child);

CFStringRef LVStringForColl(LVColl* coll);

void LVGetSemanticDirectChildren(LVColl* parent, size_t startingPos, LVElement** array, size_t* count);
