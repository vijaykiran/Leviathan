//
//  SDChoice.m
//  Oxide
//
//  Created by Steven on 7/28/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "SDChoice.h"

#import "NSString+Score.h"

@interface SDChoice ()

@property NSString* actualString;
@property NSCharacterSet* invalidSet;
@property NSString* decomposed;
@property NSNumber* fuzziness;
@property CGFloat score;

@end

@implementation SDChoice

+ (SDChoice*) choiceWithString:(NSString*)actualString {
    SDChoice* choice = [[SDChoice alloc] init];
    choice.actualString = actualString;
    choice.invalidSet = [choice.actualString invalidCharacterSet];
    choice.decomposed = [choice.actualString decomposedStringWithInvalidCharacterSet:choice.invalidSet];
    choice.fuzziness = @0.8;
    return choice;
}

- (void) updateScore {
    NSStringScoreOption opts = NSStringScoreOptionFavorSmallerWords & NSStringScoreOptionReducedLongStringPenalty;
//    NSStringScoreOption opts = NSStringScoreOptionReducedLongStringPenalty;
//    NSStringScoreOption opts = NSStringScoreOptionFavorSmallerWords;
    
    self.score = [self.actualString scoreAgainst:self.tryString
                                       fuzziness:self.fuzziness
                                         options:opts
                             invalidCharacterSet:self.invalidSet
                                decomposedString:self.decomposed];
}

@end
