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

+ (LVShortcut*) withMods:(NSArray*)mods key:(NSString*)key {
    LVShortcut* shortcut = [[LVShortcut alloc] init];
    
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
    
    shortcut.keyEquivalentString = [NSString stringWithFormat:@"%@\t%@", [self buildPrettyMods:prettyMods], [key capitalizedString]];
    shortcut.combo = @[@(keyCode), @(testMods)];
    
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
