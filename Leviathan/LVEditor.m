//
//  LVEditorViewController.m
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVEditor.h"

#import "LVPreferences.h"

@interface LVEditor ()

@property IBOutlet LVTextView* textView;

@end

@implementation LVEditor

- (NSString*) nibName {
    return @"Editor";
}

- (NSUndoManager *)undoManagerForTextView:(NSTextView *)aTextView {
    return self.file.undoManager;
}

- (void) jumpToDefinition:(LVDefinition*)def {
    size_t absPos = LVGetAbsolutePosition((void*)def.defName);
    self.textView.selectedRange = NSMakeRange(absPos, 0);
    [self.textView scrollRangeToVisible:self.textView.selectedRange];
}

- (void) startEditingFile:(LVFile*)file {
    self.file = file;
    self.title = file.shortName;
    self.textView.file = file;
    
    [[self.textView layoutManager] replaceTextStorage:file.textStorage];
    [[self.textView undoManager] removeAllActions];
    
    [self.textView setSelectedRange:NSMakeRange(0, 0)];
    
    [self.file initialHighlight];
}

- (void) makeFirstResponder {
    [[self.view window] makeFirstResponder: self.textView];
}

- (void) textViewWasFocused:(NSTextView*)view {
    [self.delegate editorWasSelected:self];
}

- (IBAction) saveDocument:(id)sender {
    [self.file save];
}

@end
