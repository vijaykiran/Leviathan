//
//  SDFuzzyMatcher.m
//  Oxide
//
//  Created by Steven on 7/28/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "SDFuzzyMatcher.h"

#import "SDFuzzyMatcherWindowController.h"
#import "SDChoice.h"

@interface SDFuzzyMatcher ()

@property NSMutableArray* waiters;

@end

@implementation SDFuzzyMatcher

+ (SDFuzzyMatcher*) sharedFuzzyMatcher {
    static SDFuzzyMatcher* sharedFuzzyMatcher;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedFuzzyMatcher = [[SDFuzzyMatcher alloc] init];
        sharedFuzzyMatcher.waiters = [NSMutableArray array];
    });
    return sharedFuzzyMatcher;
}

+ (void) showChoices:(NSArray*)choices
           charsWide:(int)charsWide
           linesTall:(int)linesTall
         windowTitle:(NSString*)windowTitle
       choseCallback:(void(^)(long chosenIndex))choseCallback
{
    NSMutableArray* realChoices = [NSMutableArray array];
    
    for (NSString* choice in choices) {
        [realChoices addObject:[SDChoice choiceWithString:choice]];
    }
    
    SDFuzzyMatcherWindowController* fuzzyMatcherWindowController = [[SDFuzzyMatcherWindowController alloc] init];
    fuzzyMatcherWindowController.choices = [realChoices copy];
    fuzzyMatcherWindowController.choseCallback = choseCallback;
    fuzzyMatcherWindowController.listSize = NSMakeSize(charsWide, linesTall);
    
    SDFuzzyMatcher* matcher = [SDFuzzyMatcher sharedFuzzyMatcher];
    
    [matcher.waiters addObject:fuzzyMatcherWindowController];
    fuzzyMatcherWindowController.killedDelegate = matcher;
    
    fuzzyMatcherWindowController.window.title = windowTitle; // forces the window to load; but meh.
    
    [fuzzyMatcherWindowController positionWindowAndShow];
}

- (void) btwImDead:(id)me {
    [self.waiters removeObject:me];
}

@end
