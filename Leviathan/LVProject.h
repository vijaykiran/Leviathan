//
//  LVProject.h
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LVFile.h"


@interface LVProjectTreeItem : NSObject
@property NSString* name;
@property NSMutableArray* children;
@property LVFile* file;
@end


@interface LVProject : NSObject

@property NSURL *projectURL;
@property NSMutableArray* files;

@property LVProjectTreeItem* fileTree;

+ (LVProject*) openProjectAtURL:(NSURL*)url;

- (LVFile*) openNewFile;

@end
