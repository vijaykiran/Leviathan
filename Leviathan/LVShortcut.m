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

@implementation LVShortcut

+ (LVShortcut*) with:(NSArray*)combos {
    if (![[combos firstObject] isKindOfClass:[NSArray self]])
        combos = @[combos];
    
    LVShortcut* shortcut = [[LVShortcut alloc] init];
    
    NSMutableArray* keyEquivStrings = [NSMutableArray array];
    NSMutableArray* orderedCombos = [NSMutableArray array];
    
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
        
        [keyEquivStrings addObject:[NSString stringWithFormat:@"%@\t%@", [self buildPrettyMods:prettyMods], [key capitalizedString]]];
        [orderedCombos addObject:@[@(keyCode), @(testMods)]];
    }
    
    shortcut.keyEquivalentString = [keyEquivStrings componentsJoinedByString:@", "];
    shortcut.orderedCombos = orderedCombos;
    
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
