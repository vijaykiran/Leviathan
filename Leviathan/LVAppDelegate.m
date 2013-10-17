//
//  LVAppDelegate.m
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVAppDelegate.h"

@implementation LVAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
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

@end
