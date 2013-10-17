//
//  LVEditorViewController.h
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "LVFile.h"

@interface LVEditorViewController : NSViewController

@property LVFile* file;

+ (LVEditorViewController*) editorForFile:(LVFile*)file;

- (void) makeFirstResponder;

@end
