//
//  LVTheme.h
//  Leviathan
//
//  Created by Steven on 10/18/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LVThemeStyle : NSObject

@property NSColor* color;
@property BOOL bold;
@property BOOL italic;

- (void) highlightIn:(NSTextStorage*)textStorage range:(NSRange)range depth:(int)depth;

@end

@interface LVThemeStyleArray : LVThemeStyle

@property NSArray* styles;

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

@property LVThemeStyleArray* rainbowparens;
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

@end
