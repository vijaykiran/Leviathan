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
    LVHighlights* hs = malloc(sizeof(LVHighlights) * CFStringGetLength(doc->string));
    
    int idx = 0;
    
    for (int i = 1; i < doc->tokens_len; i++) {
        LVToken* tok = doc->tokens[i];
        
        CFIndex len = CFStringGetLength(tok->string);
        
        for (int ii = 0; ii < len; ii++) {
            hs[idx].pos = tok->pos;
            hs[idx].len = len;
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
    
    if (atom->atom_type & LVAtomType_Spaces) return theme.symbol;
    if (atom->atom_type & LVAtomType_Newline) return theme.symbol;
    if (atom->atom_type & LVAtomType_Comma) return theme.symbol;
    
    if (atom->atom_type & LVAtomType_DefType) return theme.def;
    if (atom->atom_type & LVAtomType_DefName) return theme.defname;
    if (atom->atom_type & LVAtomType_Keyword) return theme.keyword;
    if (atom->atom_type & LVAtomType_String) return theme.string;
    if (atom->atom_type & LVAtomType_Regex) return theme.regex;
    if (atom->atom_type & LVAtomType_Number) return theme.number;
    if (atom->atom_type & LVAtomType_TrueAtom) return theme._true;
    if (atom->atom_type & LVAtomType_FalseAtom) return theme._false;
    if (atom->atom_type & LVAtomType_NilAtom) return theme._nil;
    if (atom->atom_type & LVAtomType_Comment) return theme.comment;
    if (atom->atom_type & LVAtomType_TypeOp) return theme.typeop;
    if (atom->atom_type & LVAtomType_Quote) return theme.quote;
    if (atom->atom_type & LVAtomType_Unquote) return theme.unquote;
    if (atom->atom_type & LVAtomType_SyntaxQuote) return theme.syntaxquote;
    if (atom->atom_type & LVAtomType_Splice) return theme.splice;
    
    if (atom->atom_type & LVAtomType_Var) return theme.symbol;
    if (atom->atom_type & LVAtomType_ReaderMacro) return theme.symbol;
    
    if (atom->atom_type & LVAtomType_Symbol) return theme.symbol;
    
    if (atom->atom_type & LVAtomType_CollDelim) {
        size_t depth = LVGetElementDepth((LVElement*)atom);
        NSArray* rainbows = [LVThemeManager sharedThemeManager].currentTheme.rainbowparens;
        return [rainbows objectAtIndex: depth % [rainbows count]];
    }
    
    abort();
}
