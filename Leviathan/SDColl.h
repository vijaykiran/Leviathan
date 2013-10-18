//
//  SDColl.h
//  Leviathan
//
//  Created by Steven on 10/12/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SDToken.h"
#import "SDElement.h"

typedef enum __SDCollType {
    SDCollTypeTopLevel,
    SDCollTypeList,
    SDCollTypeVector,
    SDCollTypeMap,
} SDCollType;

@interface SDColl : NSObject <SDElement>

@property SDCollType collType;
@property SDToken* openingToken;
@property SDToken* closingToken;
@property NSArray* childElements;

- (SDColl*) deepestCollAtPos:(NSUInteger)pos childsIndex:(NSUInteger*)childsIndex;

@end



@interface SDDefinition : SDColl

@property SDAtom* defType;
@property SDAtom* defName;

@end
