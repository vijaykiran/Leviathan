//
//  LVHighlighter.m
//  Leviathan
//
//  Created by Steven on 10/18/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "highlights.h"

#import "LVThemeManager.h"
#import "coll.h"
#import "atom.h"

LVHighlights* LVHighlightsForDoc(LVDoc* doc) {
    LVHighlights* hs = malloc(sizeof(LVHighlights) * CFStringGetLength(doc->storage.wholeString));
    
    int idx = 0;
    
    for (LVToken* tok = doc->firstToken->nextToken; tok; tok = tok->nextToken) {
        for (int ii = 0; ii < tok->len; ii++) {
            hs[idx].pos = tok->pos;
            hs[idx].len = tok->len;
            hs[idx].atom = tok->atom;
            hs[idx].attrs = NULL;
            idx++;
        }
    }
    
    return hs;
}

NSDictionary* LVAttributesForAtom(LVAtom* atom) {
    assert(atom != NULL);
    
//    printf("at %ld for %d\n", atom->token->pos, atom->token->string->slen);
    
    LVTheme* theme = [LVThemeManager sharedThemeManager].currentTheme;
    
    if (atom->atomType & LVAtomType_Spaces) return theme.symbol;
    if (atom->atomType & LVAtomType_Newlines) return theme.symbol;
    if (atom->atomType & LVAtomType_Comma) return theme.symbol;
    
    if (atom->atomType & LVAtomType_Operator) return theme.def;
    
    if (atom->atomType & LVAtomType_DefType) return theme.def;
    if (atom->atomType & LVAtomType_DefName) return theme.defname;
    if (atom->atomType & LVAtomType_Keyword) return theme.keyword;
    if (atom->atomType & LVAtomType_String) return theme.string;
    if (atom->atomType & LVAtomType_Regex) return theme.regex;
    if (atom->atomType & LVAtomType_Number) return theme.number;
    if (atom->atomType & LVAtomType_TrueAtom) return theme._true;
    if (atom->atomType & LVAtomType_FalseAtom) return theme._false;
    if (atom->atomType & LVAtomType_NilAtom) return theme._nil;
    if (atom->atomType & LVAtomType_Comment) return theme.comment;
    if (atom->atomType & LVAtomType_TypeOp) return theme.typeop;
    if (atom->atomType & LVAtomType_Quote) return theme.quote;
    if (atom->atomType & LVAtomType_Unquote) return theme.unquote;
    if (atom->atomType & LVAtomType_SyntaxQuote) return theme.syntaxquote;
    if (atom->atomType & LVAtomType_Splice) return theme.splice;
    
    if (atom->atomType & LVAtomType_Var) return theme.symbol;
    if (atom->atomType & LVAtomType_ReaderMacro) return theme.symbol;
    
    if (atom->atomType & LVAtomType_Symbol) return theme.symbol;
    
    if (atom->atomType & LVAtomType_CollDelim) {
        NSUInteger depth = LVGetElementDepth((LVElement*)atom);
        NSArray* rainbows = [LVThemeManager sharedThemeManager].currentTheme.rainbowparens;
        return [rainbows objectAtIndex: depth % [rainbows count]];
    }
    
    abort();
}
