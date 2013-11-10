//
//  LVNrepl.h
//  Leviathan
//
//  Created by Steven on 11/9/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GCDAsyncSocket.h"

@interface LVReplClient : NSObject <GCDAsyncSocketDelegate>

- (void) connect:(NSUInteger)port ready:(void(^)())ready;

- (id) receiveRawResponse;
- (void) sendRawCommand:(NSDictionary*)msg;

@end
