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

- (void) colorize:(CALayer*)tabLayer border:(CGFloat)border highlight:(CGFloat)highlight topGradient:(CGFloat)top bottomGradient:(CGFloat)bottom {
    CAShapeLayer* borderLayer = [[tabLayer sublayers] lastObject];
    borderLayer.fillColor = [NSColor colorWithCalibratedWhite:border alpha:1.0].CGColor;
    
    CAShapeLayer* highlightLayer = [[borderLayer sublayers] lastObject];
    highlightLayer.fillColor = [NSColor colorWithCalibratedWhite:highlight alpha:1.0].CGColor;
    
    CAGradientLayer* gradientLayer = [[highlightLayer sublayers] lastObject];
    gradientLayer.colors = @[(id)[NSColor colorWithCalibratedWhite:bottom alpha:1.0].CGColor,
                             (id)[NSColor colorWithCalibratedWhite:top alpha:1.0].CGColor];
}

- (void) unhighlightTab:(CALayer*)tabLayer {
    [self colorize:tabLayer
            border:0.55
         highlight:0.88
       topGradient:0.85
    bottomGradient:0.65];
}

- (void) highlightTab:(CALayer*)tabLayer {
    [self colorize:tabLayer
            border:0.55
         highlight:0.98
       topGradient:0.95
    bottomGradient:0.75];
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
    rect = NSInsetRect(rect, 18, 4);
    
    CGFloat fontSize = 12.0;
    
    NSFont* font = [NSFont fontWithName:@"Helvetica Neue" size:fontSize];
    font = [[NSFontManager sharedFontManager] convertFont:font toHaveTrait:NSFontBoldTrait];
    
    CATextLayer* textLayer = [CATextLayer layer];
    textLayer.frame = rect;
    textLayer.contentsScale = self.layer.contentsScale;
    textLayer.font = (__bridge CGFontRef)font;
    textLayer.fontSize = fontSize;
    textLayer.foregroundColor = [NSColor colorWithCalibratedWhite:0.15 alpha:1.0].CGColor;
    return textLayer;
}

- (CGPathRef) tabPathForRect:(CGRect)rect {
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathMoveToPoint(path, NULL, NSMinX(rect), NSMinY(rect));
    
#define THREE_X (rect.size.width / 66.66)
#define THREE_Y (rect.size.height / 5.3)
    
#define FIVE_X (rect.size.width / 40.0)
#define FIVE_Y (rect.size.height / 5.0)

#define ELEVEN_X (rect.size.width / 18.18)
#define THIRTEEN_X (rect.size.width / 15.38)
#define SIXTEEN_X (rect.size.width / 12.5)
    
    // bottom-left curve
    CGPathAddQuadCurveToPoint(path, NULL,
                              NSMinX(rect) + THREE_X, NSMinY(rect),
                              NSMinX(rect) + FIVE_X, NSMinY(rect) + FIVE_Y);
    
    // left side
    CGPathAddLineToPoint(path, NULL, NSMinX(rect) + ELEVEN_X, NSMaxY(rect) - THREE_Y);
    
    // top-left curve
    CGPathAddQuadCurveToPoint(path, NULL,
                              NSMinX(rect) + THIRTEEN_X, NSMaxY(rect),
                              NSMinX(rect) + SIXTEEN_X, NSMaxY(rect));
    
    // top side
    CGPathAddLineToPoint(path, NULL, NSMaxX(rect) - SIXTEEN_X, NSMaxY(rect));
    
    // top-right curve
    CGPathAddQuadCurveToPoint(path, NULL,
                              NSMaxX(rect) - THIRTEEN_X, NSMaxY(rect),
                              NSMaxX(rect) - ELEVEN_X, NSMaxY(rect) - THREE_Y);
    
    // right side
    CGPathAddLineToPoint(path, NULL, NSMaxX(rect) - FIVE_X, NSMinY(rect) + FIVE_Y);
    
    // bottom-right curve
    CGPathAddQuadCurveToPoint(path, NULL,
                              NSMaxX(rect) - THREE_X, NSMinY(rect),
                              NSMaxX(rect), NSMinY(rect));
    
    return path;
}

- (CALayer*) makeBorderLayer:(CGRect)rect {
    rect.origin.x += 10;
    
    CAShapeLayer* layer = [CAShapeLayer layer];
    layer.contentsScale = self.layer.contentsScale;
    layer.frame = rect;
    CGPathRef path = [self tabPathForRect:rect];
    layer.path = path;
    CFRelease(path);
    return layer;
}

- (CALayer*) makeHighlightLayer:(CGRect)rect {
    rect.size.height -= 1.0 / self.layer.contentsScale;
    rect.origin.x += 0.5 / self.layer.contentsScale;
    rect.size.width -= 2.0 / self.layer.contentsScale;
    
    CAShapeLayer* layer = [CAShapeLayer layer];
    layer.contentsScale = self.layer.contentsScale;
    layer.frame = rect;
    CGPathRef path = [self tabPathForRect:rect];
    layer.path = path;
    CFRelease(path);
    return layer;
}

- (CALayer*) makeGradientLayer:(CGRect)rect {
    rect.size.height -= 1.0 / self.layer.contentsScale;
    rect.origin.x += 0.5 / self.layer.contentsScale;
    rect.size.width -= 1.0 / self.layer.contentsScale;
    
    CAGradientLayer* layer = [CAGradientLayer layer];
    layer.contentsScale = self.layer.contentsScale;
    layer.frame = rect;
    
    CAShapeLayer* maskLayer = [CAShapeLayer layer];
    maskLayer.contentsScale = self.layer.contentsScale;
    maskLayer.fillColor = [NSColor blackColor].CGColor;
    CGPathRef path = [self tabPathForRect:rect];
    maskLayer.path = path;
    CFRelease(path);
    layer.mask = maskLayer;
    
    return layer;
}

- (CALayer*) makeTab {
    CGRect realTabRect = CGRectMake(0, 0, SD_TAB_WIDTH, 25);
    
    realTabRect = NSInsetRect(realTabRect, -10, 0);
    
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
    
    realTabRect.origin.y += 1.0;
    tab.frame = realTabRect;
    
    return tab;
}

- (void) selectTabLayer:(CALayer*)tabLayer {
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    for (CALayer* tab in self.tabs) {
        tab.zPosition = 0;
        [self unhighlightTab:tab];
    }
    
    self.selectedTab = tabLayer;
    self.selectedTab.zPosition = 1;
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
        
        CALayer* deepest = tabLayer;
        while ([[deepest sublayers] count] > 0)
            deepest = [[deepest sublayers] lastObject];
        
        CATextLayer* titleLayer = (id)deepest;
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
