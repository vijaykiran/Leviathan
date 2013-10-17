//
//  LVProjectWindowController.m
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVProjectWindowController.h"

#import "LVTabView.h"
#import "LVTabController.h"
#import "LVEditorViewController.h"

@interface LVProjectWindowController ()

@property (weak) id<LVProjectWindowController> delegate;
@property (weak) IBOutlet LVTabView* tabView;

@end

@implementation LVProjectWindowController

+ (LVProjectWindowController*) openWith:(NSURL*)url delegate:(id<LVProjectWindowController>)delegate {
    LVProjectWindowController* c = [[LVProjectWindowController alloc] init];
    c.project = [LVProject openProjectAtURL:url];
    c.delegate = delegate;
    [c showWindow:nil];
    return c;
}

- (NSString*) windowNibName {
    return @"ProjectWindow";
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self openProjectTab:nil];
}

- (void) windowWillClose:(NSNotification *)notification {
    [self.delegate projectWindowClosed:self];
}

- (IBAction) closeProjectTab:(id)sender {
    
}

- (IBAction) openProjectTab:(id)sender {
    LVFile* file = [self.project openNewFile];
    LVEditorViewController* editorController = [LVEditorViewController editorForFile:file];
    
    LVTabController* tab = [[LVTabController alloc] init];
    [tab startWithEditor: editorController];
    
    [self.tabView addTab:tab];
}

- (IBAction) closeProjectWindow:(id)sender {
    // TODO: check for unsaved files first
    [self close];
}

@end
