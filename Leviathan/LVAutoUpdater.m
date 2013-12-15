//
//  LVAutoUpdater.m
//  Leviathan
//
//  Created by Steven on 12/14/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVAutoUpdater.h"

static NSString* LVUpdateURL = @"https://raw.github.com/sdegutis/Leviathan/master/Updates/latest-version.txt";
static NSString* LVUpdateChangesURL = @"https://raw.github.com/sdegutis/Leviathan/master/Updates/changes.txt";

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
    NSDictionary* localVersionTuple = [[NSBundle mainBundle] infoDictionary];
    NSString* localRobot = localVersionTuple[(id)kCFBundleVersionKey];
    
    NSInteger localRobotInt = [localRobot integerValue];
    
    NSString* remoteVersionTuple = [NSString stringWithContentsOfURL:[NSURL URLWithString:LVUpdateURL] encoding:NSUTF8StringEncoding error:NULL];
    NSArray* remoteVersions = [remoteVersionTuple componentsSeparatedByString:@"\n"];
    NSString* remoteHuman = remoteVersions[0];
    NSString* remoteRobot = remoteVersions[1];
    NSInteger remoteRobotInt = [remoteRobot integerValue];
    
    if (remoteRobotInt > localRobotInt) {
        NSString* changes = [NSString stringWithContentsOfURL:[NSURL URLWithString:LVUpdateChangesURL] encoding:NSUTF8StringEncoding error:NULL];
        [self.delegate updateIsAvailable:remoteHuman notes:changes];
    }
}

@end
