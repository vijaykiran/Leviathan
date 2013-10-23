//
//  element.h
//  Leviathan
//
//  Created by Steven on 10/20/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "coll.h"

typedef enum __LVElementType : uint64_t {
    LVElementType_Atom   = 1 << 0,
    LVElementType_Coll   = 1 << 1,
    LVElementType_Def    = 1 << 2,
} LVElementType;


typedef struct __LVElement {
    
    LVElementType elementType;
    struct __LVColl* parent;
    size_t index;
    
} LVElement;

// TODO: LVElementLength()
