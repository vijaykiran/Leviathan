//
//  LVAutoUpdater.m
//  Leviathan
//
//  Created by Steven on 12/14/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVAutoUpdater.h"

static NSString* LVUpdateURL = @"https://raw.github.com/sdegutis/Leviathan/master/Updates/latest-version.txt";

@implementation LVAutoUpdater

- (void) startChecking {
    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:60.0 * 60.0 * 24.0
                                                      target:self
                                                    selector:@selector(checkForUpdate)
                                                    userInfo:nil
                                                     repeats:YES];
    [timer fire];
}

- (void) checkForUpdate {
    NSString* latestVersion = [NSString stringWithContentsOfURL:[NSURL URLWithString:LVUpdateURL] encoding:NSUTF8StringEncoding error:NULL];
    NSLog(@"latest version = %@", latestVersion);
}

@end
