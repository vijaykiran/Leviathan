//
//  SDTheme.h
//  Leviathan
//
//  Created by Steven Degutis on 10/12/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>


static NSString* SDThemeBackgroundColor = @"SDThemeBackgroundColor";
static NSString* SDThemeSelectionColor = @"SDThemeSelectionColor";
static NSString* SDThemeCursorColor = @"SDThemeCursorColor";

static NSString* SDThemeForSymbol = @"SDThemeForSymbol";
static NSString* SDThemeForDef = @"SDThemeForDef";
static NSString* SDThemeForDefName = @"SDThemeForDefName";
static NSString* SDThemeForKeyword = @"SDThemeForKeyword";
static NSString* SDThemeForComment = @"SDThemeForComment";
static NSString* SDThemeForTypeOp = @"SDThemeForTypeOp";
static NSString* SDThemeForQuote = @"SDThemeForQuote";
static NSString* SDThemeForUnquote = @"SDThemeForUnquote";
static NSString* SDThemeForSyntaxQuote = @"SDThemeForSyntaxQuote";
static NSString* SDThemeForNumber = @"SDThemeForNumber";
static NSString* SDThemeForSyntaxError = @"SDThemeForSyntaxError";
static NSString* SDThemeForRainbowParens = @"SDThemeForRainbowParens";
static NSString* SDThemeForString = @"SDThemeForString";
static NSString* SDThemeForRegex = @"SDThemeForRegex";
static NSString* SDThemeForSplice = @"SDThemeForSplice";

@interface SDTheme : NSObject

@property NSMutableDictionary* attributes;

+ (SDTheme*) temporaryTheme;
- (void) setup;

@end

NSColor* SDColorFromHex(NSString* hex);
NSFont* SDFixFont(NSFont* font, BOOL haveIt, int trait);
void SDApplyStyle(NSMutableAttributedString* attrString, NSString* styleName, NSRange range, NSUInteger deepness);
