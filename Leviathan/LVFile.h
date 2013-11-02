//
//  LVFile.h
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LVClojureTextStorage.h"

@interface LVFile : NSObject

+ (LVFile*) fileWithURL:(NSURL*)theURL shortName:(NSString*)shortName longName:(NSString*)longName;

@property NSURL* fileURL;
@property NSString* longName;
@property NSString* shortName;

@property LVClojureTextStorage* clojureTextStorage;

- (void) save;
- (BOOL) hasChanges;

@end
