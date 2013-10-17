//
//  LVTabEntryViewController.m
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.;
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVTab.h"

@interface LVTab ()

@property (weak) IBOutlet NSSplitView* topLevelSplitView;

@property NSMutableArray* editorControllers;

@property (weak) LVEditor* currentEditor;

@property id savedFirstResponder; // TODO: might cause a leak! cant make weak though, usually is NSTextView

@end

@implementation LVTab

- (id) init {
    if (self = [super init]) {
        self.editorControllers = [NSMutableArray array];
    }
    return self;
}

- (NSString*) nibName {
    return @"Tab";
}

- (void) startWithEditor:(LVEditor*)editor {
    [self view]; // force loading view :(
    
    [self.editorControllers addObject:editor];
    
    [self.topLevelSplitView addSubview: editor.view];
    [self.topLevelSplitView adjustSubviews];
    
    [self switchToEditor:editor];
}

- (void) switchToEditor:(LVEditor*)editor {
    self.currentEditor = editor;
    self.nextResponder = self.currentEditor;
    
    self.title = editor.title;
    // TODO: when editor's title changes, tab's title should change too
    
}

- (void) saveFirstResponder {
    self.savedFirstResponder = [[self.view window] firstResponder];
}

- (void) restoreFirstResponder {
    if (self.savedFirstResponder) {
        [[self.view window] makeFirstResponder:self.savedFirstResponder];
    }
    else {
        [self.currentEditor makeFirstResponder];
    }
}

@end
