//
//  LVShortcut.m
//  Leviathan
//
//  Created by Steven Degutis on 11/6/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVShortcut.h"

#import "LVKeyTranslator.h"
#import <Carbon/Carbon.h>

@implementation LVShortcutString

- (NSString*) joinedWithTab {
    return [NSString stringWithFormat:@"%@\t%@", self.mods, self.key];
}

- (NSString*) joinedWithoutTab {
    return [NSString stringWithFormat:@"%@ %@", self.mods, self.key];
}

@end

@implementation LVShortcut

+ (LVShortcut*) with:(NSArray*)combos {
    if (![[combos firstObject] isKindOfClass:[NSArray self]])
        combos = @[combos];
    
    LVShortcut* shortcut = [[LVShortcut alloc] init];
    
    shortcut.keyEquivalentStrings = [NSMutableArray array];
    shortcut.orderedCombos = [NSMutableArray array];
    
    for (NSArray* combo in combos) {
        NSMutableArray* mods = [combo mutableCopy];
        NSString* key = [mods lastObject];
        [mods removeLastObject];
        
        NSUInteger keyCode = [LVKeyTranslator keyCodeForString:key];
        NSUInteger testMods = 0;
        
        if ([mods containsObject:@"cmd"]) testMods |= NSCommandKeyMask;
        if ([mods containsObject:@"ctrl"]) testMods |= NSControlKeyMask;
        if ([mods containsObject:@"alt"]) testMods |= NSAlternateKeyMask;
        if ([mods containsObject:@"shift"]) testMods |= NSShiftKeyMask;
        if ([mods containsObject:@"fn"]) testMods |= NSFunctionKeyMask;
        
        NSUInteger prettyMods = testMods;
        if (keyCode == kVK_RightArrow ||
            keyCode == kVK_LeftArrow ||
            keyCode == kVK_UpArrow ||
            keyCode == kVK_DownArrow)
            testMods |= NSFunctionKeyMask | NSNumericPadKeyMask;
        
        LVShortcutString* shortcutString = [[LVShortcutString alloc] init];
        shortcutString.mods = [self buildPrettyMods:prettyMods];
        shortcutString.key = [key capitalizedString];
        
        [shortcut.keyEquivalentStrings addObject:shortcutString];
        [shortcut.orderedCombos addObject:@[@(keyCode), @(testMods)]];
    }
    
    return shortcut;
}

+ (NSString*) buildPrettyMods:(NSUInteger)mods {
    NSMutableString* string = [NSMutableString string];
    if (mods & NSControlKeyMask) [string appendString:@"⌃"];
    if (mods & NSAlternateKeyMask) [string appendString:@"⌥"];
    if (mods & NSShiftKeyMask) [string appendString:@"⇧"];
    if (mods & NSCommandKeyMask) [string appendString:@"⌘"];
    if (mods & NSFunctionKeyMask) [string appendString:@"Fn"];
    return string;
}

@end
