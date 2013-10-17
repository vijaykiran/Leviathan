//
//  LVTabView.h
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "LVTabBar.h"
#import "LVTabController.h"

@interface LVTabView : NSView <LVTabBarDelegate>

@property (weak, readonly) LVTabController* currentTab;

@property NSMutableArray* tabs;

- (void) addTab:(LVTabController*)tab;
- (void) closeCurrentTab;

@end
