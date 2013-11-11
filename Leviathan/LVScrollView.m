//
//  LVScrollView.m
//  Leviathan
//
//  Created by Steven on 11/10/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVScrollView.h"

#import "LVPreferences.h"
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

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void) tile {
    [super tile];
    
    NSView* contentView = [self contentView];
    NSRect contentViewFrame = [contentView frame];
    NSRect lineNumberFrame;
    NSDivideRect(contentViewFrame, &lineNumberFrame, &contentViewFrame, 35.0, NSMinXEdge);
    
    [self.myView setFrame:lineNumberFrame];
    [contentView setFrame:contentViewFrame];
    
    NSScroller* scroller = [self horizontalScroller];
    NSRect scrollerFrame = [scroller frame], bla;
    NSDivideRect(scrollerFrame, &bla, &scrollerFrame, 35.0, NSMinXEdge);
    [scroller setFrame:scrollerFrame];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultsFontChanged:) name:LVDefaultsFontChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultsThemeChanged:) name:LVCurrentThemeChangedNotification object:nil];
    
    NSTextView* box = [[LVLineNumbersTextView alloc] init];
    box.editable = NO;
    box.selectable = NO;
    box.textContainerInset = NSMakeSize(0.0f, 4.0f);
    
    self.myView = [[NSClipView alloc] init];
    self.myView.backgroundColor = [NSColor yellowColor];
    [self.myView setDrawsBackground:YES];
    [self.myView setDocumentView:box];
    [self addSubview:self.myView];
    
    [self setupUserDefinedProperties];
}

- (void) defaultsFontChanged:(NSNotification*)note {
    [self setupUserDefinedProperties];
}

- (void) defaultsThemeChanged:(NSNotification*)note {
    [self setupUserDefinedProperties];
}

- (void) setupUserDefinedProperties {
    NSTextView* box = [self.myView documentView];
    box.backgroundColor = [[LVThemeManager sharedThemeManager].currentTheme.backgroundColor blendedColorWithFraction:0.2 ofColor:[NSColor blackColor]];
    [self forceAdjustLineNumbers];
}

- (void) adjustLineNumbers:(NSUInteger)max {
    if (max == self.currentLineNums)
        return;
    
    self.currentLineNums = max;
    [self forceAdjustLineNumbers];
}

- (void) forceAdjustLineNumbers {
    NSTextView* box = [self.myView documentView];
    
    NSDictionary* attrs = [LVThemeManager sharedThemeManager].currentTheme.symbol;
    
    [[box textStorage] beginEditing];
    [[box textStorage] deleteCharactersInRange:NSMakeRange(0, [[box textStorage] length])];
    
    for (int i = 0; i < self.currentLineNums; i++)
        [[[box textStorage] mutableString] appendFormat:@"%d\n", i + 1];
    
    [[box textStorage] addAttributes:attrs range:NSMakeRange(0, [[box textStorage] length])];
    [[box textStorage] endEditing];
}

@end
