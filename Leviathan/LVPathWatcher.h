//
//  LVPathWatcher.h
//  Leviathan
//
//  Created by Steven Degutis on 11/6/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LVPathWatcher : NSObject

+ (LVPathWatcher*) watcherFor:(NSURL*)url handler:(void(^)())handler;

@end
