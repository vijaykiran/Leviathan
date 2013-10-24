//
//  LVHighlighter.h
//  Leviathan
//
//  Created by Steven on 10/18/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "element.h"

#import "LVThemeManager.h"

@interface LVHighlighter : NSObject

+ (void) highlight:(LVElement*)element
                in:(NSTextStorage*)attrString
           atLevel:(int)deepness;

@end
