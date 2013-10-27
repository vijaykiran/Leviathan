//
//  LVHighlighter.h
//  Leviathan
//
//  Created by Steven on 10/18/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "coll.h"

@interface LVHighlighter : NSObject

+ (LVHighlighter*) sharedHighlighter;

- (NSDictionary*) attributesForTree:(LVColl*)topLevelColl atPosition:(NSUInteger)absPos effectiveRange:(NSRange*)rangePtr;

@end
