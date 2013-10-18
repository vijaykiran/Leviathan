//
//  LVParserError.m
//  Leviathan
//
//  Created by Steven on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVParserError.h"

@implementation LVParseError

+ (LVParseError*) kind:(LVParseErrorType)kind with:(NSRange)badRange {
    LVParseError* err = [[LVParseError alloc] init];
    err.badRange = badRange;
    err.errorType = kind;
    return err;
}

@end
