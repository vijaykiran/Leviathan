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

@interface LVShortcutHandler ()

@property id globalKeyDownObserver;
@property NSMutableArray* shortcuts;

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
        
//        NSMenu* menu = [[[NSApp menu] itemWithTitle:@"Paredit"] submenu];
//        [menu performActionForItemAtIndex:[menu indexOfItemWithTarget:nil andAction:shortcut.action]];
        
        return nil;
    }
    
//    NSLog(@"%@", event);
    return event;
}

- (void) adjustMenuItemStrings {
//    NSMutableParagraphStyle* pStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
//    [pStyle setTabStops:@[[[NSTextTab alloc] initWithType:NSLeftTabStopType location:100.0]]];
//    NSMenu* menu = [[[NSApp menu] itemWithTitle:@"Paredit"] submenu];
//    NSDictionary* attrs = @{NSFontAttributeName: [NSFont systemFontOfSize:14], NSParagraphStyleAttributeName: pStyle};
//    [[[menu itemArray] objectAtIndex:0] setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Foobar\t⌘K, ⌘B" attributes:attrs]];
//    [[[menu itemArray] objectAtIndex:1] setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Bazquux\t⌘K" attributes:attrs]];
}

- (void) reloadKeyBindings {
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
    self.globalKeyDownObserver = [NSEvent addLocalMonitorForEventsMatchingMask:NSKeyDownMask
                                                                       handler:^NSEvent*(NSEvent* event) {
                                                                           return [self handleEvent:event];
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
