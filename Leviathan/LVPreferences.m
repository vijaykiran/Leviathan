//
//  LVPreferences.m
//  Leviathan
//
//  Created by Steven on 10/18/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVPreferences.h"

#import "LVThemeManager.h"

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
    NSData* dirData = [[NSUserDefaults standardUserDefaults] dataForKey:@"settingsDirectoryData"];
    
    if (!dirData) {
        [[NSUserDefaults standardUserDefaults] setObject:[self defaultSettingsDirectoryBookmarkData]
                                                  forKey:@"settingsDirectoryData"];
        return [self settingsDirectory];
    }
    
    BOOL stale;
    NSError* __autoreleasing error;
    NSURL* dir = [NSURL URLByResolvingBookmarkData:dirData
                                           options:0
                                     relativeToURL:nil
                               bookmarkDataIsStale:&stale
                                             error:&error];
    
    if ([[dir pathComponents] containsObject: @".Trash"]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"settingsDirectoryData"];
        return [self settingsDirectory];
    }
    
    return dir;
}

+ (void) setSettingsDirectory:(NSURL*)settingsDirectory {
    [[NSUserDefaults standardUserDefaults] setObject:[self dataForURL:settingsDirectory]
                                              forKey:@"settingsDirectoryData"];
}

+ (NSData*) defaultSettingsDirectoryBookmarkData {
    NSURL* appSupportDirectory = [[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory
                                                                        inDomain:NSUserDomainMask
                                                               appropriateForURL:nil
                                                                          create:YES
                                                                           error:NULL];
    
    NSURL* dataDirURL = [[appSupportDirectory URLByAppendingPathComponent:@"Leviathan"] URLByAppendingPathComponent:@"MovableLeviathanSettingsFolder"];
    
    [[NSFileManager defaultManager] createDirectoryAtURL:dataDirURL
                             withIntermediateDirectories:YES
                                              attributes:nil
                                                   error:NULL];
    
    return [self dataForURL:dataDirURL];
}

+ (NSData*) dataForURL:(NSURL*)url {
    NSError* __autoreleasing error;
    return [url bookmarkDataWithOptions:0
         includingResourceValuesForKeys:@[]
                          relativeToURL:nil
                                  error:&error];
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
    BWEnv* env = [Beowulf basicEnv];
    NSString* prelude = [NSString stringWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"prelude" withExtension:@"bwlf"] encoding:NSUTF8StringEncoding error:NULL];
    [Beowulf eval:prelude env:env error:NULL];
    return [Beowulf eval:str env:env error:NULL];
}

NSDictionary* LVParseConfigWithDefs(NSURL* url) {
    NSData* data = [NSData dataWithContentsOfURL:url];
    NSString* str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    BWEnv* env = [BWEnv env];
    env.parent = [Beowulf basicEnv];
    NSString* prelude = [NSString stringWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"prelude" withExtension:@"bwlf"] encoding:NSUTF8StringEncoding error:NULL];
    [Beowulf eval:prelude env:env error:NULL];
    [Beowulf eval:str env:env error:NULL];
    return env.names;
}
