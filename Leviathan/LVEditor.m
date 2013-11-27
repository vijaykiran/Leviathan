//
//  LVEditorViewController.m
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVEditor.h"

#import "LVProject.h"

#import "LVProjectWindowController.h"

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
    self.textView.selectedRange = NSMakeRange(absPos, def.defName->token->len);
    [self.textView centerSelectionInVisibleArea:nil];
}

- (void) startEditingFile:(LVFile*)file {
    self.file = file;
    self.title = file.shortName;
    self.textView.clojureTextStorage = file.clojureTextStorage;
    [[self.textView layoutManager] replaceTextStorage:file.clojureTextStorage];
    
    [self.textView setSelectedRange:NSMakeRange(0, 0)];
    
    [self adjustLineNumbers];
}

- (void) makeFirstResponder {
    [[self.view window] makeFirstResponder: self.textView];
}

- (void) textViewWasFocused:(NSTextView*)view {
    [self.delegate editorWasSelected:self];
}

- (IBAction) saveDocument:(id)sender {
    if (!self.file.fileURL) {
        // TODO: save it based on the namespace
        
        NSSavePanel* savePanel = [NSSavePanel savePanel];
        [savePanel setCanCreateDirectories:YES];
        [savePanel setDirectoryURL:self.file.project.projectURL];
        
        [savePanel beginSheetModalForWindow:[self.textView window] completionHandler:^(NSInteger result) {
            if (result == NSFileHandlingPanelOKButton) {
                [self.textView stripWhitespace];
                
                [self.file saveToFileURL: savePanel.URL];
                self.title = self.file.shortName;
                
                [[NSNotificationCenter defaultCenter] postNotificationName:LVTabTitleChangedNotification object:nil];
            }
        }];
        
        return;
    }
    
    [self.textView stripWhitespace];
    [self.file save];
}

- (void)textDidChange:(NSNotification *)aNotification {
    [self adjustLineNumbers];
}

- (void) adjustLineNumbers {
    NSUInteger lineNums = [[[[self.textView textStorage] string] componentsSeparatedByString:@"\n"] count];
    [self.scrollView adjustLineNumbers:lineNums];
}

@end
