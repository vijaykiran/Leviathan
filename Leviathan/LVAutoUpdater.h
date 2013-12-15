//
//  LVAutoUpdater.h
//  Leviathan
//
//  Created by Steven on 12/14/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LVAutoUpdaterDelegate <NSObject>

- (void) updateIsAvailable:(NSString*)notes;

@end

@interface LVAutoUpdater : NSObject

@property id<LVAutoUpdaterDelegate> delegate;

- (void) startChecking;

@end
