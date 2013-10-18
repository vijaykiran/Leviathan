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
    
    editor.delegate = self;
    
    [self.editorControllers addObject: editor];
    
    [self.topLevelSplitView addSubview: editor.view];
    [self.topLevelSplitView adjustSubviews];
    
    [self switchToEditor:editor];
}

- (void) switchToEditor:(LVEditor*)editor {
    self.currentEditor = editor;
    self.nextResponder = self.currentEditor;
    
    [self.currentEditor makeFirstResponder];
    [self.delegate currentEditorChanged: self];
    
    // TODO: uhh.. do more stuff here?
}

- (void) makeFirstResponder {
    [self.currentEditor makeFirstResponder];
}

- (void) addEditor:(LVEditor*)editor inDirection:(LVSplitDirection)dir {
    editor.delegate = self;
    
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
}

- (void) editorWasSelected:(LVEditor*)editor {
    self.currentEditor = editor;
    [self.delegate currentEditorChanged: self];
}

- (NSRect)splitView:(NSSplitView *)splitView effectiveRect:(NSRect)proposedEffectiveRect forDrawnRect:(NSRect)drawnRect ofDividerAtIndex:(NSInteger)dividerIndex {
    CGFloat r = 6.0;
    
    proposedEffectiveRect.origin.x -= r;
    proposedEffectiveRect.size.width += (r * 2.0);
    return proposedEffectiveRect;
}

@end
