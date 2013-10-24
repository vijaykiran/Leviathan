//
//  element.h
//  Leviathan
//
//  Created by Steven on 10/20/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

struct __LVColl;

typedef struct __LVElement {
    
    BOOL is_atom;
    struct __LVColl* parent;
    size_t index;
    
} LVElement;

size_t LVElementLength(LVElement* el);
void LVElementDestroy(LVElement* el);
