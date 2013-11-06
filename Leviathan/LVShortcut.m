//
//  LVShortcut.m
//  Leviathan
//
//  Created by Steven Degutis on 11/6/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVShortcut.h"

@implementation LVShortcut

+ (LVShortcut*) withAction:(SEL)action mods:(NSArray*)mods key:(NSString*)key {
//    static NSDictionary* replacements;
//    if (!replacements) replacements = @{@"{": @"[",
//                                        @"}": @"]",
//                                        };
//    
//    NSString* replacement = [replacements objectForKey:key];
//    if (replacement) key = replacement;
    
    LVShortcut* shortcut = [[LVShortcut alloc] init];
    shortcut.key = key;
    shortcut.action = action;
    
    shortcut.mods = 0;
    if ([mods containsObject:@"cmd"]) shortcut.mods |= NSCommandKeyMask;
    if ([mods containsObject:@"ctrl"]) shortcut.mods |= NSControlKeyMask;
    if ([mods containsObject:@"alt"]) shortcut.mods |= NSAlternateKeyMask;
    if ([mods containsObject:@"shift"]) shortcut.mods |= NSShiftKeyMask;
    if ([mods containsObject:@"fn"]) shortcut.mods |= NSFunctionKeyMask;
    
    [shortcut setupKeyEquivalentString];
    return shortcut;
}

- (void) setupKeyEquivalentString {
    NSMutableString* string = [NSMutableString string];
    if (self.mods & NSControlKeyMask) [string appendString:@"⌃"];
    if (self.mods & NSAlternateKeyMask) [string appendString:@"⌥"];
    if (self.mods & NSShiftKeyMask) [string appendString:@"⇧"];
    if (self.mods & NSCommandKeyMask) [string appendString:@"⌘"];
    if (self.mods & NSFunctionKeyMask) [string appendString:@"Fn"];
    
    NSString* s;
    if ([self.key isEqualToString:@" "]) s = @"⎵";
    else s = [self.key uppercaseString];
    
    [string appendFormat:@"\t%@", s];
    self.keyEquivalentString = string;
}

- (BOOL) matches:(NSEvent*)event {
    // if theres a :shift mod, then the KEY must be one that requires the shift key
    
    if (![[event charactersIgnoringModifiers] isEqualToString: self.key])
        return NO;
    
    if (([event modifierFlags] & NSDeviceIndependentModifierFlagsMask) != self.mods)
        return NO;
    
    return YES;
}

@end
