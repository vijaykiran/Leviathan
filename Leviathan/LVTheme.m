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
    if (hex == nil)
        return nil;
    
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

@interface LVTheme ()

@property NSDictionary* themeData;

@end

@implementation LVTheme

+ (LVTheme*) themeFromData:(NSDictionary*)data {
    LVTheme* theme = [[LVTheme alloc] init];
    theme.themeData = data;
    [theme rebuild];
    return theme;
}

- (void) rebuild {
    self.selection = LVThemeSelectionStyleFrom([self.themeData objectForKey:@"selection-style"]);
    
    self.backgroundColor = LVColorFromHex([self.themeData objectForKey:@"background-color"]);
    self.cursorColor = LVColorFromHex([self.themeData objectForKey:@"cursor-color"]);
    self.highlightLineColor = LVColorFromHex([self.themeData objectForKey:@"highlight-line-color"]);
    
    self.symbol = LVThemeStyleFrom([self.themeData objectForKey:@"symbol-style"]);
    self.def = LVThemeStyleFrom([self.themeData objectForKey:@"def-keyord-style"]);
    self.defname = LVThemeStyleFrom([self.themeData objectForKey:@"def-name-style"]);
    self.keyword = LVThemeStyleFrom([self.themeData objectForKey:@"keyword-style"]);
    self.comment = LVThemeStyleFrom([self.themeData objectForKey:@"comment-style"]);
    self.typeop = LVThemeStyleFrom([self.themeData objectForKey:@"typehint-style"]);
    self.quote = LVThemeStyleFrom([self.themeData objectForKey:@"quote-style"]);
    self.unquote = LVThemeStyleFrom([self.themeData objectForKey:@"unquote-style"]);
    self.syntaxquote = LVThemeStyleFrom([self.themeData objectForKey:@"syntaxquote-style"]);
    self.number = LVThemeStyleFrom([self.themeData objectForKey:@"number-style"]);
    self.syntaxerror = LVThemeStyleFrom([self.themeData objectForKey:@"syntax-error-style"]);
    self.string = LVThemeStyleFrom([self.themeData objectForKey:@"string-style"]);
    self.regex = LVThemeStyleFrom([self.themeData objectForKey:@"regex-style"]);
    self.splice = LVThemeStyleFrom([self.themeData objectForKey:@"splice-style"]);
    self._true = LVThemeStyleFrom([self.themeData objectForKey:@"true-style"]);
    self._false = LVThemeStyleFrom([self.themeData objectForKey:@"false-style"]);
    self._nil = LVThemeStyleFrom([self.themeData objectForKey:@"nil-style"]);
    
    NSMutableArray* rainbowStyles = [NSMutableArray array];
    for (NSDictionary* rainbowParen in [self.themeData objectForKey:@"rainbow-parens-styles"]) {
        [rainbowStyles addObject:LVThemeStyleFrom(rainbowParen)];
    }
    
    self.rainbowparens = rainbowStyles;
}

@end
