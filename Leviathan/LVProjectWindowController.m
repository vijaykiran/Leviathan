//
//  LVProjectWindowController.m
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVProjectWindowController.h"

#import "LVTabView.h"

@interface LVProjectWindowController ()

@property (weak) id<LVProjectWindowController> delegate;
@property (weak) IBOutlet LVTabView* tabView;

@end

@implementation LVProjectWindowController

+ (LVProjectWindowController*) openWith:(NSURL*)url delegate:(id<LVProjectWindowController>)delegate {
    LVProjectWindowController* c = [[LVProjectWindowController alloc] init];
    c.project = [[LVProject alloc] init];
    c.project.projectURL = url;
    c.delegate = delegate;
    [c showWindow:nil];
    return c;
}

- (NSString*) windowNibName {
    return @"ProjectWindow";
}

- (void)windowDidLoad {
    [super windowDidLoad];
}

- (void) windowWillClose:(NSNotification *)notification {
    [self.delegate projectWindowClosed:self];
}

@end
