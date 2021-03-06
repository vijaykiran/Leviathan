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
#import "LVScrollView.h"

@class LVEditor;

@protocol LVEditorDelegate <NSObject>

- (void) editorWasSelected:(LVEditor*)editor;

@end

@interface LVEditor : NSViewController <LVTextViewDelegate>

@property LVFile* file;
@property (weak) id<LVEditorDelegate> delegate;
@property IBOutlet LVTextView* textView;
@property (weak) IBOutlet LVScrollView* scrollView;

- (void) startEditingFile:(LVFile*)file;

- (void) makeFirstResponder;

- (void) jumpToDefinition:(LVDefinition*)def;

@end
