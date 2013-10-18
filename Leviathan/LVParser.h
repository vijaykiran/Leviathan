//
//  BWParser.h
//  Beowulf
//
//  Created by Steven on 9/21/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LVToken.h"

#import "SDElement.h"
#import "LVColl.h"
#import "LVAtom.h"
#import "LVParserError.h"

@interface LVParser : NSObject

+ (LVColl*) parse:(NSString*)raw
            error:(LVParseError*__autoreleasing*)error;

@end
