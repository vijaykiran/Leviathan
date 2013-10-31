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

NSColor* LVColorFromHex(NSString* hex) {
    unsigned container = 0;
    [[NSScanner scannerWithString:hex] scanHexInt:&container];
    return [NSColor colorWithCalibratedRed:(CGFloat)(unsigned char)(container >> 16) / 0xff
                                     green:(CGFloat)(unsigned char)(container >> 8) / 0xff
                                      blue:(CGFloat)(unsigned char)(container) / 0xff
                                     alpha:1.0];
}

@implementation LVThemeStyle

+ (LVThemeStyle*) styleFrom:(NSDictionary*)data {
    LVThemeStyle* style = [[LVThemeStyle alloc] init];
    
    NSMutableDictionary* attrs = [NSMutableDictionary dictionary];
    attrs[NSForegroundColorAttributeName] = LVColorFromHex([data objectForKey:@"color"]);
    
    NSFont* font = [LVPreferences userFont];
    font = LVAdjustFont(font, [[data objectForKey:@"bold"] boolValue], NSFontBoldTrait);
    font = LVAdjustFont(font, [[data objectForKey:@"italic"] boolValue], NSFontItalicTrait);
    attrs[NSFontAttributeName] = font;
    
    style.attrs = attrs;
    
    return style;
}

@end

NSDictionary* LVThemeSelectionStyleFrom(NSDictionary* data) {
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
    
    theme.symbol = [LVThemeStyle styleFrom: [data objectForKey:@"symbol-style"]];
    theme.def = [LVThemeStyle styleFrom: [data objectForKey:@"def-keyord-style"]];
    theme.defname = [LVThemeStyle styleFrom: [data objectForKey:@"def-name-style"]];
    theme.keyword = [LVThemeStyle styleFrom: [data objectForKey:@"keyword-style"]];
    theme.comment = [LVThemeStyle styleFrom: [data objectForKey:@"comment-style"]];
    theme.typeop = [LVThemeStyle styleFrom: [data objectForKey:@"typehint-style"]];
    theme.quote = [LVThemeStyle styleFrom: [data objectForKey:@"quote-style"]];
    theme.unquote = [LVThemeStyle styleFrom: [data objectForKey:@"unquote-style"]];
    theme.syntaxquote = [LVThemeStyle styleFrom: [data objectForKey:@"syntaxquote-style"]];
    theme.number = [LVThemeStyle styleFrom: [data objectForKey:@"number-style"]];
    theme.syntaxerror = [LVThemeStyle styleFrom: [data objectForKey:@"syntax-error-style"]];
    theme.string = [LVThemeStyle styleFrom: [data objectForKey:@"string-style"]];
    theme.regex = [LVThemeStyle styleFrom: [data objectForKey:@"regex-style"]];
    theme.splice = [LVThemeStyle styleFrom: [data objectForKey:@"splice-style"]];
    theme._true = [LVThemeStyle styleFrom: [data objectForKey:@"true-style"]];
    theme._false = [LVThemeStyle styleFrom: [data objectForKey:@"false-style"]];
    theme._nil = [LVThemeStyle styleFrom: [data objectForKey:@"nil-style"]];
    
    NSMutableArray* rainbowStyles = [NSMutableArray array];
    for (NSDictionary* rainbowParen in [data objectForKey:@"rainbow-parens-styles"]) {
        [rainbowStyles addObject:[LVThemeStyle styleFrom: rainbowParen]];
    }
    
    theme.rainbowparens = rainbowStyles;
    
    return theme;
}

@end
