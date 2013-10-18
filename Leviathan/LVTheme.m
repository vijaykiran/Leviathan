//
//  SDTheme.m
//  Leviathan
//
//  Created by Steven Degutis on 10/12/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVTheme.h"

NSColor* SDColorFromHex(NSString* hex) {
    unsigned container = 0;
    [[NSScanner scannerWithString:hex] scanHexInt:&container];
    return [NSColor colorWithCalibratedRed:(CGFloat)(unsigned char)(container >> 16) / 0xff
                                     green:(CGFloat)(unsigned char)(container >> 8) / 0xff
                                      blue:(CGFloat)(unsigned char)(container) / 0xff
                                     alpha:1.0];
}


NSFont* SDFixFont(NSFont* font, BOOL haveIt, int trait) {
    NSFontManager* fm = [NSFontManager sharedFontManager];
    return (haveIt ? [fm convertFont:font toHaveTrait:trait] : [fm convertFont:font toNotHaveTrait:trait]);
}

void SDApplyStyle(NSMutableAttributedString* attrString, NSString* styleName, NSRange range, NSUInteger deepness) {
    NSDictionary* customAttrs;
    
    if (styleName == SDThemeForRainbowParens) {
        NSArray* attrsList = [[[LVThemeManager sharedThemeManager] currentTheme] objectForKey: styleName];
        customAttrs = [attrsList objectAtIndex: deepness % [attrsList count]];
    }
    else {
        customAttrs = [[[LVThemeManager sharedThemeManager] currentTheme] objectForKey: styleName];
    }
    
    NSMutableDictionary* newStyle = [NSMutableDictionary dictionary];
    
    NSFont* font = [attrString attribute:NSFontAttributeName atIndex:range.location effectiveRange:NULL];
    font = SDFixFont(font, [customAttrs[@"Bold"] boolValue], NSFontBoldTrait);
    font = SDFixFont(font, [customAttrs[@"Italic"] boolValue], NSFontItalicTrait);
    newStyle[NSForegroundColorAttributeName] = SDColorFromHex(customAttrs[@"Color"]);
    newStyle[NSFontAttributeName] = font;
    
    [attrString addAttributes:newStyle
                        range:range];
}
