//
//  LVHighlighter.h
//  Leviathan
//
//  Created by Steven on 10/18/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "doc.h"

@interface LVHighlighter : NSObject

+ (LVHighlighter*) sharedHighlighter;

- (NSDictionary*) attributesForTree:(LVDoc*)doc atPosition:(NSUInteger)absPos effectiveRange:(NSRange*)rangePtr;

@end
