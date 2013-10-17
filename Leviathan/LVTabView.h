//
//  LVTabView.h
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "LVTabBar.h"

@interface LVTabView : NSView <LVTabBarDelegate>

@property NSMutableArray* tabs;

- (void) addTab:(NSViewController*)tab;
- (void) closeCurrentTab;

@end
