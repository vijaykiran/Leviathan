//
//  LVEditorViewController.h
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "LVFile.h"

@interface LVEditor : NSViewController

@property LVFile* file;

+ (LVEditor*) editorForFile:(LVFile*)file;

- (void) makeFirstResponder;

@end
