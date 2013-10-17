//
//  LVTabEntryViewController.m
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVTabController.h"

@interface LVTabController ()

@property (weak) IBOutlet NSSplitView* topLevelSplitView;

@end

@implementation LVTabController

- (NSString*) nibName {
    return @"Tab";
}

- (void) startWithEditor:(LVEditorViewController*)editor {
    [self view]; // force loading view :(
    
    self.title = editor.title;
    // TODO: when editor's title changes, tab's title should change too
    
    [self.topLevelSplitView addSubview: editor.view];
    [self.topLevelSplitView adjustSubviews];
}

@end
