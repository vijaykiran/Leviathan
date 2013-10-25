//
//  LVHighlighter.h
//  Leviathan
//
//  Created by Steven on 10/18/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "element.h"

void LVHighlight(LVElement* element, NSTextStorage* attrString, NSUInteger startPos);

void LVHighlightSomeChild(LVElement* child, NSTextStorage* attrString, NSUInteger startPos);
