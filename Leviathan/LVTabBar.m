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
    tabLayer.backgroundColor = [NSColor colorWithCalibratedWhite:0.52 alpha:1.0].CGColor;
}

- (void) highlightTab:(CALayer*)tabLayer {
    tabLayer.backgroundColor = [NSColor colorWithCalibratedWhite:0.82 alpha:1.0].CGColor;
}

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
    CGRect realTabRect = CGRectMake(0, 0, SD_TAB_WIDTH, 25);
    
    CALayer* tabLayer = [CALayer layer];
    tabLayer.backgroundColor = [NSColor whiteColor].CGColor;
    tabLayer.contentsScale = self.layer.contentsScale;
    tabLayer.frame = realTabRect;
    
    CATextLayer* textLayer = [CATextLayer layer];
    
    NSFont* font = [NSFont fontWithName:@"Helvetica Neue" size:13.0];
//    font = [[NSFontManager sharedFontManager] convertFont:font toHaveTrait:NSFontBoldTrait];
    
    textLayer.string = title;
    textLayer.font = (__bridge CGFontRef)font;
    textLayer.fontSize = 14.0;
    textLayer.foregroundColor = [NSColor blackColor].CGColor;
    textLayer.contentsScale = self.layer.contentsScale;
    textLayer.frame = NSInsetRect(realTabRect, 10, 4);
    [tabLayer addSublayer:textLayer];
    
    return tabLayer;
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
        CATextLayer* titleLayer = [[tabLayer sublayers] lastObject];
        
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
