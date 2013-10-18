//
//  LVHighlighter.h
//  Leviathan
//
//  Created by Steven on 10/18/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LVElement.h"

@interface LVHighlighter : NSObject

+ (void) highlight:(id<LVElement>)element in:(NSTextStorage*)attrString atLevel:(int)deepness;

@end

NSColor* LVColorFromHex(NSString* hex);
void LVApplyStyle(NSMutableAttributedString* attrString, NSString* styleName, NSRange range, NSUInteger deepness);
