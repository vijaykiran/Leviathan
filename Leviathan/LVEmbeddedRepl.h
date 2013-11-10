//
//  LVEmbeddedRepl.h
//  Leviathan
//
//  Created by Steven Degutis on 11/10/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LVEmbeddedRepl : NSObject

@property NSURL* baseURL;
@property (copy) void(^ready)(NSUInteger port);

- (void) open;

@end
