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

NSUInteger LVElementLength(LVElement* el);

struct __LVColl* LVGetTopLevelElement(LVElement* any);

LVElement* LVFindPreviousSemanticElement(LVElement* needle);

BOOL LVElementIsSemantic(LVElement* el);

NSUInteger LVGetAbsolutePosition(LVElement* el);

NSUInteger LVGetElementDepth(LVElement* needle);

CFStringRef LVStringForElement(LVElement* element);
