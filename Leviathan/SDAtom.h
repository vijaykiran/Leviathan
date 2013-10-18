//
//  SDAtom.h
//  Leviathan
//
//  Created by Steven on 10/12/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SDElement.h"
#import "SDToken.h"

typedef enum __LVAtomType {
    LVAtomTypeSymbol,
    LVAtomTypeKeyword,
    LVAtomTypeString,
    LVAtomTypeRegex,
    LVAtomTypeNumber,
    LVAtomTypeTrue,
    LVAtomTypeFalse,
    LVAtomTypeNil,
    LVAtomTypeComment,
    LVAtomTypeTypeOp,
    LVAtomTypeQuote,
    LVAtomTypeUnquote,
    LVAtomTypeSyntaxQuote,
    LVAtomTypeSplice,
} LVAtomType;

@interface SDAtom : NSObject <SDElement>

@property SDToken* token;
@property LVAtomType atomType;

+ (SDAtom*) with:(SDToken*)tok of:(LVAtomType)atomType;

@end
