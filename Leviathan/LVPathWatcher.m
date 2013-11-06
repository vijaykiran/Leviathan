//
//  LVPathWatcher.m
//  Leviathan
//
//  Created by Steven Degutis on 11/6/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVPathWatcher.h"

@interface LVPathWatcher ()

@property FSEventStreamRef stream;
@property (copy) void(^handler)();

@end

@implementation LVPathWatcher

void fsEventsCallback(ConstFSEventStreamRef streamRef, void *clientCallBackInfo, size_t numEvents, void *eventPaths, const FSEventStreamEventFlags eventFlags[], const FSEventStreamEventId eventIds[])
{
    LVPathWatcher* watcher = (__bridge LVPathWatcher*)clientCallBackInfo;
    [watcher fileChanged];
}

- (void) dealloc {
    if (self.stream) {
        FSEventStreamStop(self.stream);
        FSEventStreamInvalidate(self.stream);
        FSEventStreamRelease(self.stream);
    }
}

+ (LVPathWatcher*) watcherFor:(NSURL*)url handler:(void(^)())handler {
    LVPathWatcher* watcher = [[LVPathWatcher alloc] init];
    watcher.handler = handler;
    [watcher setup:url];
    return watcher;
}

- (void) setup:(NSURL*)url {
    FSEventStreamContext context;
    context.info = (__bridge void*)self;
    context.version = 0;
    context.retain = NULL;
    context.release = NULL;
    context.copyDescription = NULL;
    self.stream = FSEventStreamCreate(NULL,
                                      fsEventsCallback,
                                      &context,
                                      (__bridge CFArrayRef)@[[[url path] stringByStandardizingPath]],
                                      kFSEventStreamEventIdSinceNow,
                                      0.4,
                                      kFSEventStreamCreateFlagWatchRoot | kFSEventStreamCreateFlagNoDefer | kFSEventStreamCreateFlagFileEvents);
    FSEventStreamScheduleWithRunLoop(self.stream, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    FSEventStreamStart(self.stream);
}

- (void) fileChanged {
    self.handler();
}

@end
