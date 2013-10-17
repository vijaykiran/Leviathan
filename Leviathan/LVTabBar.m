//
//  LVTabBar.m
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVTabBar.h"

#import <QuartzCore/QuartzCore.h>

#define SD_TAB_WIDTH (140.0)

@interface LVTabBar ()

@property NSMutableArray* tabs;

@property CALayer* draggingTab;
@property CGFloat dragOffset;

@property CALayer* selectedTab;

@end

@implementation LVTabBar

- (id)initWithFrame:(NSRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.tabs = [NSMutableArray array];
        
        self.layer = [CALayer layer];
        self.layer.contentsScale = [[NSScreen mainScreen] backingScaleFactor];
        self.layer.backgroundColor = [NSColor colorWithCalibratedWhite:0.32 alpha:1.0].CGColor;
        [self setWantsLayer:YES];
    }
    return self;
}

- (CALayer*) makeTab:(NSString*)title {
    CALayer* tabLayer = [CALayer layer];
    tabLayer.backgroundColor = [NSColor whiteColor].CGColor;
    tabLayer.contentsScale = self.layer.contentsScale;
    tabLayer.frame = CGRectMake(0, 0, SD_TAB_WIDTH, 30);
    
    CATextLayer* textLayer = [CATextLayer layer];
    
    textLayer.string = title;
    textLayer.fontSize = 14.0;
    textLayer.foregroundColor = [NSColor blackColor].CGColor;
    textLayer.contentsScale = self.layer.contentsScale;
    textLayer.frame = CGRectMake(10, 6, SD_TAB_WIDTH - 10, 18);
    [tabLayer addSublayer:textLayer];
    
    return tabLayer;
}

- (void) selectTabLayer:(CALayer*)tabLayer {
    for (CALayer* tab in self.tabs) {
        tab.backgroundColor = [NSColor colorWithCalibratedWhite:0.52 alpha:1.0].CGColor;
    }
    
    self.selectedTab = tabLayer;
    self.selectedTab.backgroundColor = [NSColor colorWithCalibratedWhite:0.82 alpha:1.0].CGColor;
}

- (void) addTab:(NSString*)title {
    CALayer* tabLayer = [self makeTab:title];
    tabLayer.name = title;
    
    CGRect tabFrame = tabLayer.frame;
    tabFrame.origin.x = [self.tabs count] * (SD_TAB_WIDTH + 1.0);
    tabLayer.frame = tabFrame;
    
    [self.tabs addObject:tabLayer];
    [self.layer addSublayer:tabLayer];
    
    if ([self.tabs count] > 1) {
        CGRect animateFromRect = tabFrame;
        animateFromRect.origin.x -= (SD_TAB_WIDTH + 1.0);
//        animateFromRect.origin.y -= 30.0;
        tabLayer.zPosition = -1;
        tabLayer.frame = animateFromRect;
        
        double delayInSeconds = 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            tabLayer.zPosition = 0;
            tabLayer.frame = tabFrame;
        });
    }
    
    [self selectTabLayer:tabLayer];
}

- (void) closeCurrentTab {
    
}

- (void) mouseDown:(NSEvent *)theEvent {
    NSPoint p = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSUInteger idx = p.x / SD_TAB_WIDTH;
    
    if (idx >= [self.tabs count])
        return;
    
    self.draggingTab = [self.tabs objectAtIndex:idx];
    self.dragOffset = p.x - self.draggingTab.frame.origin.x;
    
    for (CALayer* tab in self.tabs) {
        tab.zPosition = 0;
    }
    
    self.draggingTab.zPosition = 1;
}

- (void) mouseDragged:(NSEvent *)theEvent {
    if (self.draggingTab == nil)
        return;
    
    NSPoint p = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSUInteger idx = p.x / SD_TAB_WIDTH;
    
    if (idx >= [self.tabs count])
        idx = [self.tabs count] - 1;
    
    NSMutableArray* tmpTabs = [self.tabs mutableCopy];
    
    [tmpTabs removeObject:self.draggingTab];
    [tmpTabs insertObject:self.draggingTab atIndex:idx];
    
    int i = 0;
    for (CALayer* tab in tmpTabs) {
        if (tab != self.draggingTab) {
            NSRect r = [tab frame];
            if (r.origin.x != i * (SD_TAB_WIDTH + 1.0)) {
                r.origin.x = i * (SD_TAB_WIDTH + 1.0);
                tab.frame = r;
            }
        }
        i++;
    }
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    NSRect r = self.draggingTab.frame;
    r.origin.x = p.x - self.dragOffset;
    self.draggingTab.frame = r;
    
    [CATransaction commit];
}

- (void) mouseUp:(NSEvent *)theEvent {
    if (self.draggingTab == nil)
        return;
    
    NSPoint p = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSUInteger idx = p.x / SD_TAB_WIDTH;
    
    if (idx >= [self.tabs count])
        idx = [self.tabs count] - 1;
    
    BOOL didntMove = self.draggingTab == [self.tabs objectAtIndex:idx];
    if (self.draggingTab != self.selectedTab && didntMove) {
        [self selectTabLayer:self.draggingTab];
    }
    
    NSMutableArray* tmpTabs = [self.tabs mutableCopy];
    
    [tmpTabs removeObject:self.draggingTab];
    [tmpTabs insertObject:self.draggingTab atIndex:idx];
    
    int i = 0;
    for (CALayer* tab in tmpTabs) {
        NSRect r = [tab frame];
        if (r.origin.x != i * (SD_TAB_WIDTH + 1.0)) {
            r.origin.x = i * (SD_TAB_WIDTH + 1.0);
            tab.frame = r;
        }
        i++;
    }
    
    self.tabs = tmpTabs;
    
    self.draggingTab = nil;
}

@end
