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

- (void) currentEditorChanged:(LVTab*)tab {
    [self titlesChanged];
}

- (IBAction) selectNextTabViewItem:(id)sender {
    NSUInteger idx = [self.tabs indexOfObject: self.currentTab];
    idx++;
    if (idx == [self.tabs count])
        idx = 0;
    
    [self switchToTab:[self.tabs objectAtIndex:idx]];
    [self.tabBar manuallySelectTab:idx];
}

- (IBAction) selectPreviousTabViewItem:(id)sender {
    NSUInteger idx = [self.tabs indexOfObject: self.currentTab];
    idx--;
    if (idx == -1)
        idx = [self.tabs count] - 1;
    
    [self switchToTab:[self.tabs objectAtIndex:idx]];
    [self.tabBar manuallySelectTab:idx];
}

- (void) moveTab:(NSUInteger)from to:(NSUInteger)to {
    id tab = [self.tabs objectAtIndex:from];
    
    [self.tabs removeObject:tab];
    [self.tabs insertObject:tab atIndex:to];
    
    [self.tabBar moveTab:from to:to];
}

- (IBAction) moveTabToLeft:(id)sender {
    NSUInteger from = [self.tabs indexOfObject: self.currentTab];
    
    NSUInteger to = from - 1;
    if (to == -1)
        to = [self.tabs count] - 1;
    
    [self moveTab:from to:to];
}

- (IBAction) moveTabToRight:(id)sender {
    NSUInteger from = [self.tabs indexOfObject: self.currentTab];
    
    NSUInteger to = from + 1;
    if (to == [self.tabs count])
        to = 0;
    
    [self moveTab:from to:to];
}

- (void) addTab:(LVTab*)tab {
    tab.delegate = self;
    
    [self.tabs addObject:tab];
    [self.tabBar addTab: tab.currentEditor.title];
    [self switchToTab:tab];
}

- (void) titlesChanged {
    [self.tabBar changeTitles:[self.tabs valueForKeyPath:@"currentEditor.title"]];
}

- (void) selectTab:(LVTab*)tab {
    [self switchToTab:tab];
    [self.tabBar manuallySelectTab:[self.tabs indexOfObject:tab]];
}

- (void) switchToTab:(LVTab*)tab {
    [self.currentTab saveFirstResponder];
    
    tab.view.frame = self.bodyView.bounds;
    
    [[self.bodyView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.bodyView addSubview:tab.view];
    
    self.currentTab = tab;
    
    [self.window.windowController setNextResponder:self.currentTab];
    
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
