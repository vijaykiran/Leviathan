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

@implementation LVHighlighter

+ (void) highlight:(LVElement*)element in:(NSTextStorage*)attrString {
    size_t startPos = 0;
    highlight(element, attrString, 0, &startPos);
}

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
        
        if (atom->atom_type & LVAtomType_Symbol) [[LVThemeManager sharedThemeManager].currentTheme.symbol highlightIn: attrString range: NSMakeRange(*startPos, atom->token->string->slen) depth: deepness];
        else if (atom->atom_type & LVAtomType_Keyword) [[LVThemeManager sharedThemeManager].currentTheme.keyword highlightIn: attrString range: NSMakeRange(*startPos, atom->token->string->slen) depth: deepness];
        else if (atom->atom_type & LVAtomType_String) [[LVThemeManager sharedThemeManager].currentTheme.string highlightIn: attrString range: NSMakeRange(*startPos, atom->token->string->slen) depth: deepness];
        else if (atom->atom_type & LVAtomType_Regex) [[LVThemeManager sharedThemeManager].currentTheme.regex highlightIn: attrString range: NSMakeRange(*startPos, atom->token->string->slen) depth: deepness];
        else if (atom->atom_type & LVAtomType_Number) [[LVThemeManager sharedThemeManager].currentTheme.number highlightIn: attrString range: NSMakeRange(*startPos, atom->token->string->slen) depth: deepness];
        else if (atom->atom_type & LVAtomType_TrueAtom) [[LVThemeManager sharedThemeManager].currentTheme.number highlightIn: attrString range: NSMakeRange(*startPos, atom->token->string->slen) depth: deepness]; // TODO: true, false, and nil should have their own theme keys
        else if (atom->atom_type & LVAtomType_FalseAtom) [[LVThemeManager sharedThemeManager].currentTheme.number highlightIn: attrString range: NSMakeRange(*startPos, atom->token->string->slen) depth: deepness];
        else if (atom->atom_type & LVAtomType_NilAtom) [[LVThemeManager sharedThemeManager].currentTheme.number highlightIn: attrString range: NSMakeRange(*startPos, atom->token->string->slen) depth: deepness];
        else if (atom->atom_type & LVAtomType_Comment) [[LVThemeManager sharedThemeManager].currentTheme.comment highlightIn: attrString range: NSMakeRange(*startPos, atom->token->string->slen) depth: deepness];
        else if (atom->atom_type & LVAtomType_TypeOp) [[LVThemeManager sharedThemeManager].currentTheme.typeop highlightIn: attrString range: NSMakeRange(*startPos, atom->token->string->slen) depth: deepness];
        else if (atom->atom_type & LVAtomType_Quote) [[LVThemeManager sharedThemeManager].currentTheme.quote highlightIn: attrString range: NSMakeRange(*startPos, atom->token->string->slen) depth: deepness];
        else if (atom->atom_type & LVAtomType_Unquote) [[LVThemeManager sharedThemeManager].currentTheme.unquote highlightIn: attrString range: NSMakeRange(*startPos, atom->token->string->slen) depth: deepness];
        else if (atom->atom_type & LVAtomType_SyntaxQuote) [[LVThemeManager sharedThemeManager].currentTheme.syntaxquote highlightIn: attrString range: NSMakeRange(*startPos, atom->token->string->slen) depth: deepness];
        else if (atom->atom_type & LVAtomType_Splice) [[LVThemeManager sharedThemeManager].currentTheme.splice highlightIn: attrString range: NSMakeRange(*startPos, atom->token->string->slen) depth: deepness];
        
        *startPos += atom->token->string->slen;
    }
}

@end
