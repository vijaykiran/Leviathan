//
//  LVTabBar.h
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol LVTabBarDelegate <NSObject>

// uhh...

@end

@interface LVTabBar : NSView

@property (weak) id<LVTabBarDelegate> delegate;

- (void) addTab:(NSString*)title;
- (void) closeCurrentTab;

@end
