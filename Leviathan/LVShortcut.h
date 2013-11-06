//
//  LVShortcut.h
//  Leviathan
//
//  Created by Steven Degutis on 11/6/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LVShortcut : NSObject

+ (LVShortcut*) withMods:(NSArray*)mods key:(NSString*)key;

@property NSString* keyEquivalentString;
@property NSArray* combo;

@end
