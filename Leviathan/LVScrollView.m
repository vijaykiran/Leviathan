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

@interface LVScrollView ()

@property NSClipView* myView;

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
    
    NSTextView* box = [self.myView documentView];
    NSRect boxFrame = [aClipView documentRect];
    
    if (boxFrame.size.height != [box frame].size.height) {
        boxFrame.size.width = [self.myView frame].size.width;
        boxFrame.origin.x = 0;
        [box setFrame:boxFrame];
    }
    
    NSRect r = [aClipView documentVisibleRect];
    NSPoint p = NSMakePoint(0, NSMinY(r));
    [self.myView scrollToPoint:p];
}

- (void) awakeFromNib {
    [super awakeFromNib];
    
    NSTextView* box = [[NSTextView alloc] init];
    box.font = [LVPreferences userFont];
    box.backgroundColor = [[LVThemeManager sharedThemeManager].currentTheme.backgroundColor blendedColorWithFraction:0.2 ofColor:[NSColor blackColor]];
    box.textColor = [[LVThemeManager sharedThemeManager].currentTheme.symbol objectForKey:NSForegroundColorAttributeName];
    box.textContainerInset = NSMakeSize(0.0f, 4.0f);
    
    self.myView = [[NSClipView alloc] init];
    self.myView.backgroundColor = [NSColor yellowColor];
    [self.myView setDrawsBackground:YES];
    [self.myView setDocumentView:box];
    [self addSubview:self.myView];
}

- (void) adjustLineNumbers:(NSUInteger)max {
    NSTextView* box = [self.myView documentView];
    
    [box delete:self];
    [box setSelectedRange:NSMakeRange(0, [[box textStorage] length])];
    
    for (int i = 0; i < max; i++) {
        [box insertText:[NSString stringWithFormat:@"%d\n", i + 1]];
    }
}

@end
