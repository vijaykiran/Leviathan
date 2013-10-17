//
//  SDTheme.m
//  Leviathan
//
//  Created by Steven Degutis on 10/12/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDTheme.h"

@implementation SDTheme

+ (SDTheme*) temporaryTheme {
    static SDTheme* theme;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        theme = [[SDTheme alloc] init];
        [theme setup];
    });
    return theme;
}

- (void) setup {
    self.attributes = [NSMutableDictionary dictionary];
    
    self.attributes[SDThemeBackgroundColor] = @"252A2B";
    self.attributes[SDThemeSelectionColor] = @"5c3566";
    self.attributes[SDThemeCursorColor] = @"babdb6";
    
    self.attributes[SDThemeForDef] = @{ @"Bold": @YES, @"Color": @"729fcf" };
    self.attributes[SDThemeForDefName] = @{ @"Bold": @YES, @"Color": @"edd400" };
    self.attributes[SDThemeForSymbol] = @{ @"Bold": @NO, @"Color": @"eeeeec" };
    
    self.attributes[SDThemeForKeyword] = @{ @"Bold": @NO, @"Color": @"73d216" };
    self.attributes[SDThemeForComment] = @{ @"Bold": @NO, @"Color": @"999999" };
    self.attributes[SDThemeForNumber] = @{ @"Bold": @NO, @"Color": @"99bbff" };
    self.attributes[SDThemeForString] = @{ @"Bold": @NO, @"Color": @"ad7fa8" };
    self.attributes[SDThemeForRegex] = @{ @"Bold": @NO, @"Color": @"e9b96e" };
    
    self.attributes[SDThemeForTypeOp] = @{ @"Bold": @YES, @"Color": @"edd400" };
    self.attributes[SDThemeForQuote] = @{ @"Bold": @YES, @"Color": @"edd400" };
    self.attributes[SDThemeForUnquote] = @{ @"Bold": @YES, @"Color": @"edd400" };
    self.attributes[SDThemeForSyntaxQuote] = @{ @"Bold": @YES, @"Color": @"edd400" };
    self.attributes[SDThemeForSplice] = @{ @"Bold": @YES, @"Color": @"edd400" };
    
    self.attributes[SDThemeForSyntaxError] = @{ @"Bold": @YES, @"Color": @"ef2929" };
    
    self.attributes[SDThemeForRainbowParens] = @[@{ @"Bold": @NO, @"Color": @"729fcf" },
                                                 @{ @"Bold": @NO, @"Color": @"8ae234" },
                                                 @{ @"Bold": @NO, @"Color": @"fce94f" },
                                                 @{ @"Bold": @NO, @"Color": @"ad7fa8" },
                                                 @{ @"Bold": @NO, @"Color": @"e9b96e" },
                                                 @{ @"Bold": @NO, @"Color": @"fcaf3e" },
                                                 @{ @"Bold": @NO, @"Color": @"3465a4" },
                                                 @{ @"Bold": @NO, @"Color": @"73d216" },
                                                 @{ @"Bold": @NO, @"Color": @"f57900" },
                                                 @{ @"Bold": @NO, @"Color": @"75507b" },
                                                 @{ @"Bold": @NO, @"Color": @"c17d11" }];
    
}

@end

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
        NSArray* attrsList = [[[SDTheme temporaryTheme] attributes] objectForKey: styleName];
        customAttrs = [attrsList objectAtIndex: deepness % [attrsList count]];
    }
    else {
        customAttrs = [[[SDTheme temporaryTheme] attributes] objectForKey: styleName];
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
