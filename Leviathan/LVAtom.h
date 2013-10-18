//
//  SDAtom.h
//  Leviathan
//
//  Created by Steven on 10/12/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LVElement.h"
#import "LVToken.h"

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

@interface LVAtom : NSObject <LVElement>

@property LVToken* token;
@property LVAtomType atomType;

+ (LVAtom*) with:(LVToken*)tok of:(LVAtomType)atomType;

@end
