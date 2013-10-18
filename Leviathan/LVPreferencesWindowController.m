//
//  LVPreferencesWindowController.m
//  Leviathan
//
//  Created by Steven on 10/18/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVPreferencesWindowController.h"

#import "LVPreferences.h"

@interface LVPreferencesWindowController ()

@end

@implementation LVPreferencesWindowController

+ (LVPreferencesWindowController*) sharedPreferencesWindowController {
    static LVPreferencesWindowController* sharedPreferencesWindowController;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPreferencesWindowController = [[LVPreferencesWindowController alloc] init];
    });
    return sharedPreferencesWindowController;
}

- (NSString*) windowNibName {
    return @"PreferencesWindow";
}

- (void) showWindow:(id)sender {
    NSDisableScreenUpdates();
    [super showWindow:sender];
    [[self window] center];
    NSEnableScreenUpdates();
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
