//
//  LVKeybindings.m
//  Leviathan
//
//  Created by Steven on 11/5/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVKeybindings.h"

#import "LVPreferences.h"

@implementation LVKeybindings

- (NSURL*) keybindingsFileURL {
    NSURL* settingsDestURL = [[LVPreferences settingsDirectory] URLByAppendingPathComponent:@"Keybindings.clj"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[settingsDestURL path]]) {
        NSURL* origFile = [[NSBundle mainBundle] URLForResource:@"Keybindings" withExtension:@"clj"];
        [[NSFileManager defaultManager] copyItemAtURL:origFile
                                                toURL:settingsDestURL
                                                error:NULL];
    }
    
    return settingsDestURL;
}

@end
