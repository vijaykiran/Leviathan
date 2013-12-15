//
//  LVSettings.m
//  Leviathan
//
//  Created by Steven on 11/10/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVSettings.h"

#import "LVPreferences.h"
#import "LVPathWatcher.h"

#import "Beowulf.h"

LV_DEFINE(LVSettingsReloadedNotification);

@interface LVSettings ()

@property LVPathWatcher* pathWatcher;

@end


@implementation LVSettings

+ (LVSettings*) sharedSettings {
    static LVSettings* sharedSettings;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSettings = [[LVSettings alloc] init];
        [sharedSettings setup];
        [sharedSettings recacheSettings];
    });
    return sharedSettings;
}

- (void) setup {
    self.pathWatcher = [LVPathWatcher watcherFor:[LVSettings settingsFileURL] handler:^{
        [[LVSettings sharedSettings] recacheSettings];
        [[NSNotificationCenter defaultCenter] postNotificationName:LVSettingsReloadedNotification object:nil];
    }];
}

- (void) recacheSettings {
    NSDictionary* rawSettings = LVParseConfigWithDefs([LVSettings settingsFileURL]);
    NSMutableDictionary* sanitizedSettings = [NSMutableDictionary dictionary];
    NSArray* knownSettingKeys = @[@"indent-like-functions", @"modal-key-bindings", @"key-bindings"];
    
    for (NSString* key in knownSettingKeys) {
        id val = [[rawSettings objectForKey:key] toObjC];
        if (val) {
            sanitizedSettings[key] = val;
        }
    }
    
    self.cachedSettings = sanitizedSettings;
}

+ (NSURL*) settingsFileURL {
    NSURL* settingsDestURL = [[LVPreferences settingsDirectory] URLByAppendingPathComponent:@"Settings.clj"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[settingsDestURL path]]) {
        NSURL* origFile = [[NSBundle mainBundle] URLForResource:@"Settings" withExtension:@"clj"];
        [[NSFileManager defaultManager] copyItemAtURL:origFile
                                                toURL:settingsDestURL
                                                error:NULL];
    }
    
    return settingsDestURL;
}

@end
