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

@interface LVShortcut ()

@property unsigned short keyCode;
@property NSUInteger prettyMods;
@property NSUInteger testMods;

@end

@implementation LVShortcut

+ (LVShortcut*) withAction:(SEL)action mods:(NSArray*)mods key:(NSString*)key {
    LVShortcut* shortcut = [[LVShortcut alloc] init];
    shortcut.keyCode = [LVKeyTranslator keyCodeForString:key];
    shortcut.action = action;
    
    if ([mods containsObject:@"cmd"]) shortcut.testMods |= NSCommandKeyMask;
    if ([mods containsObject:@"ctrl"]) shortcut.testMods |= NSControlKeyMask;
    if ([mods containsObject:@"alt"]) shortcut.testMods |= NSAlternateKeyMask;
    if ([mods containsObject:@"shift"]) shortcut.testMods |= NSShiftKeyMask;
    if ([mods containsObject:@"fn"]) shortcut.testMods |= NSFunctionKeyMask;
    
    shortcut.prettyMods = shortcut.testMods;
    if (shortcut.keyCode == kVK_RightArrow ||
        shortcut.keyCode == kVK_LeftArrow ||
        shortcut.keyCode == kVK_UpArrow ||
        shortcut.keyCode == kVK_DownArrow)
        shortcut.testMods |= NSFunctionKeyMask | NSNumericPadKeyMask;
    
    shortcut.keyEquivalentString = [NSString stringWithFormat:@"%@\t%@", [self buildPrettyMods:shortcut.prettyMods], [key capitalizedString]];
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

- (BOOL) matches:(NSEvent*)event {
    return ([event keyCode] == self.keyCode &&
            ([event modifierFlags] & NSDeviceIndependentModifierFlagsMask) == self.testMods);
}

@end
