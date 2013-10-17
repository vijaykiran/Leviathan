//
//  LVProject.m
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVProject.h"

@implementation LVProject

+ (LVProject*) openProjectAtURL:(NSURL*)url {
    LVProject* p = [[LVProject alloc] init];
    p.projectURL = url;
    p.files = [NSMutableArray array];
    // TODO: preload all files in project
    return p;
}

- (LVFile*) openNewFile {
    LVFile* file = [[LVFile alloc] init];
    // TODO: set file properties
    [self.files addObject:file];
    return file;
}

@end
