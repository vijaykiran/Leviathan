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

@implementation LVAppDelegate

- (NSDictionary*) defaultDefaults {
    return @{@"fontName": @"Menlo",
             @"fontSize": @12};
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [[NSUserDefaults standardUserDefaults] registerDefaults:[self defaultDefaults]];
    [[NSFontManager sharedFontManager] setTarget:self];
    
    self.projectWindowControllers = [NSMutableArray array];
    
    NSURL* tempURL = [NSURL fileURLWithPath:@"/Users/sdegutis/Dropbox/projects/cleancoders.com"];
    
    LVProjectWindowController* controller = [LVProjectWindowController openWith:tempURL
                                                                       delegate:self];
    
    [self.projectWindowControllers addObject:controller];
    
    
    
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

@end
