//
//  atom.h
//  Leviathan
//
//  Created by Steven on 10/20/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "token.h"

struct __LVColl;

typedef enum __LVAtomType : uint64_t {
    LVAtomType_Symbol  = 1 << 0,
    LVAtomType_String  = 1 << 1,
    LVAtomType_Regex   = 1 << 2,
    LVAtomType_Number  = 1 << 3,
    LVAtomType_Keyword = 1 << 4,
    
    LVAtomType_Spaces    = 1 << 5,
    LVAtomType_Newlines  = 1 << 6,
    LVAtomType_Comma     = 1 << 7,
    
    LVAtomType_Comment  = 1 << 8,
    
    LVAtomType_Var            = 1 << 9,
    LVAtomType_Quote          = 1 << 10,
    LVAtomType_Unquote        = 1 << 11,
    LVAtomType_SyntaxQuote    = 1 << 12,
    LVAtomType_Splice         = 1 << 13,
    LVAtomType_TypeOp         = 1 << 14,
    LVAtomType_ReaderMacro    = 1 << 15,
    LVAtomType_ReaderComment  = 1 << 16,
    
    LVAtomType_CollDelim   = 1 << 17,
    LVAtomType_CollOpener  = 1 << 18, // must also be LVAtomType_CollDelim
    LVAtomType_CollCloser  = 1 << 19, // must also be LVAtomType_CollDelim
    
    LVAtomType_TrueAtom  = 1 << 20, // must also be Symbol
    LVAtomType_FalseAtom = 1 << 21, // must also be Symbol
    LVAtomType_NilAtom   = 1 << 22, // must also be Symbol
    
    LVAtomType_DefType = 1 << 23,  // must also be Symbol
    LVAtomType_DefName = 1 << 24,  // must also be Symbol
    LVAtomType_Ns      = 1 << 25,  // must also be Symbol
    
    LVAtomType_Operator  = 1 << 26,  // must also be Symbol
} LVAtomType;

typedef struct __LVAtom {
    
    BOOL isAtom;
    struct __LVColl* parent;
    
    LVAtomType atomType;
    LVToken* token;
    
} LVAtom;

LVAtom* LVAtomCreate(LVAtomType typ, LVToken* tok);
void LVAtomDestroy(LVAtom* atom);

BOOL LVAtomIsSemantic(LVAtom* atom);
