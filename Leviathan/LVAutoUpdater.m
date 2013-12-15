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
static NSString* LVNewAppURL = @"https://github.com/sdegutis/Leviathan/raw/master/Builds/Leviathan-LATEST.app.tar.gz";

@implementation LVAutoUpdater

- (void) startChecking {
    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:60.0 * 60.0 * 24.0
                                                      target:self
                                                    selector:@selector(checkForUpdate)
                                                    userInfo:nil
                                                     repeats:YES];
    [timer fire];
}

- (NSString*) stringAtURL:(NSString*)urlString {
    NSURLResponse* __autoreleasing response;
    NSData* data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]] returningResponse:&response error:NULL];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

- (void) checkForUpdate {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSDictionary* localVersionTuple = [[NSBundle mainBundle] infoDictionary];
        NSString* localRobot = localVersionTuple[(id)kCFBundleVersionKey];
        
        NSInteger localRobotInt = [localRobot integerValue];
        
        NSString* remoteVersionTuple = [self stringAtURL: LVUpdateURL];
        NSArray* remoteVersions = [remoteVersionTuple componentsSeparatedByString:@"\n"];
        NSString* remoteHuman = remoteVersions[0];
        NSString* remoteRobot = remoteVersions[1];
        NSInteger remoteRobotInt = [remoteRobot integerValue];
        
        if (remoteRobotInt > localRobotInt) {
            NSString* changes = [self stringAtURL:LVUpdateChangesURL];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.delegate updateIsAvailable:remoteHuman notes:changes];
            });
        }
    });
}

- (void) updateApp {
    NSString* tempFile = @"/tmp/leviathan.tar.gz";
    NSString* destParentDir = [[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent];
    
    NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:LVNewAppURL]];
    [data writeToFile:tempFile atomically:YES];
    
    NSString* horribleShellCommand = [NSString stringWithFormat:@"tar -zxf %@ -C %@; sleep 0.5; open -a Leviathan", tempFile, destParentDir];
    
	NSTask *task = [[NSTask alloc] init];
	[task setLaunchPath:@"/bin/sh"];
	[task setArguments: @[@"-c", horribleShellCommand]];
	[task launch];
    
    exit(0);
}

@end
