//
//  LVTabBar.m
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVTabBar.h"

#import <QuartzCore/QuartzCore.h>

#define SD_TAB_WIDTH (150.0)

@interface LVTabBar ()

@property NSMutableArray* tabs;

@property CALayer* draggingTab;
@property CGFloat dragOffset;

@property CGPoint dragWindowOffset;
@property CGPoint dragWindowPosition;

@property CALayer* selectedTab;

@property BOOL dimmed;

@end

@implementation LVTabBar

- (void) colorize:(CALayer*)tabLayer border:(CGFloat)border highlight:(CGFloat)highlight topGradient:(CGFloat)top bottomGradient:(CGFloat)bottom text:(CGFloat)text {
    NSColor* borderColor = [NSColor colorWithCalibratedWhite:border alpha:1.0];
    NSColor* highlightColor = [NSColor colorWithCalibratedWhite:highlight alpha:1.0];
    NSColor* topColor = [NSColor colorWithCalibratedWhite:top alpha:1.0];
    NSColor* bottomColor = [NSColor colorWithCalibratedWhite:bottom alpha:1.0];
    NSColor* textColor = [NSColor colorWithCalibratedWhite:text alpha:1.0];
    
    if (self.dimmed) {
        CGFloat percent = 0.4;
        NSColor* blender = [NSColor whiteColor];
        borderColor = [borderColor blendedColorWithFraction:percent ofColor:blender];
        highlightColor = [highlightColor blendedColorWithFraction:percent ofColor:blender];
        topColor = [topColor blendedColorWithFraction:percent ofColor:blender];
        bottomColor = [bottomColor blendedColorWithFraction:percent ofColor:blender];
        textColor = [textColor blendedColorWithFraction:percent ofColor:blender];
    }
    
    CAShapeLayer* borderLayer = [[tabLayer sublayers] lastObject];
    borderLayer.fillColor = borderColor.CGColor;
    
    CAShapeLayer* highlightLayer = [[borderLayer sublayers] lastObject];
    highlightLayer.fillColor = highlightColor.CGColor;
    
    CAGradientLayer* gradientLayer = [[highlightLayer sublayers] lastObject];
    gradientLayer.colors = @[(id)bottomColor.CGColor,
                             (id)topColor.CGColor];
    
    CATextLayer* textLayer = [[gradientLayer sublayers] lastObject];
    textLayer.foregroundColor = textColor.CGColor;
    textLayer.shadowColor = highlightColor.CGColor;
}

- (void) unhighlightTab:(CALayer*)tabLayer {
    [self colorize:tabLayer
            border:0.55
         highlight:0.88
       topGradient:0.85
    bottomGradient:0.65
              text:0.30];
}

