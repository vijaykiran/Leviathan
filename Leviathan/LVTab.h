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


@class LVTab;

@protocol LVTabDelegate <NSObject>

- (void) currentEditorChanged:(LVTab*)tab;

@end


@interface LVTab : NSViewController <LVEditorDelegate>

@property id<LVTabDelegate> delegate;

@property (readonly) NSMutableArray* editors; // don't modify this
@property (readonly, weak) LVEditor* currentEditor;

- (void) startWithEditor:(LVEditor*)editor;

- (void) addEditor:(LVEditor*)editor inDirection:(LVSplitDirection)dir;

- (void) makeFirstResponder;

- (void) closeCurrentSplit;

@end
