//
//  element.h
//  Leviathan
//
//  Created by Steven on 10/20/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "bstrlib.h"

struct __LVColl;

typedef struct __LVElement {
    
    BOOL is_atom;
    struct __LVColl* parent;
    
} LVElement;

size_t LVElementLength(LVElement* el);
void LVElementDestroy(LVElement* el);

struct __LVColl* LVGetTopLevelElement(LVElement* any);
size_t LVGetAbsolutePosition(LVElement* needle);

size_t LVGetElementDepth(LVElement* needle);

bstring LVStringForElement(LVElement* element);
