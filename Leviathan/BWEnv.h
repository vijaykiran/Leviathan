//
//  BWEnv.h
//  Beowulf
//
//  Created by Steven on 9/11/13.
//
//

#import <Foundation/Foundation.h>

@interface BWEnv : NSObject <NSCopying>

@property NSMutableDictionary* names;
@property BWEnv* parent;

+ (BWEnv*) env;

- (id) lookup:(NSString*)name;

- (void) pinEnvOnTail:(BWEnv*)env;

@end
