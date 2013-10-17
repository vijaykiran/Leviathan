//
//  NSString+Score.h
//
//  Created by Nicholas Bruning on 5/12/11.
//  Copyright (c) 2011 Involved Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

// TODO: rewrite this since it kinda sucks, also that way i dont have to figure out who wrote it and do license crap with it

enum{
    NSStringScoreOptionNone                         = 1 << 0,
    NSStringScoreOptionFavorSmallerWords            = 1 << 1,
    NSStringScoreOptionReducedLongStringPenalty     = 1 << 2
};

typedef NSUInteger NSStringScoreOption;

@interface NSString (Score)

- (CGFloat) scoreAgainst:(NSString *)otherString;
- (CGFloat) scoreAgainst:(NSString *)otherString fuzziness:(NSNumber *)fuzziness;
- (CGFloat) scoreAgainst:(NSString *)otherString fuzziness:(NSNumber *)fuzziness options:(NSStringScoreOption)options;

- (CGFloat) scoreAgainst:(NSString *)anotherString fuzziness:(NSNumber *)fuzziness options:(NSStringScoreOption)options
     invalidCharacterSet:(NSCharacterSet *)invalidCharacterSet decomposedString:(NSString *)string;

- (NSString *)decomposedStringWithInvalidCharacterSet:(NSCharacterSet *)invalidCharacterSet;
- (NSCharacterSet *)invalidCharacterSet;

@end
