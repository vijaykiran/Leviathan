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
@property NSUInteger mods;

@end

@implementation LVShortcut

+ (LVShortcut*) withAction:(SEL)action mods:(NSArray*)mods key:(NSString*)key {
    LVShortcut* shortcut = [[LVShortcut alloc] init];
    shortcut.keyCode = [LVKeyTranslator keyCodeForString:key];
    shortcut.action = action;
    
    if ([mods containsObject:@"cmd"]) shortcut.mods |= NSCommandKeyMask;
    if ([mods containsObject:@"ctrl"]) shortcut.mods |= NSControlKeyMask;
    if ([mods containsObject:@"alt"]) shortcut.mods |= NSAlternateKeyMask;
    if ([mods containsObject:@"shift"]) shortcut.mods |= NSShiftKeyMask;
    if ([mods containsObject:@"fn"]) shortcut.mods |= NSFunctionKeyMask;
    
    shortcut.keyEquivalentString = [NSString stringWithFormat:@"%@\t%@", [self buildPrettyMods:shortcut.mods], [self buildPrettyKey:key]];
    return shortcut;
}

+ (NSString*) buildPrettyKey:(NSString*)key {
    if ([key isEqualToString:@" "]) return @"Space";
    return [key capitalizedString];
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
    if ([event keyCode] != self.keyCode)
        return NO;
    
    NSUInteger mods = self.mods;
    
    if (self.keyCode == kVK_RightArrow ||
        self.keyCode == kVK_LeftArrow ||
        self.keyCode == kVK_UpArrow ||
        self.keyCode == kVK_DownArrow)
        mods |= NSFunctionKeyMask | NSNumericPadKeyMask;
    
    if (([event modifierFlags] & NSDeviceIndependentModifierFlagsMask) != mods)
        return NO;
    
    return YES;
}

@end
