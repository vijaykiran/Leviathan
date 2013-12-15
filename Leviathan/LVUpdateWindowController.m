//
//  LVUpdateWindowController.m
//  Leviathan
//
//  Created by Steven on 12/15/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVUpdateWindowController.h"

@interface LVUpdateWindowController ()

@property NSString* currentVersion;

@end

@implementation LVUpdateWindowController

- (NSString*) windowNibName {
    return @"UpdateWindow";
}

- (void) showWindow:(id)sender {
    NSDisableScreenUpdates();
    [[self window] center];
    [super showWindow:sender];
    NSEnableScreenUpdates();
}

- (void) windowDidLoad {
    [super windowDidLoad];
    self.currentVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
}

- (IBAction) upgrade:(id)sender {
    [self close];
    [self.updateDelegate userWantsUpdate];
}

- (IBAction) later:(id)sender {
    [self close];
    [self.updateDelegate userHatesUs];
}

@end
