//
//  LVPreferences.m
//  Leviathan
//
//  Created by Steven on 10/18/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVPreferences.h"

#import "LVThemeManager.h"

#import "Beowulf.h"

LV_DEFINE(LVDefaultsFontChangedNotification);
LV_DEFINE(LVCurrentThemeChangedNotification);

NSString* LVDefaultThemeName = @"TomorrowNightEighties.clj";

@implementation LVPreferences

+ (NSFont*) userFont {
    NSString* fontName = [[NSUserDefaults standardUserDefaults] stringForKey:@"fontName"];
    CGFloat fontSize = [[NSUserDefaults standardUserDefaults] doubleForKey:@"fontSize"];
    return [NSFont fontWithName:fontName size:fontSize];
}

+ (void) setUserFont:(NSFont*)font {
    [[NSUserDefaults standardUserDefaults] setDouble:[font pointSize] forKey:@"fontSize"];
    [[NSUserDefaults standardUserDefaults] setObject:[font fontName] forKey:@"fontName"];
    [[[LVThemeManager sharedThemeManager] currentTheme] rebuild];
    [[NSNotificationCenter defaultCenter] postNotificationName:LVDefaultsFontChangedNotification object:nil];
}


+ (NSURL*) settingsDirectory {
    NSURL* url = [NSURL fileURLWithPath:[@"~/.leviathan" stringByStandardizingPath] isDirectory:YES];
    [[NSFileManager defaultManager] createDirectoryAtPath:[url path]
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:NULL];
    return url;
}

+ (NSString*) theme {
    return [[NSUserDefaults standardUserDefaults] stringForKey:@"currentThemeName"];
}

+ (void) setTheme:(NSString*)theme {
    [[NSUserDefaults standardUserDefaults] setObject:theme forKey:@"currentThemeName"];
    [[LVThemeManager sharedThemeManager] loadTheme];
    [[NSNotificationCenter defaultCenter] postNotificationName:LVCurrentThemeChangedNotification object:nil];
}

@end



#import "Beowulf.h"

id LVParseConfig(NSURL* url) {
    NSData* data = [NSData dataWithContentsOfURL:url];
    NSString* str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return [BWEval(str, BWFreshEnv(), NULL) toObjC];
}

NSDictionary* LVParseConfigWithDefs(NSURL* url) {
    NSData* data = [NSData dataWithContentsOfURL:url];
    NSString* str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    BWEnv* env = BWFreshEnv();
    
    BWEval(str, env, NULL);
    return env.names;
}
