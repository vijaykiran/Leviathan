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
    
    NSTextView* lineNumberTextView = [self.lineNumberClipView documentView];
    lineNumberFrame.origin = NSZeroPoint;
    [lineNumberTextView setFrame:lineNumberFrame];
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
    [self.lineNumberClipView scrollToPoint:NSMakePoint(0, NSMinY(clojureViewVisibleRect))];
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
    
    NSTextView* lineNumberTextView = [self.lineNumberClipView documentView];
    
    NSUInteger stringLength = [[lineNumberTextView textStorage] length];
    NSUInteger oldCurrentLines = stringLength / 2;
    NSUInteger newCurrentLines = self.currentLineNums;
    
    if (newCurrentLines == oldCurrentLines)
        return;
    
    [[lineNumberTextView textStorage] beginEditing];
    
    if (newCurrentLines > oldCurrentLines) {
        // need more
        NSUInteger difference = newCurrentLines - oldCurrentLines;
        
        for (NSUInteger i = oldCurrentLines; i < newCurrentLines; i++)
            [[[lineNumberTextView textStorage] mutableString] appendFormat:@"%ld\n", i + 1];
        
        NSRange rangeToStyle = NSMakeRange(oldCurrentLines * 2, difference * 2);
        NSDictionary* attrs = [LVThemeManager sharedThemeManager].currentTheme.symbol;
        [[lineNumberTextView textStorage] addAttributes:attrs range:rangeToStyle];
    }
    else if (newCurrentLines < oldCurrentLines) {
        // have too much
        NSUInteger difference = oldCurrentLines - newCurrentLines;
        NSRange rangeToDelete = NSMakeRange(stringLength - (difference * 2), difference * 2);
        [[lineNumberTextView textStorage] deleteCharactersInRange:rangeToDelete];
    }
    
    [[lineNumberTextView textStorage] endEditing];
}

@end
