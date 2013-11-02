//
//  LVEditorViewController.m
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVEditor.h"

#import "LVPreferences.h"

@implementation LVEditor

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) defaultsFontChanged:(NSNotification*)note {
    [self.file.clojureTextStorage rehighlight];
}

- (NSString*) nibName {
    return @"Editor";
}

- (NSUndoManager *)undoManagerForTextView:(NSTextView *)aTextView {
    return self.file.clojureTextStorage.undoManager;
}

- (void) jumpToDefinition:(LVDefinition*)def {
    NSUInteger absPos = def.defName->token->pos;
    self.textView.selectedRange = NSMakeRange(absPos, CFStringGetLength(def.defName->token->string));
    double delayInSeconds = 0.25;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.textView centerSelectionInVisibleArea:nil];
    });
}

- (void) startEditingFile:(LVFile*)file {
    self.file = file;
    self.title = file.shortName;
    self.textView.clojureTextStorage = file.clojureTextStorage;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultsFontChanged:) name:LVDefaultsFontChangedNotification object:nil];
    
    [[self.textView layoutManager] replaceTextStorage:file.clojureTextStorage];
    [[self.textView undoManager] removeAllActions];
    
    [self.textView setSelectedRange:NSMakeRange(0, 0)];
    
    self.file.clojureTextStorage.delegate = self;
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







//- (void) textStorageDidProcessEditing:(NSNotification *)notification {
//    if ([self.textView.undoManager isUndoing] || [self.textView.undoManager isRedoing])
//        return;
//    
//    [[self.textView undoManager] beginUndoGrouping];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.textView indentText];
//        [[self.textView undoManager] endUndoGrouping];
//    });
//}

@end
