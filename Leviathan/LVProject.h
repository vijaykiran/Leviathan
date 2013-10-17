//
//  LVProject.h
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LVFile.h"

@interface LVProject : NSObject

@property NSURL *projectURL;
@property NSMutableArray* files;

+ (LVProject*) openProjectAtURL:(NSURL*)url;

- (LVFile*) openNewFile;

@end
