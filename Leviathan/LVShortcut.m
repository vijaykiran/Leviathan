//
//  LVShortcut.m
//  Leviathan
//
//  Created by Steven Degutis on 11/6/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVShortcut.h"

@interface LVShortcut ()

@property unichar matchKey;
@property NSUInteger mods;

@end

@implementation LVShortcut

+ (LVShortcut*) withAction:(SEL)action mods:(NSArray*)mods key:(NSString*)key {
    LVShortcut* shortcut = [[LVShortcut alloc] init];
    shortcut.matchKey = [self buildMatchKey:key];
    shortcut.action = action;
    
    if ([mods containsObject:@"cmd"]) shortcut.mods |= NSCommandKeyMask;
    if ([mods containsObject:@"ctrl"]) shortcut.mods |= NSControlKeyMask;
    if ([mods containsObject:@"alt"]) shortcut.mods |= NSAlternateKeyMask;
    if ([mods containsObject:@"shift"]) shortcut.mods |= NSShiftKeyMask;
    if ([mods containsObject:@"fn"]) shortcut.mods |= NSFunctionKeyMask;
    
    if (shortcut.matchKey == NSUpArrowFunctionKey ||
        shortcut.matchKey == NSDownArrowFunctionKey ||
        shortcut.matchKey == NSLeftArrowFunctionKey ||
        shortcut.matchKey == NSRightArrowFunctionKey)
        shortcut.mods |= NSFunctionKeyMask | NSNumericPadKeyMask;
    
//    NSLog(@"%s %d", sel_getName(action), shortcut.matchKey);
    
    shortcut.keyEquivalentString = [NSString stringWithFormat:@"%@\t%@", [self buildPrettyMods:shortcut.mods], [self buildPrettyKey:shortcut.matchKey]];
    return shortcut;
}

+ (unichar) buildMatchKey:(NSString*)key {
//    if ([key isEqualToString:@"RETURN"]) shortcut.matchKey = kVK_Return;
//    if ([key isEqualToString:@"TAB"]) shortcut.matchKey = kVK_Tab;
//    if ([key isEqualToString:@"SPACE"]) shortcut.matchKey = kVK_Space;
//    if ([key isEqualToString:@"DELETE"]) shortcut.matchKey = kVK_Delete;
//    if ([key isEqualToString:@"ESCAPE"]) shortcut.matchKey = kVK_Escape;
//    if ([key isEqualToString:@"HELP"]) shortcut.matchKey = kVK_Help;
//    if ([key isEqualToString:@"HOME"]) shortcut.matchKey = kVK_Home;
//    if ([key isEqualToString:@"PAGE_UP"]) shortcut.matchKey = kVK_PageUp;
//    if ([key isEqualToString:@"FORWARD_DELETE"]) shortcut.matchKey = kVK_ForwardDelete;
//    if ([key isEqualToString:@"END"]) shortcut.matchKey = kVK_End;
//    if ([key isEqualToString:@"PAGE_DOWN"]) shortcut.matchKey = kVK_PageDown;
    if ([[key uppercaseString] isEqualToString:@"LEFT"]) return NSLeftArrowFunctionKey;
    if ([[key uppercaseString] isEqualToString:@"RIGHT"]) return NSRightArrowFunctionKey;
    if ([[key uppercaseString] isEqualToString:@"DOWN"]) return NSDownArrowFunctionKey;
    if ([[key uppercaseString] isEqualToString:@"UP"]) return NSUpArrowFunctionKey;
    return [key characterAtIndex:0];
}

+ (NSString*) buildPrettyKey:(unichar)key {
    if (key == NSLeftArrowFunctionKey) return @"Left";
    if (key == NSRightArrowFunctionKey) return @"Right";
    if (key == NSDownArrowFunctionKey) return @"Down";
    if (key == NSUpArrowFunctionKey) return @"Up";
    if (key == ' ') return @"Space";
    
    return [[NSString stringWithFormat:@"%C", key] uppercaseString];
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
    // if theres a :shift mod, then the KEY must be one that requires the shift key
    
    if ([[event charactersIgnoringModifiers] characterAtIndex:0] != self.matchKey)
        return NO;
    
    if (([event modifierFlags] & NSDeviceIndependentModifierFlagsMask) != self.mods)
        return NO;
    
    return YES;
}

@end
