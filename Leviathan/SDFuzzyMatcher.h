//
//  SDFuzzyMatcher.h
//  Oxide
//
//  Created by Steven on 7/28/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SDFuzzyMatcherWindowController.h"

@interface SDFuzzyMatcher : NSObject <SDKilledDelegate>

+ (void) showChoices:(NSArray*)choices
           charsWide:(int)charsWide
           linesTall:(int)linesTall
         windowTitle:(NSString*)windowTitle
       choseCallback:(void(^)(long chosenIndex))choseCallback;

@end
