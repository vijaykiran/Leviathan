//
//  LVThemeManager.m
//  Leviathan
//
//  Created by Steven on 10/18/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVThemeManager.h"

#import "configs.h"
#import "LVPreferences.h"

@interface LVThemeManager ()

@property NSMutableArray* oldThemes; // TODO: this is a TOTAL hack

@end

@implementation LVThemeManager

+ (LVThemeManager*) sharedThemeManager {
    static LVThemeManager* sharedThemeManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedThemeManager = [[LVThemeManager alloc] init];
        sharedThemeManager.oldThemes = [NSMutableArray array];
    });
    return sharedThemeManager;
}

- (void) loadThemes {
    NSData* data = [NSData dataWithContentsOfURL:[self themeFileURL]];
    NSString* str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary* themeData = [LVParseConfigFromString(str) copy];
    
    if (self.currentTheme) {
        [self.oldThemes addObject: self.currentTheme];
        
        double delayInSeconds = 2.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self.oldThemes removeObject: self.currentTheme];
        });
    }
    
    self.currentTheme = [LVTheme themeFromData:themeData];
}

- (NSArray*) potentialThemeNames {
    NSArray* themeURLs = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[self themesDirectory]
                                                       includingPropertiesForKeys:@[]
                                                                          options:NSDirectoryEnumerationSkipsSubdirectoryDescendants
                                                                            error:NULL];
    
    NSMutableArray* names = [NSMutableArray array];
    
    for (NSURL* themeURL in themeURLs) {
        [names addObject:[themeURL lastPathComponent]];
    }
    
    return names;
}

- (NSURL*) themeFileURL {
    NSString* themeName = [LVPreferences theme];
    NSURL* themeDestURL = [[self themesDirectory] URLByAppendingPathComponent:themeName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[themeDestURL path]]) {
        if ([themeName isEqualToString: @"Default.clj"]) {
            // copy file and try again
            NSURL* bundledThemesDir = [[NSBundle mainBundle] URLForResource:@"Themes" withExtension:@""];
            [[NSFileManager defaultManager] createDirectoryAtURL:[self themesDirectory] withIntermediateDirectories:YES attributes:nil error:NULL];
            
            NSArray* bundledThemeURLs = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:bundledThemesDir includingPropertiesForKeys:@[] options:NSDirectoryEnumerationSkipsSubdirectoryDescendants error:NULL];
            
            for (NSURL* themeURL in bundledThemeURLs) {
                [[NSFileManager defaultManager] copyItemAtURL:themeURL
                                                        toURL:[[self themesDirectory] URLByAppendingPathComponent:[themeURL lastPathComponent]]
                                                        error:NULL];
            }
        }
        else {
            // use default theme and try again
            [LVPreferences setTheme:@"Default.clj"];
        }
        return [self themeFileURL];
    }
    
    return themeDestURL;
}

- (NSURL*) themesDirectory {
    NSURL* dataDirURL = [[LVPreferences settingsDirectory] URLByAppendingPathComponent:@"Themes"];
    
    [[NSFileManager defaultManager] createDirectoryAtURL:dataDirURL
                             withIntermediateDirectories:YES
                                              attributes:nil
                                                   error:NULL];
    
    return dataDirURL;
}

@end
