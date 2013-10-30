//
//  BWCallable.h
//  Beowulf
//
//  Created by Steven on 9/21/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BWEnv.h"

@protocol BWCallable <NSObject>

- (id) call:(NSArray*)args env:(BWEnv*)callingEnv;

@end
