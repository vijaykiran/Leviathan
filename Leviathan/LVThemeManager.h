//
//  LVThemeManager.h
//  Leviathan
//
//  Created by Steven on 10/18/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>


static NSString* LVStyleBackgroundColor = @"background_color";
static NSString* LVStyleForSelection = @"selection_style";
static NSString* LVStyleCursorColor = @"cursor_color";

static NSString* LVStyleForSymbol = @"symbol_style";
static NSString* LVStyleForDef = @"def_keyord_style";
static NSString* LVStyleForDefName = @"def_name_style";
static NSString* LVStyleForKeyword = @"keyword_style";
static NSString* LVStyleForComment = @"comment_style";
static NSString* LVStyleForTypeOp = @"typehint_style";
static NSString* LVStyleForQuote = @"quote_style";
static NSString* LVStyleForUnquote = @"unquote_style";
static NSString* LVStyleForSyntaxQuote = @"syntaxquote_style";
static NSString* LVStyleForNumber = @"number_style";
static NSString* LVStyleForSyntaxError = @"syntax_error_style";
static NSString* LVStyleForRainbowParens = @"rainbow_parens_styles";
static NSString* LVStyleForString = @"string_style";
static NSString* LVStyleForRegex = @"regex_style";
static NSString* LVStyleForSplice = @"splice_style";


@interface LVThemeManager : NSObject

+ (LVThemeManager*) sharedThemeManager;
- (void) loadThemes;

@property NSDictionary* currentTheme;

@end
