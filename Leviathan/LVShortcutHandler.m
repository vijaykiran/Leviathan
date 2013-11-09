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

@property NSDictionary* currentChord;

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
    id action = [self.currentChord objectForKey:combo];
    
    if (action) {
        if ([action isKindOfClass:[NSString self]]) {
            // just do it
            
            SEL sel = NSSelectorFromString(action);
            BOOL worked = [NSApp sendAction:sel to:nil from:nil];
            if (worked)
                return nil;
        }
        else {
            self.currentChord = action;
            
            double delayInSeconds = 2.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                self.currentChord = self.shortcutCombos;
                // they took too look
            });
            
            return nil;
        }
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
            
            NSString* keyEquiv;
            NSMutableArray* shortcutStrings = self.shortcutKeyEquivalents[NSStringFromSelector([item action])];
            if (shortcutStrings) {
                LVShortcutString* firstPair = [shortcutStrings objectAtIndex:0];
                [shortcutStrings removeObjectAtIndex:0];
                
                shortcutStrings = [[shortcutStrings valueForKeyPath:@"joinedWithoutTab"] mutableCopy];
                [shortcutStrings insertObject:[firstPair joinedWithTab] atIndex:0];
                
                keyEquiv = [shortcutStrings componentsJoinedByString:@", "];
            }
            else {
                keyEquiv = @"";
            }
            
            NSString* newTitle = [NSString stringWithFormat:@"%@\t%@", title, keyEquiv];
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
        self.shortcutKeyEquivalents[selName] = shortcut.keyEquivalentStrings;
        
        NSMutableArray* orderedCombos = shortcut.orderedCombos;
        
        /*
         
         // [cmd-I] = "indent"
         // [cmd-K cmd-R] = "raise"
         // [cmd-K cmd-S] = "splice"
         
         1. Remove the first one, and keep it.
         2. If the list is empty, just set the action in the current hash.
         3. Otherwise, look for a hash in the current hash by this key, or create one if it's not there. Set it to current hash and loop.
         
         */
        
        NSMutableDictionary* currentHash = self.shortcutCombos;
        
        while ([orderedCombos count] > 1) {
            NSArray* combo = [orderedCombos firstObject];
            [orderedCombos removeObjectAtIndex:0];
            
            NSMutableDictionary* newHash = currentHash[combo];
            if (!newHash) {
                newHash = [NSMutableDictionary dictionary];
                currentHash[combo] = newHash;
            }
            
            currentHash = newHash;
        }
        
        NSArray* combo = [orderedCombos lastObject];
        currentHash[combo] = selName;
    }
    
    self.currentChord = self.shortcutCombos;
    
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
