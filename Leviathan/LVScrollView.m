//
//  LVScrollView.m
//  Leviathan
//
//  Created by Steven on 11/10/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVScrollView.h"

#import "LVThemeManager.h"

@interface LVLineNumbersTextView : NSTextView
@end

@implementation LVLineNumbersTextView
- (BOOL) acceptsFirstResponder { return NO; }
@end

@interface LVScrollView ()

@property NSClipView* myView;
@property NSUInteger currentLineNums;

@end

@implementation LVScrollView

- (void) tile {
    [super tile];
    
    NSView* contentView = [self contentView];
    NSRect contentViewFrame = [contentView frame];
    NSRect lineNumberFrame;
    NSDivideRect(contentViewFrame, &lineNumberFrame, &contentViewFrame, 30.0, NSMinXEdge);
    
    [self.myView setFrame:lineNumberFrame];
    [contentView setFrame:contentViewFrame];
}

- (void)reflectScrolledClipView:(NSClipView *)aClipView {
    [super reflectScrolledClipView:aClipView];
    [self updateLineNumberPosition];
}

- (void) updateLineNumberPosition {
    NSTextView* box = [self.myView documentView];
    NSRect boxFrame = [[self contentView] documentRect];
    
    if (boxFrame.size.height != [box frame].size.height) {
        boxFrame.size.width = [self.myView frame].size.width;
        boxFrame.origin.x = 0;
        [box setFrame:boxFrame];
    }
    
    NSRect r = [[self contentView] documentVisibleRect];
    NSPoint p = NSMakePoint(0, NSMinY(r));
    [self.myView scrollToPoint:p];
}

- (void) awakeFromNib {
    [super awakeFromNib];
    
    NSTextView* box = [[LVLineNumbersTextView alloc] init];
    box.editable = NO;
    box.selectable = NO;
    box.backgroundColor = [[LVThemeManager sharedThemeManager].currentTheme.backgroundColor blendedColorWithFraction:0.2 ofColor:[NSColor blackColor]];
    box.textContainerInset = NSMakeSize(0.0f, 4.0f);
    
    self.myView = [[NSClipView alloc] init];
    self.myView.backgroundColor = [NSColor yellowColor];
    [self.myView setDrawsBackground:YES];
    [self.myView setDocumentView:box];
    [self addSubview:self.myView];
}

- (void) adjustLineNumbers:(NSUInteger)max {
    if (max == self.currentLineNums)
        return;
    
    self.currentLineNums = max;
    
    NSTextView* box = [self.myView documentView];
    
    NSDictionary* attrs = [LVThemeManager sharedThemeManager].currentTheme.symbol;
    
    [[box textStorage] beginEditing];
    [[box textStorage] deleteCharactersInRange:NSMakeRange(0, [[box textStorage] length])];
    
    for (int i = 0; i < max; i++) {
        [[[box textStorage] mutableString] appendFormat:@"%d\n", i + 1];
    }
    
    [[box textStorage] addAttributes:attrs range:NSMakeRange(0, [[box textStorage] length])];
    [[box textStorage] endEditing];
}

@end
