//
//  SDElement.h
//  Leviathan
//
//  Created by Steven on 10/12/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
// 

#import <Foundation/Foundation.h>

@class SDColl;
@class SDAtom;

@protocol SDElement <NSObject>

- (BOOL) isColl;
- (BOOL) isAtom;

- (SDColl*) asColl;
- (SDAtom*) asAtom;

@property id<SDElement> parent;
@property NSUInteger idx;

@property NSRange fullyEnclosedRange;

- (void) highlightIn:(NSTextStorage*)attrString atLevel:(int)deepness;

@end
