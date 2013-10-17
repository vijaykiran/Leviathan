//
//  SDFuzzyMatcherWindowController.h
//  Oxide
//
//  Created by Steven on 7/28/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol SDKilledDelegate <NSObject>

- (void) btwImDead:(id)me;

@end

@interface SDFuzzyMatcherWindowController : NSWindowController <NSWindowDelegate, NSTextFieldDelegate>

@property NSArray* choices;
@property NSSize listSize;
@property (copy) void(^choseCallback)(long chosenIndex);

@property id<SDKilledDelegate>killedDelegate;

- (void) positionWindowAndShow;

@end
