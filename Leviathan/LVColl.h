//
//  SDColl.h
//  Leviathan
//
//  Created by Steven on 10/12/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LVToken.h"
#import "LVElement.h"

typedef enum __LVCollType {
    LVCollTypeTopLevel,
    LVCollTypeList,
    LVCollTypeVector,
    LVCollTypeMap,
} LVCollType;

@interface LVColl : NSObject <LVElement>

@property LVCollType collType;
@property LVToken* openingToken;
@property LVToken* closingToken;
@property NSArray* childElements;

- (LVColl*) deepestCollAtPos:(NSUInteger)pos childsIndex:(NSUInteger*)childsIndex;

- (void) findDefinitions:(NSMutableArray*)defs;

@end



@interface LVDefinition : LVColl

@property LVAtom* defType;
@property LVAtom* defName;

@end
