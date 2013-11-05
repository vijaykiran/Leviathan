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

#import "LVTestBed.h"

@interface LVAppDelegate ()

@property IBOutlet NSMenuItem* closeWindowItem;
@property IBOutlet NSMenuItem* closeTabItem;
@property IBOutlet NSMenuItem* closeSplitItem;
@property IBOutlet NSMenuItem* closeItem;

@property BOOL quitting;

@end

@implementation LVAppDelegate

- (NSDictionary*) defaultDefaults {
    return @{@"fontName": @"Menlo",
             @"fontSize": @12,
             @"currentThemeName": @"Default.clj"};
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

- (IBAction) openDocument:(id)sender {
    NSOpenPanel* openPanel = [NSOpenPanel openPanel];
    openPanel.canChooseDirectories = YES;
    openPanel.canChooseFiles = NO;
    openPanel.allowsMultipleSelection = NO;
    if ([openPanel runModal] == NSFileHandlingPanelOKButton) {
        [self openProjectForURL:[openPanel URL]];
    }
}

- (void) saveProjects {
    NSArray* projectURLs = [self.projectWindowControllers valueForKeyPath:@"project.projectURL"];
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:projectURLs];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"savedProjects"];
}

- (void) restoreProjects {
    NSData* data = [[NSUserDefaults standardUserDefaults] objectForKey:@"savedProjects"];
    NSArray* projectURLs = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    for (NSURL* url in projectURLs) {
        [self openProjectForURL:url];
    }
}

- (void) openProjectForURL:(NSURL*)url {
    LVProjectWindowController* controller = [LVProjectWindowController openWith:url delegate:self];
    [self.projectWindowControllers addObject:controller];
    [self saveProjects];
}

- (void) expireSoon {
    NSString* s = [NSString stringWithFormat:@"%s, %s", __DATE__, __TIME__];
    NSDate* compileDate = [NSDate dateWithNaturalLanguageString:s];
    
    NSDate* fireDate = [compileDate dateByAddingTimeInterval:60.0 * 60.0 * 24.0 * 7.0];
    
    NSTimer* expirationTimer = [[NSTimer alloc] initWithFireDate:fireDate interval:0 target:self selector:@selector(quitTrial:) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:expirationTimer forMode:NSRunLoopCommonModes];
}

- (void) quitTrial:(NSTimer*)timer {
    NSRunAlertPanel(@"This build has expired", @"I've probably got a new build. If I haven't sent it to you, please email me.\n\nAfter you close this popup, you've got 3 minutes to save your work.", @"OK", @"", nil);
    
    double delayInSeconds = 60.0 * 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        exit(1);
    });
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [LVTestBed runTests];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:[self defaultDefaults]];
    [[NSFontManager sharedFontManager] setTarget:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(windowDidBecomeKey:)
                                                 name:NSWindowDidBecomeKeyNotification
                                               object:nil];
    
    [[LVThemeManager sharedThemeManager] loadThemes];
    
    self.projectWindowControllers = [NSMutableArray array];
    
    [self restoreProjects];
    
    [self expireSoon];
}

- (void) projectWindowClosed:(LVProjectWindowController *)controller {
    [self.projectWindowControllers removeObject:controller];
    
    if (!self.quitting)
        [self saveProjects];
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
