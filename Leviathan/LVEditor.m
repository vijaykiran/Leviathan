//
//  LVEditorViewController.m
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVEditor.h"

@interface LVEditor ()

@property IBOutlet LVTextView* textView;

@end

@implementation LVEditor

- (NSString*) nibName {
    return @"Editor";
}

+ (LVEditor*) editorForFile:(LVFile*)file {
    LVEditor* c = [[LVEditor alloc] init];
    c.file = file;
    c.title = file.shortName;
    // TODO: set title based on file
    return c;
}

- (void) makeFirstResponder {
    [[self.view window] makeFirstResponder: self.textView];
}

- (void) textViewWasFocused:(NSTextView*)view {
    [self.delegate editorWasSelected:self];
}

- (void) startEditingOtherFile:(LVFile*)file {
    self.title = file.shortName;
    [[self.textView layoutManager] replaceTextStorage:file.textStorage];
}

@end
