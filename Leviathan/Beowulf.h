//
//  Beowulf.h
//  Beowulf
//
//  Created by Steven on 9/10/13.
//
//

#import <Foundation/Foundation.h>

#import "BWEnv.h"

@interface Beowulf : NSObject

+ (BWEnv*) basicEnv;

+ (id) eval:(NSString*)raw
        env:(BWEnv*)env
      error:(NSError*__autoreleasing)error;

@end

NSString* BWPrnStr(id obj);
