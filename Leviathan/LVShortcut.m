//
//  LVShortcut.m
//  Leviathan
//
//  Created by Steven Degutis on 11/6/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVShortcut.h"

@implementation LVShortcut

- (NSString*) keyEquivalentString {
    NSMutableString* string = [NSMutableString string];
    if ([self.mods containsObject:@"ctrl"]) [string appendString:@"⌃"];
    if ([self.mods containsObject:@"alt"]) [string appendString:@"⌥"];
    if ([self.mods containsObject:@"shift"]) [string appendString:@"⇧"];
    if ([self.mods containsObject:@"cmd"]) [string appendString:@"⌘"];
    
    NSString* s;
    if ([self.key isEqualToString:@" "]) s = @"Space";
    else s = [self.key uppercaseString];
    
    [string appendFormat:@"\t%@", s];
    return string;
}

@end
