//
//  LVSettings.h
//  Leviathan
//
//  Created by Steven on 11/10/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* LVSettingsReloadedNotification;

@interface LVSettings : NSObject

+ (LVSettings*) sharedSettings;

@property NSDictionary* cachedSettings;
- (void) recacheSettings;

+ (NSURL*) settingsFileURL;

@end

id LVParseConfig(NSURL* url);
NSDictionary* LVParseConfigWithDefs(NSURL* url);
