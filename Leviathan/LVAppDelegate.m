//
//  LVAppDelegate.m
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVAppDelegate.h"

#import "LVPreferencesWindowController.h"
#import "LVPreferences.h"
#import "LVThemeManager.h"

@interface LVAppDelegate ()

@property IBOutlet NSMenuItem* closeWindowItem;
@property IBOutlet NSMenuItem* closeTabItem;
@property IBOutlet NSMenuItem* closeSplitItem;
@property IBOutlet NSMenuItem* closeItem;

@end

@implementation LVAppDelegate

- (NSDictionary*) defaultDefaults {
    return @{@"fontName": @"Menlo",
             @"fontSize": @12};
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    for (LVProjectWindowController* c in self.projectWindowControllers) {
        if (![c tryClosingCompletely])
            return NSTerminateCancel;
    }
    return NSTerminateNow;
}

- (IBAction) openDocument:(id)sender {
    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
    openPanel.canChooseDirectories = YES;
    openPanel.canChooseFiles = NO;
    openPanel.allowsMultipleSelection = NO;
    if ([openPanel runModal] == NSFileHandlingPanelOKButton) {
        [self openProjectForURL:[openPanel URL]];
    }
}

- (void) openProjectForURL:(NSURL*)url {
    LVProjectWindowController* controller = [LVProjectWindowController openWith:url delegate:self];
    [self.projectWindowControllers addObject:controller];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [[NSUserDefaults standardUserDefaults] registerDefaults:[self defaultDefaults]];
    [[NSFontManager sharedFontManager] setTarget:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(windowDidBecomeKey:)
                                                 name:NSWindowDidBecomeKeyNotification
                                               object:nil];
    
    [[LVThemeManager sharedThemeManager] loadThemes];
    
    self.projectWindowControllers = [NSMutableArray array];
    
    NSURL* tempURL = [NSURL fileURLWithPath:@"/Users/sdegutis/Dropbox/projects/cleancoders.com"];
    [self openProjectForURL:tempURL];
    
    
    
    double delayInSeconds = 60.0 * 5.0; // quit after 5 mins
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [NSApp terminate:self];
    });
}

- (void) projectWindowClosed:(LVProjectWindowController *)controller {
    [self.projectWindowControllers removeObject:controller];
}

- (IBAction) showPreferencesWindow:(id)sender {
    [[LVPreferencesWindowController sharedPreferencesWindowController] showWindow:sender];
}

- (void)changeFont:(id)sender {
    [LVPreferences setUserFont: [sender convertFont:[LVPreferences userFont]]];
}

- (IBAction) reloadCurrentTheme:(id)sender {
    // TODO: hook this up to a menu item somewhere
    [[LVThemeManager sharedThemeManager] loadThemes];
    
    // TODO: send notification of LVCurrentThemeChangedNotification! (meh, boring)
}

- (void) windowDidBecomeKey:(NSNotification*)note {
    NSWindow* window = [note object];
    
    BOOL isProjectWindow = [[window windowController] isKindOfClass:[LVProjectWindowController self]];
    if (isProjectWindow) {
        [self.closeItem setKeyEquivalent:@""];
        [self.closeSplitItem setKeyEquivalent:@"w"];
        [self.closeTabItem setKeyEquivalent:@"w"];
        [self.closeWindowItem setKeyEquivalent:@"W"];
    }
    else {
        [self.closeItem setKeyEquivalent:@"w"];
        [self.closeSplitItem setKeyEquivalent:@""];
        [self.closeTabItem setKeyEquivalent:@""];
        [self.closeWindowItem setKeyEquivalent:@""];
    }
}

@end
