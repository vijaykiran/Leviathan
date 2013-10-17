//
//  LVEditorViewController.m
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVEditor.h"

@interface LVEditor ()

@property IBOutlet NSTextView* textView;

@end

@implementation LVEditor

- (NSString*) nibName {
    return @"Editor";
}

+ (LVEditor*) editorForFile:(LVFile*)file {
    LVEditor* c = [[LVEditor alloc] init];
    c.file = file;
    c.title = @"Untitled";
    // TODO: set title based on file
    return c;
}

- (void) makeFirstResponder {
    [[self.view window] makeFirstResponder: self.textView];
}

@end
