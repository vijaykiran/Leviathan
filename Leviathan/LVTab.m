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

- (NSArray*) splits {
    return self.editorControllers;
}

- (void) startWithEditor:(LVEditor*)editor {
    [self view]; // force loading view :(
    
    [self.editorControllers addObject: editor];
    
    [self.topLevelSplitView addSubview: editor.view];
    [self.topLevelSplitView adjustSubviews];
    
    [self switchToEditor:editor];
}

- (void) switchToEditor:(LVEditor*)editor {
    self.currentEditor = editor;
    self.nextResponder = self.currentEditor;
    
    self.title = editor.title;
    // TODO: when editor's title changes, tab's title should change too
    
    [self.currentEditor makeFirstResponder];
    
    // TODO: uhh.. more stuff?
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

- (void) addEditor:(LVEditor*)editor inDirection:(LVSplitDirection)dir {
    [self.editorControllers addObject: editor];
    
    [self.topLevelSplitView addSubview: editor.view];
    [self.topLevelSplitView adjustSubviews];
    
    [self switchToEditor:editor];
}

- (IBAction) selectNextSplit:(id)sender {
    NSUInteger idx = [self.editorControllers indexOfObject:self.currentEditor];
    idx++;
    if (idx == [self.editorControllers count])
        idx = 0;
    
    [self switchToEditor:[self.editorControllers objectAtIndex:idx]];
}

- (IBAction) selectPreviousSplit:(id)sender {
    NSUInteger idx = [self.editorControllers indexOfObject:self.currentEditor];
    idx--;
    if (idx == -1)
        idx = [self.editorControllers count] - 1;
    
    [self switchToEditor:[self.editorControllers objectAtIndex:idx]];
}

- (void) closeCurrentSplit {
    [self.currentEditor.view removeFromSuperview];
    [self.editorControllers removeObject:self.currentEditor];
    [self switchToEditor:[self.editorControllers lastObject]];
    [self.currentEditor makeFirstResponder];
    // TODO: this is BROKEN, it sometimes closes the wrong one! because self.currentEditor isn't changed when you MANULLY switch to another one by clicking inside it's textview with the mouse.
}

@end