- (void) highlightTab:(CALayer*)tabLayer {
    [self colorize:tabLayer
            border:0.55
         highlight:0.98
       topGradient:0.95
    bottomGradient:0.75
              text:0.20];
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

- (void) restyleAllTabs {
    [CATransaction begin];
    [CATransaction setValue:@YES forKey:kCATransactionDisableActions];
    
    for (CALayer* tab in self.tabs) {
        if (tab == self.selectedTab)
            [self highlightTab:tab];
        else
            [self unhighlightTab:tab];
    }
    
    [CATransaction commit];
}

- (void) dim {
    self.dimmed = YES;
    [self restyleAllTabs];
}

- (void) undim {
    self.dimmed = NO;
    [self restyleAllTabs];
}

- (CALayer*) makeTabTitleLayer:(CGRect)rect {
    rect = NSInsetRect(rect, 15, 4);
    
    CGFloat fontSize = 12.0;
    
    NSFont* font = [NSFont fontWithName:@"Helvetica Neue" size:fontSize];
    font = [[NSFontManager sharedFontManager] convertFont:font toHaveTrait:NSFontBoldTrait];
    
    CATextLayer* textLayer = [CATextLayer layer];
    textLayer.frame = rect;
    textLayer.contentsScale = self.layer.contentsScale;
    textLayer.font = (__bridge CGFontRef)font;
    textLayer.fontSize = fontSize;
    textLayer.foregroundColor = [NSColor colorWithCalibratedWhite:0.20 alpha:1.0].CGColor;
    textLayer.shadowColor = [NSColor colorWithCalibratedWhite:0.85 alpha:1.0].CGColor;
    textLayer.shadowOffset = CGSizeMake(0, -1);
    textLayer.shadowOpacity = 1.0;
    textLayer.shadowRadius = 0.0;
    return textLayer;
}

- (CGPathRef) tabPathForRect:(CGRect)rect {
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGFloat X_TOP_BEFORE_CURVE = (7.0);
    CGFloat Y_TOP_BEFORE_CURVE = (5.0);
    CGFloat X_TOP_CONTROL_POINT = (X_TOP_BEFORE_CURVE + 2.0);
    CGFloat Y_TOP_CONTROL_POINT = (0.0);
    CGFloat X_TOP_AFTER_CURVE = (X_TOP_CONTROL_POINT + 3.0);
    
    CGPathMoveToPoint(path, NULL, NSMinX(rect), NSMinY(rect));
    
    // left side
    CGPathAddLineToPoint(path, NULL, NSMinX(rect) + X_TOP_BEFORE_CURVE, NSMaxY(rect) - Y_TOP_BEFORE_CURVE);
    
    // top-left curve
    CGPathAddQuadCurveToPoint(path, NULL,
                              NSMinX(rect) + X_TOP_CONTROL_POINT, NSMaxY(rect) - Y_TOP_CONTROL_POINT,
                              NSMinX(rect) + X_TOP_AFTER_CURVE, NSMaxY(rect));
    
    // top side
    CGPathAddLineToPoint(path, NULL, NSMaxX(rect) - X_TOP_AFTER_CURVE, NSMaxY(rect));
    
    // top-right curve
    CGPathAddQuadCurveToPoint(path, NULL,
                              NSMaxX(rect) - X_TOP_CONTROL_POINT, NSMaxY(rect) - Y_TOP_CONTROL_POINT,
                              NSMaxX(rect) - X_TOP_BEFORE_CURVE, NSMaxY(rect) - Y_TOP_BEFORE_CURVE);
    
    // right side
    CGPathAddLineToPoint(path, NULL, NSMaxX(rect), NSMinY(rect));
    
    return path;
}

#define SD_TAP_OVERLAP (6.0)

- (CALayer*) makeBorderLayer:(CGRect)rect {
    rect.origin.x += SD_TAP_OVERLAP;
    
    CAShapeLayer* layer = [CAShapeLayer layer];
    layer.contentsScale = self.layer.contentsScale;
    layer.frame = rect;
    CGPathRef path = [self tabPathForRect:rect];
    layer.path = path;
    CFRelease(path);
    return layer;
}

- (CALayer*) makeHighlightLayer:(CGRect)rect {
    rect.size.height -= 1.0;
    rect.origin.x += 0.5;
    rect.size.width -= 2.0;
    
    CAShapeLayer* layer = [CAShapeLayer layer];
    layer.contentsScale = self.layer.contentsScale;
    layer.frame = rect;
    CGPathRef path = [self tabPathForRect:rect];
    layer.path = path;
    CFRelease(path);
    return layer;
}

- (CALayer*) makeGradientLayer:(CGRect)rect {
    rect.size.height -= 1.0;
    rect.origin.x += 0.5;
    rect.size.width -= 1.0;
    
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
    
    realTabRect = NSInsetRect(realTabRect, -SD_TAP_OVERLAP, 0);
    
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
    tabLayer.zPosition = 1;
    tabLayer.frame = tabFrame;
    
    [CATransaction begin];
    [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    
    [self.tabs addObject:tabLayer];
    [self.layer addSublayer:tabLayer];
    
    [CATransaction commit];
    
    if ([self.tabs count] > 1) {
        CGPoint animatedFromPosition = tabLayer.position;
        animatedFromPosition.x -= (SD_TAB_WIDTH + 1.0);
        
        CAAnimationGroup* animationGroup = [CAAnimationGroup animation];
        
        CABasicAnimation* positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        positionAnimation.fromValue = [NSValue valueWithPoint:animatedFromPosition];
        positionAnimation.toValue = [NSValue valueWithPoint:tabLayer.position];
        
        CABasicAnimation* zPosAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        zPosAnimation.fromValue = @0.0;
        zPosAnimation.toValue = @(tabLayer.opacity);
        
        animationGroup.animations = @[positionAnimation, zPosAnimation];
        animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        animationGroup.duration = 0.1;
        [tabLayer addAnimation:animationGroup forKey:@"newtab"];
    }
    
    [self selectTabLayer:tabLayer];
}

- (void) closeCurrentTab {
    [CATransaction begin];
    
    CGPoint animatedToPosition = self.selectedTab.position;
    animatedToPosition.y -= 25.0;
    
    CAAnimationGroup* animationGroup = [CAAnimationGroup animation];
    
    CABasicAnimation* positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    positionAnimation.fromValue = [NSValue valueWithPoint:self.selectedTab.position];
    positionAnimation.toValue = [NSValue valueWithPoint:animatedToPosition];
    
    animationGroup.animations = @[positionAnimation];
    animationGroup.duration = 0.1;
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animationGroup.delegate = self;
    [self.selectedTab addAnimation:animationGroup forKey:@"newtab"];
    
    [CATransaction setCompletionBlock:^{
        NSUInteger newIndex = [self.tabs indexOfObject:self.selectedTab];
        
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
        
        [self.selectedTab removeFromSuperlayer];
        [self.tabs removeObject:self.selectedTab];
        
        [CATransaction commit];
        
        if (newIndex == [self.tabs count])
            newIndex--;
        
        if ([self.tabs count] == 0)
            return;
        
        [self selectTabLayer:[self.tabs objectAtIndex:newIndex]];
        
        [self repositionTabs];
    }];
    [CATransaction commit];
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
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.1];
    
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
    
    [CATransaction commit];
//    self.draggingTab.zPosition = 2;
}

- (void) repositionTabs {
    [self repositionTabs:self.tabs];
}

- (BOOL) acceptsFirstMouse:(NSEvent *)theEvent {
    NSPoint p = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSUInteger idx = p.x / SD_TAB_WIDTH;
    
    if (idx >= [self.tabs count])
        return YES;
    
    return NO;
}

- (void) mouseDown:(NSEvent *)theEvent {
    NSPoint p = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSUInteger idx = p.x / SD_TAB_WIDTH;
    
    self.dragWindowOffset = [NSEvent mouseLocation];
    self.dragWindowPosition = NSMakePoint(NSMinX([[self window] frame]), NSMaxY([[self window] frame]));
    
    if (idx >= [self.tabs count])
        return;
    
    self.draggingTab = [self.tabs objectAtIndex:idx];
    self.dragOffset = p.x - self.draggingTab.frame.origin.x;
    
    for (CALayer* tab in self.tabs) {
        tab.zPosition = 0;
    }
}

- (void) mouseDragged:(NSEvent *)theEvent {
    [super mouseDragged:theEvent];
    
    if (self.draggingTab == nil) {
        NSPoint p = [NSEvent mouseLocation];
        NSPoint newWindowPoint;
        newWindowPoint.x = self.dragWindowPosition.x - (self.dragWindowOffset.x - p.x);
        newWindowPoint.y = self.dragWindowPosition.y - (self.dragWindowOffset.y - p.y);
        [[self window] setFrameTopLeftPoint:newWindowPoint];
        return;
    }
    
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
