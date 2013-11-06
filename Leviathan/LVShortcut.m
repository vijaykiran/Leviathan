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
    shortcut.mods = mods;
    return shortcut;
}

- (NSString*) keyEquivalentString {
    NSMutableString* string = [NSMutableString string];
    if ([self.mods containsObject:@"ctrl"]) [string appendString:@"⌃"];
    if ([self.mods containsObject:@"alt"]) [string appendString:@"⌥"];
    if ([self.mods containsObject:@"shift"]) [string appendString:@"⇧"];
    if ([self.mods containsObject:@"cmd"]) [string appendString:@"⌘"];
    
    NSString* s;
    if ([self.key isEqualToString:@" "]) s = @"⎵";
    else s = [self.key uppercaseString];
    
    [string appendFormat:@"\t%@", s];
    return string;
}

- (BOOL) matches:(NSEvent*)event {
    // if theres a :shift mod, then the KEY must be one that requires the shift key
    
    if (![[event charactersIgnoringModifiers] isEqualToString: self.key])
        return NO;
    
    NSMutableArray* needsMods = [NSMutableArray array];
    
    if ([event modifierFlags] & NSCommandKeyMask) [needsMods addObject:@"cmd"];
    if ([event modifierFlags] & NSShiftKeyMask) [needsMods addObject:@"shift"];
    if ([event modifierFlags] & NSControlKeyMask) [needsMods addObject:@"ctrl"];
    if ([event modifierFlags] & NSAlternateKeyMask) [needsMods addObject:@"alt"];
    
    if (![needsMods isEqualToArray: self.mods])
        return NO;
    
    return YES;
}

@end
