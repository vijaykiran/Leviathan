//
//  LVTheme.h
//  Leviathan
//
//  Created by Steven on 10/18/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LVTheme : NSObject

+ (LVTheme*) themeFromData:(NSDictionary*)data;

@property NSColor* backgroundColor;
@property NSDictionary* selection;
@property NSColor* cursorColor;
@property NSColor* highlightLineColor;

@property NSArray* rainbowparens;
@property NSDictionary* symbol;
@property NSDictionary* def;
@property NSDictionary* defname;
@property NSDictionary* keyword;
@property NSDictionary* comment;
@property NSDictionary* typeop;
@property NSDictionary* quote;
@property NSDictionary* unquote;
@property NSDictionary* syntaxquote;
@property NSDictionary* number;
@property NSDictionary* syntaxerror;
@property NSDictionary* string;
@property NSDictionary* regex;
@property NSDictionary* splice;
@property NSDictionary* _true;
@property NSDictionary* _false;
@property NSDictionary* _nil;

- (void) rebuild;

@end
