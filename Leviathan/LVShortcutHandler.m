//
//  LVShortcutHandler.m
//  Leviathan
//
//  Created by Steven Degutis on 11/6/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVShortcutHandler.h"

#import "LVPreferences.h"
#import "LVShortcut.h"

#import "LVPathWatcher.h"

@interface LVShortcutHandler ()

@property id globalKeyDownObserver;
@property NSMutableDictionary* shortcutCombos;
@property NSMutableDictionary* shortcutKeyEquivalents;

@property LVPathWatcher* pathWatcher;

@end

@implementation LVShortcutHandler

- (NSURL*) keybindingsFileURL {
    NSURL* settingsDestURL = [[LVPreferences settingsDirectory] URLByAppendingPathComponent:@"Keybindings.clj"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[settingsDestURL path]]) {
        NSURL* origFile = [[NSBundle mainBundle] URLForResource:@"Keybindings" withExtension:@"clj"];
        [[NSFileManager defaultManager] copyItemAtURL:origFile
                                                toURL:settingsDestURL
                                                error:NULL];
    }
    
    return settingsDestURL;
}

- (NSEvent*) handleEvent:(NSEvent*)event {
    NSArray* combo = @[@([event keyCode]), @([event modifierFlags] & NSDeviceIndependentModifierFlagsMask)];
    NSString* action = [self.shortcutCombos objectForKey:combo];
    
    if (action) {
        SEL sel = NSSelectorFromString(action);
        BOOL worked = [NSApp sendAction:sel to:nil from:nil];
        if (worked)
            return nil;
    }
    
    return event;
}

- (void) adjustMenuItemStrings {
    NSArray* specialMenus = @[@"Project", @"Paredit"];
    
    for (NSString* specialMenu in specialMenus) {
        NSMenu* menu = [[[NSApp menu] itemWithTitle:specialMenu] submenu];
        
        for (NSMenuItem* item in [menu itemArray]) {
            NSString* title = [item title];
            
            NSUInteger tabLocationInTitle = [title rangeOfString:@"\t"].location;
            if (tabLocationInTitle != NSNotFound)
                title = [title substringToIndex:tabLocationInTitle];
            
            [item setTitle:title];
        }
        
        NSNumber* longestTitleLen = [[menu itemArray] valueForKeyPath:@"title.@max.length"];
        CGFloat tabStopLoc = [longestTitleLen doubleValue] * 8.75;
        
        NSMutableParagraphStyle* pStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [pStyle setTabStops:@[]];
        [pStyle addTabStop:[[NSTextTab alloc] initWithType:NSRightTabStopType location:tabStopLoc]];
        [pStyle addTabStop:[[NSTextTab alloc] initWithType:NSLeftTabStopType location:tabStopLoc + 2.0]];
        NSDictionary* attrs = @{NSFontAttributeName: [NSFont systemFontOfSize:14], NSParagraphStyleAttributeName: pStyle};
        
        for (NSMenuItem* item in [menu itemArray]) {
            NSString* title = [item title];
            NSString* keyEquiv = self.shortcutKeyEquivalents[NSStringFromSelector([item action])];
            NSString* modsString = (keyEquiv ?: @"");
            NSString* newTitle = [NSString stringWithFormat:@"%@\t%@", title, modsString];
            NSAttributedString* attrTitle = [[NSAttributedString alloc] initWithString:newTitle attributes:attrs];
            [item setAttributedTitle:attrTitle];
        }
    }
}

- (void) reloadKeyBindings {
    self.shortcutCombos = [NSMutableDictionary dictionary];
    self.shortcutKeyEquivalents = [NSMutableDictionary dictionary];
    
    NSDictionary* shortcuts = LVParseConfig([self keybindingsFileURL]);
    for (NSArray* combo in shortcuts) {
        NSString* selName = [shortcuts objectForKey:combo];
        
        LVShortcut* shortcut = [LVShortcut with:combo];
        self.shortcutKeyEquivalents[selName] = shortcut.keyEquivalentString;
        
        NSMutableArray* orderedCombos = [[shortcut.orderedCombos arrayByAddingObject:selName] mutableCopy];
        
        /*
         
         // [cmd-I] = "indent"
         // [cmd-K cmd-R] = "raise"
         // [cmd-K cmd-S] = "splice"
         
         {cmd-I = "indent"}
         {cmd-K = {cmd-R = "raise", cmd-S = "splice"}}
         
         Plan:
         
         1. Combine them, so that:
         
         // [cmd-I, "indent"]
         // [cmd-K, cmd-R, "raise"]
         
         2. Take the last two off, join them as a single key-value dictionary, add it back onto array:
         
         // [{cmd-I: "indent"}]
         // [cmd-K, {cmd-R: "raise"}]
         
         3. Loop until the list only has 1 element. That's the action!
         
         // [{cmd-I: "indent"}]
         // [{cmd-K: {cmd-R: "raise"}}]
         
         // {cmd-I: "indent"}
         // {cmd-K: {cmd-R: "raise"}}
         
         4. But they might have like, hash-key collisions. So we need to add them back into the main one manually.
         
         */
        
        do {
            id action = [orderedCombos lastObject];
            [orderedCombos removeLastObject];
            
            NSArray* combo = [orderedCombos lastObject];
            [orderedCombos removeLastObject];
            
            NSDictionary* combined = @{combo: action};
            [orderedCombos addObject:combined];
        } while ([orderedCombos count] > 1);
        
        NSDictionary* action = [orderedCombos lastObject];
        
        // now add it carefully into the main tree
        
        NSLog(@"%@", action);
        
//        for (NSArray* combo in orderedCombos) {
//            comboGroup[combo] = next;
//        }
    }
    
    [self adjustMenuItemStrings];
}

- (void) setup {
    [self reloadKeyBindings];
    self.globalKeyDownObserver = [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask handler:^NSEvent*(NSEvent* event) {
        return [self handleEvent:event];
    }];
    self.pathWatcher = [LVPathWatcher watcherFor:[self keybindingsFileURL] handler:^{
        [self reloadKeyBindings];
    }];
}

@end
