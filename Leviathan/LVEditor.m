//
//  LVEditorViewController.m
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVEditor.h"

@implementation LVEditor

//- (void) dealloc {
//    NSLog(@"editor dealloced for %@", self.file.shortName);
//}

- (NSString*) nibName {
    return @"Editor";
}

- (NSUndoManager *)undoManagerForTextView:(NSTextView *)aTextView {
    return self.file.clojureTextStorage.undoManager;
}

- (void) jumpToDefinition:(LVDefinition*)def {
    NSUInteger absPos = def.defName->token->pos;
    self.textView.selectedRange = NSMakeRange(absPos, CFStringGetLength(def.defName->token->string));
    [self.textView centerSelectionInVisibleArea:nil];
}

- (void) startEditingFile:(LVFile*)file {
    self.file = file;
    self.title = file.shortName;
    self.textView.clojureTextStorage = file.clojureTextStorage;
    [[self.textView layoutManager] replaceTextStorage:file.clojureTextStorage];
    
    [self.textView setSelectedRange:NSMakeRange(0, 0)];
}

- (void) makeFirstResponder {
    [[self.view window] makeFirstResponder: self.textView];
}

- (void) textViewWasFocused:(NSTextView*)view {
    [self.delegate editorWasSelected:self];
}

- (IBAction) saveDocument:(id)sender {
    [self.textView stripWhitespace];
    [self.file save];
}

@end
