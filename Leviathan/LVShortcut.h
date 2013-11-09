//
//  LVShortcut.h
//  Leviathan
//
//  Created by Steven Degutis on 11/6/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LVShortcutString : NSObject

@property NSString* mods;
@property NSString* key;

- (NSString*) joinedWithTab;
- (NSString*) joinedWithoutTab;

@end

@interface LVShortcut : NSObject

+ (LVShortcut*) with:(NSArray*)combo;

@property NSMutableArray* keyEquivalentStrings;
@property NSMutableArray* orderedCombos;

@end
