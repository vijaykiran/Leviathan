//
//  BWParser.h
//  Beowulf
//
//  Created by Steven on 9/21/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SDToken.h"

#import "SDElement.h"
#import "SDColl.h"
#import "SDAtom.h"
#import "SDParserError.h"

@interface SDParser : NSObject

+ (SDColl*) parse:(NSString*)raw
            error:(SDParseError*__autoreleasing*)error;

@end
