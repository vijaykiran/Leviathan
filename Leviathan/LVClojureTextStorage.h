//
//  LVClojureText.h
//  Leviathan
//
//  Created by Steven Degutis on 10/27/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "doc.h"

@interface LVClojureTextStorage : NSTextStorage <NSTextStorageDelegate>

@property NSUndoManager* undoManager;

@property LVDoc* doc;

@property BOOL parsingEnabled;
- (void) parse;

- (void) rehighlight;

@end
