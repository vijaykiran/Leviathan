//
//  element.h
//  Leviathan
//
//  Created by Steven on 10/20/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>

struct __LVColl;

typedef struct __LVElement {
    
    BOOL isAtom;
    struct __LVColl* parent;
    
} LVElement;

size_t LVElementLength(LVElement* el);
void LVElementDestroy(LVElement* el);

struct __LVColl* LVGetTopLevelElement(LVElement* any);

LVElement* LVFindPreviousSemanticElement(LVElement* needle);

BOOL LVElementIsSemantic(LVElement* el);

size_t LVGetAbsolutePosition(LVElement* el);

size_t LVGetElementDepth(LVElement* needle);

CFStringRef LVStringForElement(LVElement* element);
