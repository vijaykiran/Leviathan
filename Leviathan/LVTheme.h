//
//  LVTheme.h
//  Leviathan
//
//  Created by Steven on 10/18/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LVThemeStyle : NSObject

@property NSDictionary* attrs;

@end

@interface LVThemeSelectionStyle : NSObject

@property NSColor* foregroundColor;
@property NSColor* backgroundColor;

@end

@interface LVTheme : NSObject

+ (LVTheme*) themeFromData:(NSDictionary*)data;

@property NSColor* backgroundColor;
@property LVThemeSelectionStyle* selection;
@property NSColor* cursorColor;

@property NSArray* rainbowparens;
@property LVThemeStyle* symbol;
@property LVThemeStyle* def;
@property LVThemeStyle* defname;
@property LVThemeStyle* keyword;
@property LVThemeStyle* comment;
@property LVThemeStyle* typeop;
@property LVThemeStyle* quote;
@property LVThemeStyle* unquote;
@property LVThemeStyle* syntaxquote;
@property LVThemeStyle* number;
@property LVThemeStyle* syntaxerror;
@property LVThemeStyle* string;
@property LVThemeStyle* regex;
@property LVThemeStyle* splice;
@property LVThemeStyle* _true;
@property LVThemeStyle* _false;
@property LVThemeStyle* _nil;

@end
