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
    if (!element->isAtom) {
        LVColl* coll = (void*)element;
        
        BOOL notTopLevel = !(coll->collType & LVCollType_TopLevel);
        
        if (notTopLevel) {
            [[LVThemeManager sharedThemeManager].currentTheme.rainbowparens highlightIn:attrString range:NSMakeRange(*startPos, coll->open_token->val->slen) depth:deepness];
            *startPos += coll->open_token->val->slen;
        }
        
        for (int i = 0; i < coll->children.len; i++) {
            LVElement* child = coll->children.elements[i];
            highlight(child, attrString, deepness + 1, startPos);
        }
        
        if (notTopLevel) {
            [[LVThemeManager sharedThemeManager].currentTheme.rainbowparens highlightIn:attrString range:NSMakeRange(*startPos, coll->close_token->val->slen) depth:deepness];
            *startPos += coll->close_token->val->slen;
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
        
        if (atom->atomType & LVAtomType_Symbol) [[LVThemeManager sharedThemeManager].currentTheme.symbol highlightIn: attrString range: NSMakeRange(*startPos, atom->token->val->slen) depth: deepness];
        else if (atom->atomType & LVAtomType_Keyword) [[LVThemeManager sharedThemeManager].currentTheme.keyword highlightIn: attrString range: NSMakeRange(*startPos, atom->token->val->slen) depth: deepness];
        else if (atom->atomType & LVAtomType_String) [[LVThemeManager sharedThemeManager].currentTheme.string highlightIn: attrString range: NSMakeRange(*startPos, atom->token->val->slen) depth: deepness];
        else if (atom->atomType & LVAtomType_Regex) [[LVThemeManager sharedThemeManager].currentTheme.regex highlightIn: attrString range: NSMakeRange(*startPos, atom->token->val->slen) depth: deepness];
        else if (atom->atomType & LVAtomType_Number) [[LVThemeManager sharedThemeManager].currentTheme.number highlightIn: attrString range: NSMakeRange(*startPos, atom->token->val->slen) depth: deepness];
        else if (atom->atomType & LVAtomType_TrueAtom) [[LVThemeManager sharedThemeManager].currentTheme.number highlightIn: attrString range: NSMakeRange(*startPos, atom->token->val->slen) depth: deepness]; // TODO: true, false, and nil should have their own theme keys
        else if (atom->atomType & LVAtomType_FalseAtom) [[LVThemeManager sharedThemeManager].currentTheme.number highlightIn: attrString range: NSMakeRange(*startPos, atom->token->val->slen) depth: deepness];
        else if (atom->atomType & LVAtomType_NilAtom) [[LVThemeManager sharedThemeManager].currentTheme.number highlightIn: attrString range: NSMakeRange(*startPos, atom->token->val->slen) depth: deepness];
        else if (atom->atomType & LVAtomType_Comment) [[LVThemeManager sharedThemeManager].currentTheme.comment highlightIn: attrString range: NSMakeRange(*startPos, atom->token->val->slen) depth: deepness];
        else if (atom->atomType & LVAtomType_TypeOp) [[LVThemeManager sharedThemeManager].currentTheme.typeop highlightIn: attrString range: NSMakeRange(*startPos, atom->token->val->slen) depth: deepness];
        else if (atom->atomType & LVAtomType_Quote) [[LVThemeManager sharedThemeManager].currentTheme.quote highlightIn: attrString range: NSMakeRange(*startPos, atom->token->val->slen) depth: deepness];
        else if (atom->atomType & LVAtomType_Unquote) [[LVThemeManager sharedThemeManager].currentTheme.unquote highlightIn: attrString range: NSMakeRange(*startPos, atom->token->val->slen) depth: deepness];
        else if (atom->atomType & LVAtomType_SyntaxQuote) [[LVThemeManager sharedThemeManager].currentTheme.syntaxquote highlightIn: attrString range: NSMakeRange(*startPos, atom->token->val->slen) depth: deepness];
        else if (atom->atomType & LVAtomType_Splice) [[LVThemeManager sharedThemeManager].currentTheme.splice highlightIn: attrString range: NSMakeRange(*startPos, atom->token->val->slen) depth: deepness];
        
        *startPos += atom->token->val->slen;
    }
}

@end
