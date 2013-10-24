//
//  atom.h
//  Leviathan
//
//  Created by Steven on 10/20/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "token.h"
#import "coll.h"

typedef enum __LVAtomType : uint64_t {
    LVAtomType_Symbol  = 1 << 0,
    LVAtomType_String  = 1 << 1,
    LVAtomType_Regex   = 1 << 2,
    LVAtomType_Number  = 1 << 3,
    LVAtomType_Keyword = 1 << 4,
    
    LVAtomType_Spaces   = 1 << 5,
    LVAtomType_Newline  = 1 << 6,
    LVAtomType_Comma    = 1 << 7,
    
    LVAtomType_Comment  = 1 << 8,
    
    LVAtomType_Var            = 1 << 9,
    LVAtomType_Quote          = 1 << 10,
    LVAtomType_Unquote        = 1 << 11,
    LVAtomType_SyntaxQuote    = 1 << 12,
    LVAtomType_Splice         = 1 << 13,
    LVAtomType_TypeOp         = 1 << 14,
    LVAtomType_ReaderMacro    = 1 << 15,
    LVAtomType_ReaderComment  = 1 << 16,
    
    LVAtomType_TrueAtom  = 1 << 17, // must also be Symbol
    LVAtomType_FalseAtom = 1 << 18, // must also be Symbol
    LVAtomType_NilAtom   = 1 << 19, // must also be Symbol
    
    LVAtomType_Deflike = 1 << 20,  // must also be Symbol
    LVAtomType_Ns      = 1 << 21, // must also be Symbol
} LVAtomType;

typedef struct __LVAtom {
    
    BOOL is_atom;
    LVColl* parent;
    
    LVAtomType atom_type;
    LVToken* token;
    
} LVAtom;

LVAtom* LVAtomCreate(LVAtomType typ, LVToken* tok);
void LVAtomDestroy(LVAtom* atom);

BOOL LVAtomIsSemantic(LVAtom* atom);
