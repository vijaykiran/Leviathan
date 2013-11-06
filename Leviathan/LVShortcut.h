//
//  LVShortcut.h
//  Leviathan
//
//  Created by Steven Degutis on 11/6/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LVShortcut : NSObject

+ (LVShortcut*) withAction:(SEL)action mods:(NSArray*)mods key:(NSString*)key;

@property SEL action;
@property NSString* key;
@property NSArray* mods;

- (NSString*) keyEquivalentString;

- (BOOL) matches:(NSEvent*)event;

@end
