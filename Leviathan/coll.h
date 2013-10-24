//
//  coll.h
//  Leviathan
//
//  Created by Steven on 10/20/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "element.h"
#import "token.h"

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
    
    BOOL is_atom;
    LVColl* parent;
    size_t index;
    
    LVCollType coll_type;
    LVToken* open_token;
    LVToken* close_token;
    
    LVElement** children;
    size_t children_len;
    size_t children_cap;
    
};

LVColl* LVCollCreate();
void LVCollDestroy(LVColl* coll);

void LVElementListAppend(LVColl* coll, LVElement* child);

LVColl* LVCollHighestParent(LVColl* coll);
LVColl* LVFindDeepestColl(LVColl* coll, size_t start, size_t pos, size_t* childsIndex, size_t* relativePos);

size_t LVCollAbsolutePosition(LVColl* topLevel, LVColl* coll);

bstring LVStringForColl(LVColl* coll);
