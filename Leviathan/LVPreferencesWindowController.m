//
//  LVPreferencesWindowController.m
//  Leviathan
//
//  Created by Steven on 10/18/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVPreferencesWindowController.h"

#import "LVPreferences.h"
#import "LVThemeManager.h"

@interface LVPreferencesWindowController ()

@property (weak) IBOutlet NSPopUpButton* themesButton;

@end

@implementation LVPreferencesWindowController

+ (LVPreferencesWindowController*) sharedPreferencesWindowController {
    static LVPreferencesWindowController* sharedPreferencesWindowController;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPreferencesWindowController = [[LVPreferencesWindowController alloc] init];
    });
    return sharedPreferencesWindowController;
}

- (NSString*) windowNibName {
    return @"PreferencesWindow";
}

- (void) showWindow:(id)sender {
    NSDisableScreenUpdates();
    [super showWindow:sender];
    [[self window] center];
    [self setupThemeNames];
    NSEnableScreenUpdates();
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction) moveSettingsDirectory:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[LVPreferences settingsDirectory]];
}

- (void) setupThemeNames {
    NSArray* names = [[LVThemeManager sharedThemeManager] potentialThemeNames];
    [self.themesButton removeAllItems];
    [self.themesButton addItemsWithTitles:names];
    [self.themesButton sizeToFit];
}

- (IBAction) changeTheme:(id)sender {
    NSString* newTheme = [self.themesButton titleOfSelectedItem];
    [LVPreferences setTheme:newTheme];
}

@end
