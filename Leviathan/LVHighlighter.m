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
    if (element->elementType & LVElementType_Coll) {
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
        
//        switch (atom->atomType) {
//            case LVAtomType_Symbol: [[LVThemeManager sharedThemeManager].currentTheme.symbol highlightIn: attrString range: atom.token.range depth: deepness]; break;
//            case LVAtomType_Keyword: [[LVThemeManager sharedThemeManager].currentTheme.keyword highlightIn: attrString range: atom.token.range depth: deepness]; break;
//            case LVAtomType_String: [[LVThemeManager sharedThemeManager].currentTheme.string highlightIn: attrString range: atom.token.range depth: deepness]; break;
//            case LVAtomType_Regex: [[LVThemeManager sharedThemeManager].currentTheme.regex highlightIn: attrString range: atom.token.range depth: deepness]; break;
//            case LVAtomType_Number: [[LVThemeManager sharedThemeManager].currentTheme.number highlightIn: attrString range: atom.token.range depth: deepness]; break;
//            case LVAtomType_True: [[LVThemeManager sharedThemeManager].currentTheme.number highlightIn: attrString range: atom.token.range depth: deepness]; break; // TODO: true, false, and nil should have their own theme keys
//            case LVAtomType_False: [[LVThemeManager sharedThemeManager].currentTheme.number highlightIn: attrString range: atom.token.range depth: deepness]; break;
//            case LVAtomType_Nil: [[LVThemeManager sharedThemeManager].currentTheme.number highlightIn: attrString range: atom.token.range depth: deepness]; break;
//            case LVAtomType_Comment: [[LVThemeManager sharedThemeManager].currentTheme.comment highlightIn: attrString range: atom.token.range depth: deepness]; break;
//            case LVAtomType_TypeOp: [[LVThemeManager sharedThemeManager].currentTheme.typeop highlightIn: attrString range: atom.token.range depth: deepness]; break;
//            case LVAtomType_Quote: [[LVThemeManager sharedThemeManager].currentTheme.quote highlightIn: attrString range: atom.token.range depth: deepness]; break;
//            case LVAtomType_Unquote: [[LVThemeManager sharedThemeManager].currentTheme.unquote highlightIn: attrString range: atom.token.range depth: deepness]; break;
//            case LVAtomType_SyntaxQuote: [[LVThemeManager sharedThemeManager].currentTheme.syntaxquote highlightIn: attrString range: atom.token.range depth: deepness]; break;
//            case LVAtomType_Splice: [[LVThemeManager sharedThemeManager].currentTheme.splice highlightIn: attrString range: atom.token.range depth: deepness]; break;
//        }
        
        *startPos += atom->token->val->slen;
    }
}

@end
