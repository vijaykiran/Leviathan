//
//  LVTheme.m
//  Leviathan
//
//  Created by Steven on 10/18/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVTheme.h"

#import "LVPreferences.h"

static NSFont* LVAdjustFont(NSFont* font, BOOL haveIt, int trait) {
    NSFontManager* fm = [NSFontManager sharedFontManager];
    return (haveIt ? [fm convertFont:font toHaveTrait:trait] : [fm convertFont:font toNotHaveTrait:trait]);
}

static NSColor* LVColorFromHex(NSString* hex) {
    unsigned container = 0;
    [[NSScanner scannerWithString:hex] scanHexInt:&container];
    return [NSColor colorWithCalibratedRed:(CGFloat)(unsigned char)(container >> 16) / 0xff
                                     green:(CGFloat)(unsigned char)(container >> 8) / 0xff
                                      blue:(CGFloat)(unsigned char)(container) / 0xff
                                     alpha:1.0];
}

static NSDictionary* LVThemeStyleFrom(NSDictionary* data) {
    NSMutableDictionary* attrs = [NSMutableDictionary dictionary];
    attrs[NSForegroundColorAttributeName] = LVColorFromHex([data objectForKey:@"color"]);
    
    NSFont* font = [LVPreferences userFont];
    font = LVAdjustFont(font, [[data objectForKey:@"bold"] boolValue], NSFontBoldTrait);
    font = LVAdjustFont(font, [[data objectForKey:@"italic"] boolValue], NSFontItalicTrait);
    attrs[NSFontAttributeName] = font;
    
    return attrs;
}

static NSDictionary* LVThemeSelectionStyleFrom(NSDictionary* data) {
    NSMutableDictionary* selectionAttrs = [NSMutableDictionary dictionary];
    
    NSString* fg = [data objectForKey:@"foreground-color"];
    if (fg) selectionAttrs[NSForegroundColorAttributeName] = LVColorFromHex(fg);
    
    NSString* bg = [data objectForKey:@"background-color"];
    if (bg) selectionAttrs[NSBackgroundColorAttributeName] = LVColorFromHex(bg);
    
    return selectionAttrs;
}

@implementation LVTheme

+ (LVTheme*) themeFromData:(NSDictionary*)data {
    LVTheme* theme = [[LVTheme alloc] init];
    
    theme.selection = LVThemeSelectionStyleFrom([data objectForKey:@"selection-style"]);
    
    theme.backgroundColor = LVColorFromHex([data objectForKey:@"background-color"]);
    theme.cursorColor = LVColorFromHex([data objectForKey:@"cursor-color"]);
    
    theme.symbol = LVThemeStyleFrom([data objectForKey:@"symbol-style"]);
    theme.def = LVThemeStyleFrom([data objectForKey:@"def-keyord-style"]);
    theme.defname = LVThemeStyleFrom([data objectForKey:@"def-name-style"]);
    theme.keyword = LVThemeStyleFrom([data objectForKey:@"keyword-style"]);
    theme.comment = LVThemeStyleFrom([data objectForKey:@"comment-style"]);
    theme.typeop = LVThemeStyleFrom([data objectForKey:@"typehint-style"]);
    theme.quote = LVThemeStyleFrom([data objectForKey:@"quote-style"]);
    theme.unquote = LVThemeStyleFrom([data objectForKey:@"unquote-style"]);
    theme.syntaxquote = LVThemeStyleFrom([data objectForKey:@"syntaxquote-style"]);
    theme.number = LVThemeStyleFrom([data objectForKey:@"number-style"]);
    theme.syntaxerror = LVThemeStyleFrom([data objectForKey:@"syntax-error-style"]);
    theme.string = LVThemeStyleFrom([data objectForKey:@"string-style"]);
    theme.regex = LVThemeStyleFrom([data objectForKey:@"regex-style"]);
    theme.splice = LVThemeStyleFrom([data objectForKey:@"splice-style"]);
    theme._true = LVThemeStyleFrom([data objectForKey:@"true-style"]);
    theme._false = LVThemeStyleFrom([data objectForKey:@"false-style"]);
    theme._nil = LVThemeStyleFrom([data objectForKey:@"nil-style"]);
    
    NSMutableArray* rainbowStyles = [NSMutableArray array];
    for (NSDictionary* rainbowParen in [data objectForKey:@"rainbow-parens-styles"]) {
        [rainbowStyles addObject:LVThemeStyleFrom(rainbowParen)];
    }
    
    theme.rainbowparens = rainbowStyles;
    
    return theme;
}

@end
