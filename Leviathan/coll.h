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
    TopLevel   = 1 << 0,
    
    List       = 1 << 1,
    Vector     = 1 << 2,
    Map        = 1 << 3,
    
    AnonFn     = 1 << 4,
    
    Definition = 1 << 5,
    Ns         = 1 << 6,
} LVCollType;

struct __LVColl;
typedef struct __LVColl LVColl;

struct __LVColl {
    
    LVElementType elementType;
    LVColl* parent;
    size_t index;
    
    LVCollType collType;
    LVToken* open_token;
    LVToken* close_token;
    void** children;
    
};

LVColl* LVCollCreate();
void LVCollDestroy(LVColl* coll);
