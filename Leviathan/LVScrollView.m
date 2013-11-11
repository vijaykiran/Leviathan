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

@property NSClipView* lineNumberClipView;
@property NSUInteger currentLineNums;
@property NSUInteger maxDigits;

@end

@implementation LVScrollView

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) tile {
    [super tile];
    
//    if (self.maxDigits < 1)
//        self.maxDigits = 1;
    
    NSFont* font = [LVPreferences userFont];
    CGFloat width = [font boundingRectForFont].size.width;
    CGFloat fullWidth = self.maxDigits * width;
//    CGFloat fullWidth = 35.0;
    
    NSView* contentView = [self contentView];
    NSRect contentViewFrame = [contentView frame];
    NSRect lineNumberFrame;
    NSDivideRect(contentViewFrame, &lineNumberFrame, &contentViewFrame, fullWidth, NSMinXEdge);
    
    [self.lineNumberClipView setFrame:lineNumberFrame];
    [contentView setFrame:contentViewFrame];
    
    NSScroller* scroller = [self horizontalScroller];
    NSRect scrollerFrame = [scroller frame], bla;
    NSDivideRect(scrollerFrame, &bla, &scrollerFrame, fullWidth, NSMinXEdge);
    [scroller setFrame:scrollerFrame];
}

- (void)reflectScrolledClipView:(NSClipView *)aClipView {
    [super reflectScrolledClipView:aClipView];
    
//    if (aClipView == [self contentView])
        [self updateLineNumberPosition];
}

- (void) updateLineNumberPosition {
    NSTextView* lineNumberTextView = [self.lineNumberClipView documentView];
    NSRect clojureTextViewFrame = [[self contentView] documentRect];
    
    if ([lineNumberTextView frame].size.height != clojureTextViewFrame.size.height) {
        NSRect lineNumberTextViewFrame = clojureTextViewFrame;
        lineNumberTextViewFrame.size.width = [self.lineNumberClipView frame].size.width;
        lineNumberTextViewFrame.origin.x = 0;
        [lineNumberTextView setFrame:lineNumberTextViewFrame];
    }
    
    NSRect r = [[self contentView] documentVisibleRect];
    NSPoint p = NSMakePoint(0, NSMinY(r));
    [self.lineNumberClipView scrollToPoint:p];
}

- (void) awakeFromNib {
    [super awakeFromNib];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultsFontChanged:) name:LVDefaultsFontChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultsThemeChanged:) name:LVCurrentThemeChangedNotification object:nil];
    
    NSTextView* lineNumberTextView = [[LVLineNumbersTextView alloc] init];
    [lineNumberTextView setEditable:NO];
    [lineNumberTextView setSelectable:NO];
    [lineNumberTextView setTextContainerInset:NSMakeSize(0.0f, 4.0f)];
//    [lineNumberTextView setAlignment:NSRightTextAlignment];
    
    self.lineNumberClipView = [[NSClipView alloc] init];
    [self.lineNumberClipView setDrawsBackground:NO];
    [self.lineNumberClipView setDocumentView:lineNumberTextView];
    [self addSubview:self.lineNumberClipView];
    
    [self setupUserDefinedProperties];
}

- (void) defaultsFontChanged:(NSNotification*)note {
    [self setupUserDefinedProperties];
}

- (void) defaultsThemeChanged:(NSNotification*)note {
    [self setupUserDefinedProperties];
}

- (void) setupUserDefinedProperties {
    NSTextView* lineNumberTextView = [self.lineNumberClipView documentView];
    lineNumberTextView.backgroundColor = [[LVThemeManager sharedThemeManager].currentTheme.backgroundColor blendedColorWithFraction:0.2 ofColor:[NSColor blackColor]];
    [self forceAdjustLineNumbers];
}

- (void) adjustLineNumbers:(NSUInteger)max {
    if (max == self.currentLineNums)
        return;
    
    self.currentLineNums = max;
    [self forceAdjustLineNumbers];
    
    self.maxDigits = [[NSString stringWithFormat:@"%ld", self.currentLineNums] length];
    [self tile];
}

- (void) forceAdjustLineNumbers {
    if (self.currentLineNums == 0)
        return;
    
    NSTextView* lineNumberTextView = [self.lineNumberClipView documentView];
    
    NSDictionary* attrs = [LVThemeManager sharedThemeManager].currentTheme.symbol;
    
    [[lineNumberTextView textStorage] beginEditing];
    [[lineNumberTextView textStorage] deleteCharactersInRange:NSMakeRange(0, [[lineNumberTextView textStorage] length])];
    
    for (int i = 0; i < self.currentLineNums; i++)
        [[[lineNumberTextView textStorage] mutableString] appendFormat:@"%d\n", i + 1];
    
    [[lineNumberTextView textStorage] addAttributes:attrs range:NSMakeRange(0, [[lineNumberTextView textStorage] length])];
    [[lineNumberTextView textStorage] endEditing];
}

@end
