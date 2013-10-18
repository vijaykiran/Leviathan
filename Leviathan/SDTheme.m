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

- (NSURL*) currentThemeFile {
    NSError *error;
    NSURL *appSupportDir = [[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory
                                                                  inDomain:NSUserDomainMask
                                                         appropriateForURL:nil
                                                                    create:YES
                                                                     error:&error];
    
    NSURL* dataDirURL = [[appSupportDir URLByAppendingPathComponent:@"Leviathan"] URLByAppendingPathComponent:@"Themes"];
    
    [[NSFileManager defaultManager] createDirectoryAtURL:dataDirURL
                             withIntermediateDirectories:YES
                                              attributes:nil
                                                   error:NULL];
    
    return [dataDirURL URLByAppendingPathComponent:@"CURRENT_THEME.json"];
}

- (void) copyFileOrElse:(NSURL*)from to:(NSURL*)to {
    NSError*__autoreleasing error;
    if (![[NSFileManager defaultManager] copyItemAtURL:from toURL:to error:&error]) {
        [NSApp presentError:error];
        return; // TODO: probably should just quit actually
    }
}

- (void) copyDefaultThemeMaybe {
    NSURL* currentThemeInAppSupport = [self currentThemeFile];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[currentThemeInAppSupport path]]) {
        NSURL* defaultThemeInBundle = [[NSBundle mainBundle] URLForResource:@"default_leviathan_theme" withExtension:@"json"];
        
        [self copyFileOrElse:defaultThemeInBundle to:currentThemeInAppSupport];
        [self copyFileOrElse:defaultThemeInBundle to:[[currentThemeInAppSupport URLByDeletingLastPathComponent] URLByAppendingPathComponent:@"DefaultTheme.json"]];
    }
}

- (void) loadCurrentTheme {
    NSData* data = [NSData dataWithContentsOfURL:[self currentThemeFile]];
    
    NSError* __autoreleasing error;
    self.attributes = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if (self.attributes == nil) {
        [NSApp presentError:error];
    }
}

- (void) setup {
    [self copyDefaultThemeMaybe];
    [self loadCurrentTheme];
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
