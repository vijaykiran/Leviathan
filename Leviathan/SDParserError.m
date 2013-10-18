//
//  SDParserError.m
//  Leviathan
//
//  Created by Steven on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDParserError.h"

@implementation SDParseError

+ (SDParseError*) kind:(SDParseErrorType)kind with:(NSRange)badRange {
    SDParseError* err = [[SDParseError alloc] init];
    err.badRange = badRange;
    err.errorType = kind;
    return err;
}

@end
