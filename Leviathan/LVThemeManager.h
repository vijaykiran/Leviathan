//
//  LVThemeManager.h
//  Leviathan
//
//  Created by Steven on 10/18/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LVTheme.h"

@interface LVThemeManager : NSObject

+ (LVThemeManager*) sharedThemeManager;

@property LVTheme* currentTheme;
- (NSArray*) potentialThemeNames;

- (void) loadTheme;

@end
