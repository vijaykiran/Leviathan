//
//  LVTabView.h
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "LVTabBar.h"
#import "LVTab.h"

@interface LVTabView : NSView <LVTabBarDelegate, LVTabDelegate>

@property (weak, readonly) LVTab* currentTab;

@property NSMutableArray* tabs;

- (void) addTab:(LVTab*)tab;
- (void) closeCurrentTab;
- (void) closeAllTabs;

- (void) selectTab:(LVTab*)tab;

- (void) updateTabTitles;

@end
