//
//  LVTabEntryViewController.h
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "LVEditor.h"

typedef enum __LVSplitDirection {
    LVSplitDirectionEast,
    LVSplitDirectionWest,
    LVSplitDirectionNorth,
    LVSplitDirectionSouth,
} LVSplitDirection;

@interface LVTab : NSViewController <LVEditorDelegate>

@property (readonly, weak) LVEditor* currentEditor;

- (NSArray*) splits;

- (void) startWithEditor:(LVEditor*)editor;

- (void) addEditor:(LVEditor*)editor inDirection:(LVSplitDirection)dir;

- (void) saveFirstResponder;
- (void) restoreFirstResponder;

- (void) closeCurrentSplit;

@end
