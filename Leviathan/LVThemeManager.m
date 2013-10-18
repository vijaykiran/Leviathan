//
//  LVThemeManager.m
//  Leviathan
//
//  Created by Steven on 10/18/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVThemeManager.h"

#import "edn-objc/edn-objc.h"

@interface LVThemeManager ()
@end

@implementation LVThemeManager

+ (LVThemeManager*) sharedThemeManager {
    static LVThemeManager* sharedThemeManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedThemeManager = [[LVThemeManager alloc] init];
    });
    return sharedThemeManager;
}

- (void) loadThemes {
    [self copyDefaultThemeMaybe];
    [self loadCurrentTheme];
}

- (NSURL*) currentThemeFile {
    NSError *error;
    NSURL *appSupportDir = [[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory
                                                                  inDomain:NSUserDomainMask
                                                         appropriateForURL:nil
                                                                    create:YES
                                                                     error:&error];
    
    NSURL* dataDirURL = [[appSupportDir URLByAppendingPathComponent:@"Leviathan"] URLByAppendingPathComponent:@"Themes"];
    
    [[NSFileManager defaultManager] createDirectoryAtURL:dataDirURL
                             withIntermediateDirectories:YES
                                              attributes:nil
                                                   error:NULL];
    
    return [dataDirURL URLByAppendingPathComponent:@"CURRENT_THEME.clj"];
}

- (void) copyFileOrElse:(NSURL*)from to:(NSURL*)to {
    NSError*__autoreleasing error;
    if (![[NSFileManager defaultManager] copyItemAtURL:from toURL:to error:&error]) {
        [NSApp presentError:error];
        [NSApp terminate:self];
        return;
    }
}

- (void) copyDefaultThemeMaybe {
    NSURL* currentThemeInAppSupport = [self currentThemeFile];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[currentThemeInAppSupport path]]) {
        NSURL* defaultThemeInBundle = [[NSBundle mainBundle] URLForResource:@"default_leviathan_theme" withExtension:@"clj"];
        
        [self copyFileOrElse:defaultThemeInBundle to:currentThemeInAppSupport];
        [self copyFileOrElse:defaultThemeInBundle to:[[currentThemeInAppSupport URLByDeletingLastPathComponent] URLByAppendingPathComponent:@"DefaultTheme.clj"]];
    }
}

- (void) loadCurrentTheme {
    NSData* data = [NSData dataWithContentsOfURL:[self currentThemeFile]];
    
    NSError* __autoreleasing error;
    NSDictionary* themeData = [BMOEDNSerialization ednObjectWithData:data options:0 error:&error];
    
    if (themeData == nil) {
        [NSApp presentError:error];
        [NSApp terminate:self];
        return;
    }
    
    self.currentTheme = [LVTheme themeFromData:themeData];;
}

@end
