//
//  LVEditorViewController.h
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "LVFile.h"

#import "LVTextView.h"

@class LVEditor;

@protocol LVEditorDelegate <NSObject>

- (void) editorWasSelected:(LVEditor*)editor;

@end

@interface LVEditor : NSViewController <LVTextViewDelegate, NSTextStorageDelegate>

@property LVFile* file;
@property (weak) id<LVEditorDelegate> delegate;
@property IBOutlet LVTextView* textView;

- (void) startEditingFile:(LVFile*)file;

- (void) makeFirstResponder;

- (void) jumpToDefinition:(LVDefinition*)def;

@end
