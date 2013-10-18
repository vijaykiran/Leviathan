//
//  SDParserError.h
//  Leviathan
//
//  Created by Steven on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum __SDParseErrorType {
    SDParseErrorTypeUnopenedCloser,
    SDParseErrorTypeUnclosedOpener,
    SDParseErrorTypeUnfinishedKeyword,
    SDParseErrorTypeUnfinishedDispatch,
    SDParseErrorTypeUnclosedString,
    SDParseErrorTypeUnclosedRegex,
    SDParseErrorTypeUnexpectedEnd,
} SDParseErrorType;


@interface SDParseError : NSObject

@property NSRange badRange;
@property SDParseErrorType errorType;

+ (SDParseError*) kind:(SDParseErrorType)kind with:(NSRange)badRange;

@end
