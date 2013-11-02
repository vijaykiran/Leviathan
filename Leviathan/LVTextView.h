//
//  LVTextView.h
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "LVClojureTextStorage.h"

@protocol LVTextViewDelegate <NSObject>

- (void) textViewWasFocused:(NSTextView*)view;

@end



@interface LVTextView : NSTextView

@property (weak) IBOutlet id<LVTextViewDelegate> customDelegate;

@property (weak) LVClojureTextStorage* clojureTextStorage;

- (void) indentText;
- (void) stripWhitespace;

@end
