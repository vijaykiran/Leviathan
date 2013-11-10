//
//  LVNrepl.m
//  Leviathan
//
//  Created by Steven on 11/9/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVNrepl.h"

static NSString* LVEncodeThing(id thing) {
    if ([thing isKindOfClass:[NSNumber self]]) {
        return [NSString stringWithFormat:@"i%lde", [thing integerValue]];
    }
    else if ([thing isKindOfClass:[NSString self]]) {
        return [NSString stringWithFormat:@"%ld:%@", [thing length], thing];
    }
    else if ([thing isKindOfClass:[NSArray self]]) {
        NSMutableString* buffer = [@"l" mutableCopy];
        for (id child in thing) {
            [buffer appendString:LVEncodeThing(child)];
        }
        [buffer appendString:@"e"];
        return buffer;
    }
    else if ([thing isKindOfClass:[NSDictionary self]]) {
        NSMutableString* buffer = [@"d" mutableCopy];
        for (id key in thing) {
            id value = thing[key];
            [buffer appendString:LVEncodeThing(key)];
            [buffer appendString:LVEncodeThing(value)];
        }
        [buffer appendString:@"e"];
        return buffer;
    }
    abort();
}

@interface LVNrepl ()

@property GCDAsyncSocket* socket;
@property NSMutableArray* actions;

@end


@implementation LVNrepl

enum {
    LVNREPL_LISTENING_ANY,
    LVNREPL_LISTENING_INT,
    LVNREPL_LISTENING_STR1,
    LVNREPL_LISTENING_STR2,
};

- (void) connect {
    self.actions = [NSMutableArray array];
    
    NSInteger port = 56046;
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_queue_create("foo", NULL)];
    [self.socket connectToHost:@"localhost" onPort:port error:NULL];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    [self listenForAnything:^(id obj){
        NSLog(@"got it! %@", obj);
    }];
    
    // write a test command
    [self sendMessage:@{@"op": @"eval", @"code": @"(+ 1 2)"}];
}

- (void) sendMessage:(NSDictionary*)msg {
    NSString* outstr = LVEncodeThing(msg);
    [self.socket writeData:[outstr dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:-1];
}

- (void) listenForAnything:(void(^)(id obj))action {
    [self.actions addObject:[action copy]];
    [self.socket readDataToLength:1 withTimeout:-1 tag:LVNREPL_LISTENING_ANY];
}

- (void) popActionWith:(id)obj {
    void (^action)(id) = [self.actions lastObject];
    [self.actions removeLastObject];
    action(obj);
}

- (void) listenForKeyIn:(NSMutableDictionary*)dict {
    [self listenForAnything:^(id key) {
        if (key) {
            [self listenForAnything:^(id val) {
                [dict setObject:val forKey:key];
                [self listenForKeyIn:dict];
            }];
        }
        else {
            [self popActionWith:dict];
        }
    }];
}

- (void) listenForElementIn:(NSMutableArray*)array {
    [self listenForAnything:^(id obj) {
        if (obj) {
            [array addObject:obj];
            [self listenForElementIn:array];
        }
        else {
            [self popActionWith:array];
        }
    }];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    if (tag == LVNREPL_LISTENING_INT) {
        NSMutableString* str = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [str deleteCharactersInRange:NSMakeRange([str length] - 1, 1)];
        [self popActionWith:str];
    }
    else if (tag == LVNREPL_LISTENING_STR1) {
        NSString* firstHalf = [self.actions lastObject];
        [self.actions removeLastObject];
        
        NSMutableString* str = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [str deleteCharactersInRange:NSMakeRange([str length] - 1, 1)];
        NSUInteger len = [[firstHalf stringByAppendingString:str] integerValue];
        
        [self.socket readDataToLength:len withTimeout:-1 tag:LVNREPL_LISTENING_STR2];
    }
    else if (tag == LVNREPL_LISTENING_STR2) {
        NSString* str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        [self popActionWith:str];
    }
    else if (tag == LVNREPL_LISTENING_ANY) {
        NSString* str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        unichar c = [str characterAtIndex:0];
        
        if (c == 'e')
            [self popActionWith:nil];
        else if (c == 'd')
            [self listenForKeyIn:[NSMutableDictionary dictionary]];
        else if (c == 'l')
            [self listenForElementIn:[NSMutableArray array]];
        else if (c == 'i')
            [self.socket readDataToData:[@"e" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:LVNREPL_LISTENING_INT];
        else {
            [self.actions addObject:str];
            [self.socket readDataToData:[@":" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:LVNREPL_LISTENING_STR1];
        }
    }
}

@end
