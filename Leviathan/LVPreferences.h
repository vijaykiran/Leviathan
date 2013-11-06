//
//  LVPreferences.h
//  Leviathan
//
//  Created by Steven on 10/18/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString* LVDefaultsFontChangedNotification;
extern NSString* LVCurrentThemeChangedNotification;

@interface LVPreferences : NSObject

+ (NSFont*) userFont;
+ (void) setUserFont:(NSFont*)font;

+ (NSURL*) settingsDirectory;

+ (NSString*) theme;
+ (void) setTheme:(NSString*)theme;

@end

id LVParseConfigFromString(NSURL* url);
