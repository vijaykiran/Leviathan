//
//  LVPreferences.m
//  Leviathan
//
//  Created by Steven on 10/18/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVPreferences.h"

#import "LVThemeManager.h"

NSString* LVDefaultsFontChangedNotification = @"LVDefaultsFontChangedNotification";
NSString* LVCurrentThemeChangedNotification = @"LVCurrentThemeChangedNotification";

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

+ (NSData*) defaultSettingsDirectoryBookmarkData {
    NSURL* appSupportDirectory = [[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory
                                                                        inDomain:NSUserDomainMask
                                                               appropriateForURL:nil
                                                                          create:YES
                                                                           error:NULL];
    
    NSURL* dataDirURL = [[appSupportDirectory URLByAppendingPathComponent:@"Leviathan"] URLByAppendingPathComponent:@"Settings"];
    
    [[NSFileManager defaultManager] createDirectoryAtURL:dataDirURL
                             withIntermediateDirectories:YES
                                              attributes:nil
                                                   error:NULL];
    
    NSError* __autoreleasing error;
    return [[dataDirURL filePathURL] bookmarkDataWithOptions:0
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
