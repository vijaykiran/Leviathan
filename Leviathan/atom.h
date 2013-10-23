//
//  atom.h
//  Leviathan
//
//  Created by Steven on 10/20/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "element.h"
#import "token.h"
#import "coll.h"

typedef enum __LVAtomType : uint64_t {
    LVAtomType_Symbol  = 1 << 0,
    LVAtomType_String  = 1 << 1,
    LVAtomType_Number  = 1 << 2,
    LVAtomType_Keyword = 1 << 3,
    
    LVAtomType_Spaces  = 1 << 4,
    
    LVAtomType_TrueAtom  = 1 << 5, // must also be Symbol
    LVAtomType_FalseAtom = 1 << 6, // must also be Symbol
    LVAtomType_NilAtom   = 1 << 7, // must also be Symbol
    
    LVAtomType_Deflike = 1 << 8, // must also be Symbol
    LVAtomType_Ns      = 1 << 9, // must also be Symbol
} LVAtomType;

typedef struct __LVAtom {
    
    LVElementType elementType;
    LVColl* parent;
    size_t index;
    
    LVAtomType atomType;
    LVToken* token;
    
} LVAtom;

LVAtom* LVAtomCreate();
void LVAtomDestroy(LVAtom* atom);
