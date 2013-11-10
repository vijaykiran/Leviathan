//
//  LVEmbeddedRepl.m
//  Leviathan
//
//  Created by Steven Degutis on 11/10/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVEmbeddedRepl.h"

@interface LVEmbeddedRepl ()

@property NSTask* task;
@property NSPipe* outputPipe;
@property NSPipe* inputPipe;

@end

@implementation LVEmbeddedRepl

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) applicationWillTerminate:(NSNotification*)note {
    [self closePipes];
//    pid_t p = [self.task processIdentifier];
//    [self.task terminate];
//    kill(p, SIGKILL);
    self.task = nil;
}

- (void) closePipes {
    [self.inputPipe.fileHandleForWriting closeFile];
    [self.outputPipe.fileHandleForReading closeFile];
    self.inputPipe = nil;
    self.outputPipe = nil;
}

- (void) open {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:NSApplicationWillTerminateNotification object:nil];
    
    self.task = [[NSTask alloc] init];
    
    self.inputPipe = [NSPipe pipe];
    self.outputPipe = [NSPipe pipe];
    
    self.task.standardInput = [self.inputPipe fileHandleForReading];
    self.task.standardOutput = [self.outputPipe fileHandleForWriting];
    
    NSMutableString* buffer = [NSMutableString string];
    __weak LVEmbeddedRepl* _self = self;
    
    [self.outputPipe fileHandleForReading].readabilityHandler = ^(NSFileHandle* handle) {
        NSString* str = [[NSString alloc] initWithData:[handle availableData] encoding:NSUTF8StringEncoding];
        [buffer appendString:str];
        
        NSUInteger endPos = [buffer rangeOfString:@" on host"].location;
        
        if (endPos != NSNotFound) {
            NSUInteger startPos = NSMaxRange([buffer rangeOfString:@"on port "]);
            NSString* portString = [buffer substringWithRange:NSMakeRange(startPos, endPos - startPos)];
            [_self.outputPipe fileHandleForReading].readabilityHandler = nil;
            _self.ready([portString integerValue]);
            _self.ready = nil;
        }
    };
    
    self.task.currentDirectoryPath = [self.baseURL path];
    self.task.launchPath = @"/Users/sdegutis/bin/lein";
    self.task.arguments = @[@"repl"];
    [self.task launch];
}

@end
