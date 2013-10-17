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
}

- (void) projectWindowClosed:(LVProjectWindowController *)controller {
    [self.projectWindowControllers removeObject:controller];
}

@end
