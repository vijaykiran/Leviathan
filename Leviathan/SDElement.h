//
//  SDElement.h
//  Leviathan
//
//  Created by Steven on 10/12/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
// 

#import <Foundation/Foundation.h>

@class LVColl;
@class LVAtom;

@protocol LVElement <NSObject>

- (BOOL) isColl;
- (BOOL) isAtom;

- (LVColl*) asColl;
- (LVAtom*) asAtom;

@property id<LVElement> parent;
@property NSUInteger idx;

@property NSRange fullyEnclosedRange;

- (void) highlightIn:(NSTextStorage*)attrString atLevel:(int)deepness;

@end
