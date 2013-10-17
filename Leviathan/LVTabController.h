//
//  LVTabEntryViewController.h
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "LVEditorViewController.h"

@interface LVTabController : NSViewController

- (void) startWithEditor:(LVEditorViewController*)editor;

- (void) saveFirstResponder;
- (void) restoreFirstResponder;

@end
