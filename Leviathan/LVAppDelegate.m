//
//  LVAppDelegate.m
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVAppDelegate.h"

#import "LVPreferences.h"
#import "LVThemeManager.h"

#import "LVShortcutHandler.h"

@interface LVAppDelegate ()

@property BOOL quitting;

@property LVShortcutHandler* shortcutHandler;
@property LVAutoUpdater* autoUpdater;
@property LVUpdateWindowController* updateWindowController;

@end

@implementation LVAppDelegate

- (NSDictionary*) defaultDefaults {
    return @{@"fontName": @"Menlo",
             @"fontSize": @12,
             @"currentThemeName": LVDefaultThemeName};
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    self.quitting = YES;
    
    BOOL anyCantClose = NO;
    
    for (LVProjectWindowController* c in [self.projectWindowControllers copy]) {
        if (![c tryClosingCompletely])
            anyCantClose = YES;
    }
    
    return (anyCantClose ? NSTerminateCancel : NSTerminateNow);
}

- (IBAction) openProject:(id)sender {
    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
    openPanel.canChooseDirectories = YES;
    openPanel.canChooseFiles = NO;
    openPanel.allowsMultipleSelection = NO;
    if ([openPanel runModal] == NSFileHandlingPanelOKButton) {
        [self openProjectForURL:[openPanel URL]];
    }
}

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename {
    [self openProjectForURL:[NSURL fileURLWithPath:filename]];
    return YES;
}

- (IBAction) openDocument:(id)sender {
    [self openProject:sender];
}

- (void) saveProjects {
    NSArray* projectURLs = [self.projectWindowControllers valueForKeyPath:@"project.projectURL"];
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:projectURLs];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"savedProjects"];
}

- (void) restoreProjects {
    NSData* data = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedProjects"];
    if (!data)
        return;
    
    NSArray* projectURLs = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    for (NSURL* url in projectURLs) {
        [self openProjectForURL:url];
    }
}

- (IBAction) enterModalityMode:(id)sender {
    [self.shortcutHandler enterModalityMode];
}

- (IBAction) exitModalityMode:(id)sender {
    [self.shortcutHandler exitModalityMode];
}

- (NSURL*) findProjectFor:(NSURL*)url {
    NSURL* origURL = url;
    
    while (![[url pathComponents] isEqualToArray:@[@"/"]]) {
        NSArray* contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:url
                                                          includingPropertiesForKeys:@[]
                                                                             options:NSDirectoryEnumerationSkipsSubdirectoryDescendants
                                                                               error:NULL];
        if ([[contents valueForKey:@"lastPathComponent"] containsObject:@"project.clj"])
            return url;
        
        url = [[url URLByDeletingLastPathComponent] URLByStandardizingPath];
    }
    
    return origURL;
}

- (LVProjectWindowController*) openProjectForURL:(NSURL*)url {
    url = [self findProjectFor:url];
    
    for (LVProjectWindowController* existing in self.projectWindowControllers) {
        if ([existing.project.projectURL isEqual: url]) {
            return existing;
        }
    }
    
    LVProjectWindowController* controller = [LVProjectWindowController openWith:url delegate:self];
    [self.projectWindowControllers addObject:controller];
    [self saveProjects];
    [[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:url];
    return controller;
}

- (IBAction) revealSettingsFolder:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[LVPreferences settingsDirectory]];
}

- (IBAction) useDifferentSettingsFolder:(id)sender {
    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
    openPanel.canChooseDirectories = YES;
    openPanel.canChooseFiles = NO;
    openPanel.allowsMultipleSelection = NO;
    if ([openPanel runModal] == NSFileHandlingPanelOKButton) {
        [LVPreferences setSettingsDirectory:[openPanel URL]];
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    self.shortcutHandler = [[LVShortcutHandler alloc] init];
    [self.shortcutHandler setup];
    
    self.autoUpdater = [[LVAutoUpdater alloc] init];
    self.autoUpdater.delegate = self;
    [self.autoUpdater startChecking];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:[self defaultDefaults]];
    [[NSFontManager sharedFontManager] setTarget:self];
    
    [[LVThemeManager sharedThemeManager] loadTheme];
    
    self.projectWindowControllers = [NSMutableArray array];
    
    [self restoreProjects];
}

- (IBAction) editSettingsFile:(id)sender {
    LVProjectWindowController* pc = [self openProjectForURL:[LVPreferences settingsDirectory]];
    [pc editFileWithLongName:@"Settings.clj"];
}

- (IBAction) editCurrentThemeFile:(id)sender {
    LVProjectWindowController* pc = [self openProjectForURL:[LVPreferences settingsDirectory]];
    [pc editFileWithLongName:[@"Themes" stringByAppendingPathComponent:[LVPreferences theme]]];
}

- (void) projectWindowClosed:(LVProjectWindowController *)controller {
    [self.projectWindowControllers removeObject:controller];
    
    if (!self.quitting)
        [self saveProjects];
}

- (void)changeFont:(id)sender {
    [LVPreferences setUserFont: [sender convertFont:[LVPreferences userFont]]];
}

- (void) updateIsAvailable:(NSString*)version notes:(NSString*)notes {
    self.updateWindowController = [[LVUpdateWindowController alloc] init];
    self.updateWindowController.version = version;
    self.updateWindowController.notes = notes;
    self.updateWindowController.updateDelegate = self;
    [self.updateWindowController showWindow:self];
}

- (void) userWantsUpdate {
    self.updateWindowController = nil;
    [self.autoUpdater updateApp];
}

- (void) userHatesUs {
    self.updateWindowController = nil;
}

@end
