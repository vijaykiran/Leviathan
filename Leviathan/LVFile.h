//
//  LVFile.h
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LVClojureTextStorage.h"

@class LVProject;

@interface LVFile : NSObject

+ (LVFile*) untitledFileInProject:(LVProject*)project;

- (void) loadFromFileURL:(NSURL*)fileURL;
- (void) saveToFileURL:(NSURL*)fileURL;

- (void) save;
- (BOOL) hasChanges;

@property NSURL* fileURL;
@property NSString* longName;
@property NSString* shortName;

@property (weak) LVProject* project;

@property LVClojureTextStorage* clojureTextStorage;

@end
