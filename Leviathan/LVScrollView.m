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

@interface LVLineNumbersView : NSView

@property NSString* numbers;

@end

@implementation LVLineNumbersView

- (void) drawRect:(NSRect)dirtyRect {
    [[[NSColor darkGrayColor] colorWithAlphaComponent:0.5] drawSwatchInRect:[self bounds]];
    
    NSDictionary* attrs = [LVThemeManager sharedThemeManager].currentTheme.symbol;
    
    [self.numbers drawAtPoint:NSZeroPoint withAttributes:attrs];
}

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
    
//    LVLineNumbersView* lineNumberTextView = [self.lineNumberClipView documentView];
//    lineNumberFrame.origin = NSZeroPoint;
//    lineNumberFrame.size.height = 200;
//    [lineNumberTextView setFrame:lineNumberFrame];
//    NSLog(@"%@", lineNumberTextView);
    
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
    NSRect clojureViewVisibleRect = [[self contentView] documentVisibleRect];
//    CGFloat y = [self.lineNumberClipView frame].size.height;
    
    CGFloat y = 0 - NSMaxY(clojureViewVisibleRect) + [[self contentView] documentRect].size.height;
    
    [self.lineNumberClipView scrollToPoint:NSMakePoint(0, y)];
}

- (void) awakeFromNib {
    [super awakeFromNib];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultsFontChanged:) name:LVDefaultsFontChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultsThemeChanged:) name:LVCurrentThemeChangedNotification object:nil];
    
    LVLineNumbersView* lineNumberTextView = [[LVLineNumbersView alloc] init];
    
    self.lineNumberClipView = [[NSClipView alloc] init];
    [self.lineNumberClipView setDrawsBackground:YES];
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
    self.lineNumberClipView.backgroundColor = [[LVThemeManager sharedThemeManager].currentTheme.backgroundColor blendedColorWithFraction:0.2 ofColor:[NSColor blackColor]];
    [self adjustLineNumbers];
}

- (void) adjustLineNumbers:(NSUInteger)max {
    if (max == self.currentLineNums)
        return;
    
    self.currentLineNums = max;
    [self adjustLineNumbers];
    
    self.maxDigits = [[NSString stringWithFormat:@"%ld", self.currentLineNums] length];
    [self tile];
}

- (void) adjustLineNumbers {
    if (self.currentLineNums == 0)
        return;
    
    LVLineNumbersView* lineNumberTextView = [self.lineNumberClipView documentView];
    
    NSMutableArray* nums = [NSMutableArray arrayWithCapacity:self.currentLineNums];
    
    for (NSUInteger i = 0; i < self.currentLineNums; i++)
        [nums addObject:@(i+1)];
    
    lineNumberTextView.numbers = [nums componentsJoinedByString:@"\n"];
    
    NSRect f = NSMakeRect(0, 0, 30, self.currentLineNums * 18);
    
    [lineNumberTextView setFrame:f];
    
    [lineNumberTextView setNeedsDisplay:YES];
}

@end
