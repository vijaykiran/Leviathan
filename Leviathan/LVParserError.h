//
//  LVParserError.h
//  Leviathan
//
//  Created by Steven on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum __LVParseErrorType {
    LVParseErrorTypeUnopenedCloser,
    LVParseErrorTypeUnclosedOpener,
    LVParseErrorTypeUnfinishedKeyword,
    LVParseErrorTypeUnfinishedDispatch,
    LVParseErrorTypeUnclosedString,
    LVParseErrorTypeUnclosedRegex,
    LVParseErrorTypeUnexpectedEnd,
} LVParseErrorType;


@interface LVParseError : NSObject

@property NSRange badRange;
@property LVParseErrorType errorType;

+ (LVParseError*) kind:(LVParseErrorType)kind with:(NSRange)badRange;

@end
