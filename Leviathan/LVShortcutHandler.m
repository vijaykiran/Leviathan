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
        if (![[event charactersIgnoringModifiers] isEqualToString: shortcut.key])
            continue;
        
        NSMutableArray* needsMods = [NSMutableArray array];
        
        if ([event modifierFlags] & NSCommandKeyMask) [needsMods addObject:@"cmd"];
        if ([event modifierFlags] & NSShiftKeyMask) [needsMods addObject:@"shift"];
        if ([event modifierFlags] & NSControlKeyMask) [needsMods addObject:@"ctrl"];
        if ([event modifierFlags] & NSAlternateKeyMask) [needsMods addObject:@"alt"];
        
        if (![needsMods isEqualToArray: shortcut.mods])
            continue;
        
        [NSApp sendAction:shortcut.action to:nil from:nil];
        
        return nil;
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
    NSMenu* menu = [[[NSApp menu] itemWithTitle:@"Paredit"] submenu];
    
    NSNumber* longestTitleLen = [[menu itemArray] valueForKeyPath:@"title.@max.length"];
    
    NSMutableParagraphStyle* pStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    [pStyle setTabStops:@[]];
    [pStyle addTabStop:[[NSTextTab alloc] initWithType:NSRightTabStopType location:[longestTitleLen doubleValue] * 8.75]];
    [pStyle addTabStop:[[NSTextTab alloc] initWithType:NSLeftTabStopType location:[longestTitleLen doubleValue] * 8.75 + 5]];
    NSDictionary* attrs = @{NSFontAttributeName: [NSFont systemFontOfSize:14], NSParagraphStyleAttributeName: pStyle};
    
    for (NSMenuItem* item in [menu itemArray]) {
        NSString* title = [item title];
        
        LVShortcut* shortcut = [self shortcutForAction:[item action]];
        NSString* modsString = [shortcut keyEquivalentString];
        NSString* newTitle = [NSString stringWithFormat:@"%@\t%@", title, modsString];
        NSAttributedString* attrTitle = [[NSAttributedString alloc] initWithString:newTitle attributes:attrs];
        [item setAttributedTitle:attrTitle];
    }
}

- (void) reloadKeyBindings {
    NSLog(@"relaoding");
    self.shortcuts = [NSMutableArray array];
    
    NSDictionary* shortcuts = LVParseConfigFromString([self keybindingsFileURL]);
    for (NSString* selName in shortcuts) {
        NSMutableArray* mods = [[shortcuts objectForKey:selName] mutableCopy];
        NSString* key = [mods lastObject];
        [mods removeLastObject];
        [self addShortcut:NSSelectorFromString(selName) mods:mods key:key];
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

- (void) addShortcut:(SEL)action mods:(NSArray*)mods key:(NSString*)key {
    LVShortcut* shortcut = [[LVShortcut alloc] init];
    shortcut.key = key;
    shortcut.action = action;
    shortcut.mods = mods;
    [self.shortcuts addObject:shortcut];
}

@end
