//
//  LVUpdateWindowController.h
//  Leviathan
//
//  Created by Steven on 12/15/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol LVUpdateWindowControllerDelegate <NSObject>

- (void) userWantsUpdate;
- (void) userHatesUs;

@end

@interface LVUpdateWindowController : NSWindowController

@property NSString* version;
@property NSString* notes;

@property id<LVUpdateWindowControllerDelegate> updateDelegate;

@end
