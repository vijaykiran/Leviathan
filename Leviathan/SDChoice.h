//
//  SDChoice.h
//  Oxide
//
//  Created by Steven on 7/28/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDChoice : NSObject

+ (SDChoice*) choiceWithString:(NSString*)actualString;

@property (readonly) NSString* actualString;
@property NSString* tryString;

@property (readonly) CGFloat score;

- (void) updateScore;

@end
