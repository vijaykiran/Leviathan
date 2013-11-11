//
//  LVThemeMenuDelegate.m
//  Leviathan
//
//  Created by Steven on 11/11/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVThemeMenuDelegate.h"

#import "LVPreferences.h"
#import "LVThemeManager.h"

@implementation LVThemeMenuDelegate

- (void) menuNeedsUpdate:(NSMenu *)menu {
    NSArray* names = [[LVThemeManager sharedThemeManager] potentialThemeNames];
    
    [menu removeAllItems];
    
    for (NSString* name in names) {
        NSMenuItem* item = [menu addItemWithTitle:name action:@selector(changeTheme:) keyEquivalent:@""];
        [item setTarget:self];
        
        if ([name isEqualToString: [LVPreferences theme]]) {
            [item setState:NSOnState];
        }
    }
}

- (IBAction) changeTheme:(NSMenuItem*)item {
    [LVPreferences setTheme: [item title]];
}

@end
