//
//  LVTabView.m
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVTabView.h"

@interface LVTabView ()

@property LVTabBar* tabBar;
@property NSView* bodyView;

@property (weak) LVTab* currentTab;

@end

@implementation LVTabView

- (id)initWithFrame:(NSRect)frame {
    if (self = [super initWithFrame:frame]) {
        // TODO: do we need this?
    }
    return self;
}

- (void) awakeFromNib {
    self.tabs = [NSMutableArray array];
    
    NSRect tabFrame, bodyFrame;
    NSDivideRect([self bounds], &tabFrame, &bodyFrame, 30.0, NSMaxYEdge);
    
    self.tabBar = [[LVTabBar alloc] initWithFrame:tabFrame];
    self.bodyView = [[NSView alloc] initWithFrame:bodyFrame];
    
    self.tabBar.autoresizingMask = NSViewWidthSizable | NSViewMinYMargin;
    self.bodyView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    
    self.tabBar.delegate = self;
    
    [self addSubview:self.tabBar];
    [self addSubview:self.bodyView];
}

- (void) addTab:(LVTab*)tab {
    [self.tabs addObject:tab];
    [self.tabBar addTab: tab.title];
    [self switchToTab:tab];
}

- (void) switchToTab:(LVTab*)tab {
    [self.currentTab saveFirstResponder];
    
    tab.view.frame = self.bodyView.bounds;
    
    [[self.bodyView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.bodyView addSubview:tab.view];
    
    self.nextResponder = tab;
    
    self.currentTab = tab;
    
    [self.currentTab restoreFirstResponder];
}

- (void) movedTab:(NSUInteger)from to:(NSUInteger)to {
    id tab = [self.tabs objectAtIndex:from];
    [self.tabs removeObject:tab];
    [self.tabs insertObject:tab atIndex:to];
}

- (void) selectedTab:(NSUInteger)tabIndex {
    [self switchToTab:[self.tabs objectAtIndex:tabIndex]];
}

- (void) closeCurrentTab {
    [self.tabBar closeCurrentTab];
    
    NSUInteger newIndex = [self.tabs indexOfObject:self.currentTab];
    
    [self.tabs removeObject:self.currentTab];
    
    if (newIndex == [self.tabs count])
        newIndex--;
    
    [self switchToTab:[self.tabs objectAtIndex:newIndex]];
}

@end
