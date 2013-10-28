//
//  LVHighlighter.m
//  Leviathan
//
//  Created by Steven on 10/18/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVHighlighter.h"

#import "LVThemeManager.h"
#import "coll.h"
#import "atom.h"

LVHighlights* LVHighlightsForDoc(LVDoc* doc) {
    LVHighlights* hs = malloc(sizeof(LVHighlights) * doc->string->slen);
    
    int idx = 0;
    
    for (int i = 1; i < doc->tokens_len; i++) {
        LVToken* tok = doc->tokens[i];
        
        for (int ii = 0; ii < tok->string->slen; ii++) {
            hs[idx].pos = tok->pos;
            hs[idx].len = tok->string->slen;
            hs[idx].atom = tok->atom;
            idx++;
        }
    }
    
    return hs;
}

NSDictionary* LVAttributesForAtom(LVAtom* atom) {
    assert(atom != NULL);
    
//    printf("at %ld for %d\n", atom->token->pos, atom->token->string->slen);
    
    LVTheme* theme = [LVThemeManager sharedThemeManager].currentTheme;
    
    if (atom->atom_type & LVAtomType_Spaces) return theme.symbol.attrs;
    if (atom->atom_type & LVAtomType_Newline) return theme.symbol.attrs;
    if (atom->atom_type & LVAtomType_Comma) return theme.symbol.attrs;
    
    if (atom->atom_type & LVAtomType_DefType) return theme.def.attrs;
    if (atom->atom_type & LVAtomType_DefName) return theme.defname.attrs;
    if (atom->atom_type & LVAtomType_Symbol) return theme.symbol.attrs;
    if (atom->atom_type & LVAtomType_Keyword) return theme.keyword.attrs;
    if (atom->atom_type & LVAtomType_String) return theme.string.attrs;
    if (atom->atom_type & LVAtomType_Regex) return theme.regex.attrs;
    if (atom->atom_type & LVAtomType_Number) return theme.number.attrs;
    if (atom->atom_type & LVAtomType_TrueAtom) return theme._true.attrs;
    if (atom->atom_type & LVAtomType_FalseAtom) return theme._false.attrs;
    if (atom->atom_type & LVAtomType_NilAtom) return theme._nil.attrs;
    if (atom->atom_type & LVAtomType_Comment) return theme.comment.attrs;
    if (atom->atom_type & LVAtomType_TypeOp) return theme.typeop.attrs;
    if (atom->atom_type & LVAtomType_Quote) return theme.quote.attrs;
    if (atom->atom_type & LVAtomType_Unquote) return theme.unquote.attrs;
    if (atom->atom_type & LVAtomType_SyntaxQuote) return theme.syntaxquote.attrs;
    if (atom->atom_type & LVAtomType_Splice) return theme.splice.attrs;
    
    if (atom->atom_type & LVAtomType_Var) return theme.symbol.attrs;
    if (atom->atom_type & LVAtomType_ReaderMacro) return theme.symbol.attrs;
    
    if (atom->atom_type & LVAtomType_CollDelim) {
        size_t depth = LVGetElementDepth((LVElement*)atom);
        NSArray* rainbows = [LVThemeManager sharedThemeManager].currentTheme.rainbowparens;
        LVThemeStyle* style = [rainbows objectAtIndex: depth % [rainbows count]];
        return style.attrs;
    }
    
    abort();
}
