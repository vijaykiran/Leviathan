//
//  LVThemeManager.m
//  Leviathan
//
//  Created by Steven on 10/18/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVThemeManager.h"

#import "LVPreferences.h"
#import "LVSettings.h"
#import "LVPathWatcher.h"

@interface LVThemeManager ()

@property NSMutableArray* oldThemes; // TODO: this is a TOTAL hack
@property LVPathWatcher* pathWatcher;

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

- (id) init {
    if (self = [super init]) {
        self.oldThemes = [NSMutableArray array];
        self.pathWatcher = [LVPathWatcher watcherFor:[LVThemeManager themesDirectory] handler:^{
            [LVPreferences setTheme:[LVPreferences theme]];
        }];
    }
    return self;
}

- (void) loadTheme {
    NSDictionary* themeData = LVParseConfig([self themeFileURL]);
    
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
    NSArray* themeURLs = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[LVThemeManager themesDirectory]
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
    NSURL* themeDestURL = [[LVThemeManager themesDirectory] URLByAppendingPathComponent:themeName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[themeDestURL path]]) {
        if ([themeName isEqualToString: LVDefaultThemeName]) {
            // copy file and try again
            NSURL* bundledThemesDir = [[NSBundle mainBundle] URLForResource:@"Themes" withExtension:@""];
            [[NSFileManager defaultManager] createDirectoryAtURL:[LVThemeManager themesDirectory] withIntermediateDirectories:YES attributes:nil error:NULL];
            
            NSArray* bundledThemeURLs = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:bundledThemesDir includingPropertiesForKeys:@[] options:NSDirectoryEnumerationSkipsSubdirectoryDescendants error:NULL];
            
            for (NSURL* themeURL in bundledThemeURLs) {
                [[NSFileManager defaultManager] copyItemAtURL:themeURL
                                                        toURL:[[LVThemeManager themesDirectory] URLByAppendingPathComponent:[themeURL lastPathComponent]]
                                                        error:NULL];
            }
        }
        else {
            // use default theme and try again
            [LVPreferences setTheme:LVDefaultThemeName];
        }
        return [self themeFileURL];
    }
    
    return themeDestURL;
}

+ (NSURL*) themesDirectory {
    NSURL* dataDirURL = [[LVPreferences settingsDirectory] URLByAppendingPathComponent:@"Themes"];
    
    [[NSFileManager defaultManager] createDirectoryAtURL:dataDirURL
                             withIntermediateDirectories:YES
                                              attributes:nil
                                                   error:NULL];
    
    return dataDirURL;
}

@end
