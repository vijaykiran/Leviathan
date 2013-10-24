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

+ (void) highlight:(LVElement*)element in:(NSTextStorage*)attrString atLevel:(int)deepness {
    
    if (element->elementType & LVElementType_Coll) {
        LVColl* coll = (void*)element;
        
//        printf("in here\n");
        
        if (!(coll->collType & LVCollType_TopLevel)) {
//            [[LVThemeManager sharedThemeManager].currentTheme.rainbowparens highlightIn:attrString range:coll.openingToken.range depth:deepness];
//            [[LVThemeManager sharedThemeManager].currentTheme.rainbowparens highlightIn:attrString range:coll.closingToken.range depth:deepness];
        }
        
        for (int i = 0; i < coll->children.len; i++) {
            LVElement* child = coll->children.elements[i];
            [self highlight:child in:attrString atLevel:deepness + 1];
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
    }
}

@end
