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

static void highlight(LVElement* element, NSTextStorage* attrString, int deepness, size_t* startPos) {
    if (!element->is_atom) {
        LVColl* coll = (void*)element;
        
        BOOL notTopLevel = !(coll->coll_type & LVCollType_TopLevel);
        
        if (notTopLevel) {
            [[LVThemeManager sharedThemeManager].currentTheme.rainbowparens highlightIn:attrString range:NSMakeRange(*startPos, coll->open_token->string->slen) depth:deepness];
            *startPos += coll->open_token->string->slen;
        }
        
        for (int i = 0; i < coll->children_len; i++) {
            LVElement* child = coll->children[i];
            highlight(child, attrString, deepness + 1, startPos);
        }
        
        if (notTopLevel) {
            [[LVThemeManager sharedThemeManager].currentTheme.rainbowparens highlightIn:attrString range:NSMakeRange(*startPos, coll->close_token->string->slen) depth:deepness];
            *startPos += coll->close_token->string->slen;
        }
        
        
//        if ([element isKindOfClass:[LVDefinition self]]) {
//            LVDefinition* def = element;
//            
//            [[LVThemeManager sharedThemeManager].currentTheme.def highlightIn:attrString range:def.defType.token.range depth:deepness];
//            [[LVThemeManager sharedThemeManager].currentTheme.defname highlightIn:attrString range:def.defName.token.range depth:deepness];
//        }
    }
    else {
        LVAtom* atom = (void*)element;
        
        LVTheme* theme = [LVThemeManager sharedThemeManager].currentTheme;
        LVThemeStyle* style;
        
        if (atom->atom_type & LVAtomType_Symbol) style = theme.symbol;
        else if (atom->atom_type & LVAtomType_Keyword) style = theme.keyword;
        else if (atom->atom_type & LVAtomType_String) style = theme.string;
        else if (atom->atom_type & LVAtomType_Regex) style = theme.regex;
        else if (atom->atom_type & LVAtomType_Number) style = theme.number;
        else if (atom->atom_type & LVAtomType_TrueAtom) style = theme._true;
        else if (atom->atom_type & LVAtomType_FalseAtom) style = theme._false;
        else if (atom->atom_type & LVAtomType_NilAtom) style = theme._nil;
        else if (atom->atom_type & LVAtomType_Comment) style = theme.comment;
        else if (atom->atom_type & LVAtomType_TypeOp) style = theme.typeop;
        else if (atom->atom_type & LVAtomType_Quote) style = theme.quote;
        else if (atom->atom_type & LVAtomType_Unquote) style = theme.unquote;
        else if (atom->atom_type & LVAtomType_SyntaxQuote) style = theme.syntaxquote;
        else if (atom->atom_type & LVAtomType_Splice) style = theme.splice;
        
        [style highlightIn: attrString range: NSMakeRange(*startPos, atom->token->string->slen) depth: deepness];
        
        *startPos += atom->token->string->slen;
    }
}

void LVHighlight(LVElement* element, NSTextStorage* attrString, NSUInteger startPos) {
    highlight(element, attrString, 0, &startPos);
}

void LVHighlightSomeChild(LVElement* child, NSTextStorage* attrString, NSUInteger startPos) {
    int depth = 0;
    
    LVElement* iter = child;
    
    while (iter->parent) {
        depth++;
        iter = (void*)iter->parent;
    }
    
    highlight(child, attrString, depth, &startPos);
}
