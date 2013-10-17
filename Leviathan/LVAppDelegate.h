//
//  LVAppDelegate.h
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "LVProjectWindowController.h"

@interface LVAppDelegate : NSObject <NSApplicationDelegate, LVProjectWindowController>

@property NSMutableArray *projectWindowControllers;

@end
