//
//  LVTabBar.m
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVTabBar.h"

#import <QuartzCore/QuartzCore.h>

#define SD_TAB_WIDTH (200.0)

@interface LVTabBar ()

@property NSMutableArray* tabs;

@property CALayer* draggingTab;
@property CGFloat dragOffset;

@property CALayer* selectedTab;

@end

@implementation LVTabBar

- (void) unhighlightTab:(CALayer*)tabLayer {
//    tabLayer.backgroundColor = [NSColor colorWithCalibratedWhite:0.52 alpha:1.0].CGColor;
}

- (void) highlightTab:(CALayer*)tabLayer {
//    tabLayer.backgroundColor = [NSColor colorWithCalibratedWhite:0.72 alpha:1.0].CGColor;
}

- (id)initWithFrame:(NSRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.tabs = [NSMutableArray array];
        
        self.layer = [CALayer layer];
        self.layer.contentsScale = [[NSScreen mainScreen] backingScaleFactor];
        [self setWantsLayer:YES];
    }
    return self;
}

- (CALayer*) makeTabTitleLayer:(CGRect)rect {
    rect = NSInsetRect(rect, 10, 4);
    
    CATextLayer* textLayer = [CATextLayer layer];
    textLayer.frame = rect;
    textLayer.contentsScale = self.layer.contentsScale;
    textLayer.font = (__bridge CGFontRef)[NSFont fontWithName:@"Helvetica Neue" size:13.0];
    textLayer.fontSize = 13.0;
    textLayer.foregroundColor = [NSColor blackColor].CGColor;
    return textLayer;
}

- (CALayer*) makeBorderLayer:(CGRect)rect {
    CALayer* layer = [CALayer layer];
    layer.frame = rect;
    layer.backgroundColor = [NSColor colorWithCalibratedWhite:0.65 alpha:1.0].CGColor;
    return layer;
}

- (CALayer*) makeHighlightLayer:(CGRect)rect {
    rect.size.height -= 1;
    rect = NSInsetRect(rect, 1, 0);
    
    CALayer* layer = [CALayer layer];
    layer.frame = rect;
    layer.backgroundColor = [NSColor colorWithCalibratedWhite:0.99 alpha:1.0].CGColor;
    return layer;
}

- (CALayer*) makeGradientLayer:(CGRect)rect {
    rect.size.height -= 1;
    rect = NSInsetRect(rect, 1, 0);
    
    CAGradientLayer* layer = [CAGradientLayer layer];
    layer.frame = rect;
    layer.colors = @[(id)[NSColor colorWithCalibratedWhite:0.75 alpha:1.0].CGColor,
                     (id)[NSColor colorWithCalibratedWhite:0.95 alpha:1.0].CGColor];
    return layer;
}

- (CALayer*) makeTab {
    CGRect realTabRect = CGRectMake(0, 0, SD_TAB_WIDTH, 25);
    
    CALayer* tab = [CALayer layer];
    tab.contentsScale = self.layer.contentsScale;
    tab.frame = realTabRect;
    
    CALayer* borderLayer = [self makeBorderLayer:realTabRect];
    [tab addSublayer:borderLayer];
    
    CALayer* highlightLayer = [self makeHighlightLayer:borderLayer.bounds];
    [borderLayer addSublayer:highlightLayer];
    
    CALayer* gradientLayer = [self makeGradientLayer:highlightLayer.bounds];
    [highlightLayer addSublayer:gradientLayer];
    
    CALayer* titleLayer = [self makeTabTitleLayer:gradientLayer.bounds];
    [gradientLayer addSublayer:titleLayer];
    
    return tab;
}

- (void) selectTabLayer:(CALayer*)tabLayer {
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    for (CALayer* tab in self.tabs) {
        tab.zPosition = 0;
        [self unhighlightTab:tab];
    }
    
    self.selectedTab.zPosition = 1;
    self.selectedTab = tabLayer;
    [self highlightTab:self.selectedTab];
    
    [CATransaction commit];
}

- (void) addTab:(NSString*)title {
    CALayer* tabLayer = [self makeTab];
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
            tabLayer.zPosition = 1;
            tabLayer.frame = tabFrame;
        });
    }
    
    [self selectTabLayer:tabLayer];
}

- (void) closeCurrentTab {
    NSUInteger newIndex = [self.tabs indexOfObject:self.selectedTab];
    
    [self.selectedTab removeFromSuperlayer];
    [self.tabs removeObject:self.selectedTab]; // TODO: animate this
    
    if (newIndex == [self.tabs count])
        newIndex--;
    
    if ([self.tabs count] == 0)
        return;
    
    [self selectTabLayer:[self.tabs objectAtIndex:newIndex]];
    
    [self repositionTabs];
}

- (void) changeTitles:(NSArray*)titles {
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    for (int i = 0; i < [titles count]; i++) {
        CALayer* tabLayer = [self.tabs objectAtIndex:i];
        NSString* title = [titles objectAtIndex:i];
        CATextLayer* titleLayer = (id)[tabLayer hitTest:CGPointMake(tabLayer.frame.origin.x + 15, tabLayer.frame.origin.y + 10)];
        
        titleLayer.string = title;
    }
    
    [CATransaction commit];
}

- (void) repositionTabs:(NSArray*)tabs {
    int i = 0;
    for (CALayer* tab in tabs) {
        tab.zPosition = (tab == self.selectedTab ? 1 : 0);
        if (tab != self.draggingTab) {
            NSRect r = [tab frame];
            if (r.origin.x != i * (SD_TAB_WIDTH + 1.0)) {
                r.origin.x = i * (SD_TAB_WIDTH + 1.0);
                tab.frame = r;
            }
        }
        i++;
    }
//    self.draggingTab.zPosition = 2;
}

- (void) repositionTabs {
    [self repositionTabs:self.tabs];
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
    
    [self repositionTabs:tmpTabs];
    
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
    BOOL switchingTabs = (self.draggingTab != self.selectedTab && didntMove);
    if (switchingTabs) {
        [self selectTabLayer:self.draggingTab];
    }
    
    NSMutableArray* tmpTabs = [self.tabs mutableCopy];
    
    NSUInteger from = [tmpTabs indexOfObject:self.draggingTab];
    NSUInteger to = idx;
    
    [self.delegate movedTab:from to:to];
    
    [tmpTabs removeObject:self.draggingTab];
    [tmpTabs insertObject:self.draggingTab atIndex:idx];
    
    if (switchingTabs) {
        [self.delegate selectedTab:[tmpTabs indexOfObject:self.selectedTab]];
    }
    
    self.tabs = tmpTabs;
    self.draggingTab = nil;
    
    [self repositionTabs];
}

// tabview-initated actions

- (void) manuallySelectTab:(NSUInteger)tabIndex {
    [self selectTabLayer:[self.tabs objectAtIndex:tabIndex]];
}

- (void) moveTab:(NSUInteger)from to:(NSUInteger)to {
    id tab = [self.tabs objectAtIndex:from];
    
    [self.tabs removeObject:tab];
    [self.tabs insertObject:tab atIndex:to];
    
    [self repositionTabs];
}

@end
