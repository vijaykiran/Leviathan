//
//  SDTheme.h
//  Leviathan
//
//  Created by Steven Degutis on 10/12/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>


static NSString* SDThemeBackgroundColor = @"background_color";
static NSString* SDThemeSelectionColor = @"selection_color";
static NSString* SDThemeCursorColor = @"cursor_color";

static NSString* SDThemeForSymbol = @"symbol_style";
static NSString* SDThemeForDef = @"def_keyord_style";
static NSString* SDThemeForDefName = @"def_name_style";
static NSString* SDThemeForKeyword = @"keyword_style";
static NSString* SDThemeForComment = @"comment_style";
static NSString* SDThemeForTypeOp = @"typehint_style";
static NSString* SDThemeForQuote = @"quote_style";
static NSString* SDThemeForUnquote = @"unquote_style";
static NSString* SDThemeForSyntaxQuote = @"syntaxquote_style";
static NSString* SDThemeForNumber = @"number_style";
static NSString* SDThemeForSyntaxError = @"syntax_error_style";
static NSString* SDThemeForRainbowParens = @"rainbow_parens_styles";
static NSString* SDThemeForString = @"string_style";
static NSString* SDThemeForRegex = @"regex_style";
static NSString* SDThemeForSplice = @"splice_style";

@interface SDTheme : NSObject

@property NSMutableDictionary* attributes;

+ (SDTheme*) temporaryTheme;
- (void) setup;

@end

NSColor* SDColorFromHex(NSString* hex);
NSFont* SDFixFont(NSFont* font, BOOL haveIt, int trait);
void SDApplyStyle(NSMutableAttributedString* attrString, NSString* styleName, NSRange range, NSUInteger deepness);
