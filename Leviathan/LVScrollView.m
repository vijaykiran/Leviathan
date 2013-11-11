//
//  LVScrollView.m
//  Leviathan
//
//  Created by Steven on 11/10/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVScrollView.h"

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
    
    NSView* box = [self.myView documentView];
    NSRect boxFrame = [aClipView documentRect];
    boxFrame.size.width = [self.myView frame].size.width;
    boxFrame.origin.x = 0;
    [box setFrame:boxFrame];
    
    NSRect r = [aClipView documentVisibleRect];
    NSPoint p = NSMakePoint(0, NSMaxY(boxFrame) - NSMaxY(r));
    [self.myView scrollToPoint:p];
}

- (void) awakeFromNib {
    [super awakeFromNib];
    
    NSView* box = [[NSBox alloc] init];
    self.myView = [[NSClipView alloc] init];
    [self.myView setDocumentView:box];
    [self addSubview:self.myView];
}

@end
