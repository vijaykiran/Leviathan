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
@property NSMutableArray* shortcuts;

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
    for (LVShortcut* shortcut in self.shortcuts) {
        if ([shortcut matches: event]) {
            [NSApp sendAction:shortcut.action to:nil from:nil];
            return nil;
        }
    }
    
    return event;
}

- (LVShortcut*) shortcutForAction:(SEL)action {
    for (LVShortcut* shortcut in self.shortcuts) {
        if (shortcut.action == action)
            return shortcut;
    }
    return nil;
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
            LVShortcut* shortcut = [self shortcutForAction:[item action]];
            NSString* modsString = (shortcut ? [shortcut keyEquivalentString] : @"");
            NSString* newTitle = [NSString stringWithFormat:@"%@\t%@", title, modsString];
            NSAttributedString* attrTitle = [[NSAttributedString alloc] initWithString:newTitle attributes:attrs];
            [item setAttributedTitle:attrTitle];
        }
    }
}

- (void) reloadKeyBindings {
    self.shortcuts = [NSMutableArray array];
    
    NSDictionary* shortcuts = LVParseConfigFromString([self keybindingsFileURL]);
    for (NSString* selName in shortcuts) {
        NSMutableArray* mods = [[shortcuts objectForKey:selName] mutableCopy];
        NSString* key = [mods lastObject];
        [mods removeLastObject];
        [self.shortcuts addObject:[LVShortcut withAction:NSSelectorFromString(selName) mods:mods key:key]];
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
