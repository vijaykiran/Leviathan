//
//  LVPreferences.m
//  Leviathan
//
//  Created by Steven on 10/18/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVPreferences.h"

NSString* LVDefaultsFontChangedNotification = @"SDDefaultsFontChangedNotification";

@implementation LVPreferences

+ (NSFont*) userFont {
    NSString* fontName = [[NSUserDefaults standardUserDefaults] stringForKey:@"fontName"];
    CGFloat fontSize = [[NSUserDefaults standardUserDefaults] doubleForKey:@"fontSize"];
    return [NSFont fontWithName:fontName size:fontSize];
}

+ (void) setUserFont:(NSFont*)font {
    [[NSUserDefaults standardUserDefaults] setDouble:[font pointSize] forKey:@"fontSize"];
    [[NSUserDefaults standardUserDefaults] setObject:[font fontName] forKey:@"fontName"];
    [[NSNotificationCenter defaultCenter] postNotificationName:LVDefaultsFontChangedNotification object:nil];
}

@end
