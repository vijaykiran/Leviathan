//
//  SDExpectation.h
//  Beowulf
//
//  Created by Steven Degutis on 9/20/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

@import XCTest;

@interface SDExpectation : NSObject

@property NSString* file;
@property NSUInteger line;
@property id recv;
@property XCTestCase* ctx;

+ (SDExpectation*) expectationFor:(id)recv in:(NSString*)file at:(NSUInteger)line ctx:(XCTestCase*)ctx;
- (void) toEqual:(id)other;
- (void) toNotRaise;

@end

#define expect(x) [SDExpectation expectationFor:x in:[NSString stringWithUTF8String:__FILE__] at:__LINE__ ctx:self]
