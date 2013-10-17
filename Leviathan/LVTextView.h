//
//  LVTextView.h
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol LVTextViewDelegate <NSObject>

- (void) textViewWasFocused:(NSTextView*)view;

@end



@interface LVTextView : NSTextView

@property (weak) IBOutlet id<LVTextViewDelegate> customDelegate;

@end
