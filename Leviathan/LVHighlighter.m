//
//  LVHighlighter.m
//  Leviathan
//
//  Created by Steven on 10/18/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVHighlighter.h"

#import "LVThemeManager.h"
#import "LVColl.h"
#import "LVAtom.h"

@implementation LVHighlighter

+ (void) highlight:(id<LVElement>)element in:(NSTextStorage*)attrString atLevel:(int)deepness {
    if ([element isKindOfClass:[LVColl self]]) {
        LVColl* coll = element;
        
        if (coll.collType != LVCollTypeTopLevel) {
            [[LVThemeManager sharedThemeManager].currentTheme.rainbowparens highlightIn:attrString range:coll.openingToken.range depth:deepness];
            [[LVThemeManager sharedThemeManager].currentTheme.rainbowparens highlightIn:attrString range:coll.closingToken.range depth:deepness];
        }
        
        for (id<LVElement> child in coll.childElements) {
            [self highlight:child in:attrString atLevel:deepness + 1];
        }
        
        if ([element isKindOfClass:[LVDefinition self]]) {
            LVDefinition* def = element;
            
            [[LVThemeManager sharedThemeManager].currentTheme.def highlightIn:attrString range:def.defType.token.range depth:deepness];
            [[LVThemeManager sharedThemeManager].currentTheme.defname highlightIn:attrString range:def.defName.token.range depth:deepness];
        }
    }
    else if ([element isKindOfClass:[LVAtom self]]) {
        LVAtom* atom = element;
        
        switch (atom.atomType) {
            case LVAtomTypeSymbol: [[LVThemeManager sharedThemeManager].currentTheme.symbol highlightIn: attrString range: atom.token.range depth: deepness]; break;
            case LVAtomTypeKeyword: [[LVThemeManager sharedThemeManager].currentTheme.keyword highlightIn: attrString range: atom.token.range depth: deepness]; break;
            case LVAtomTypeString: [[LVThemeManager sharedThemeManager].currentTheme.string highlightIn: attrString range: atom.token.range depth: deepness]; break;
            case LVAtomTypeRegex: [[LVThemeManager sharedThemeManager].currentTheme.regex highlightIn: attrString range: atom.token.range depth: deepness]; break;
            case LVAtomTypeNumber: [[LVThemeManager sharedThemeManager].currentTheme.number highlightIn: attrString range: atom.token.range depth: deepness]; break;
            case LVAtomTypeTrue: [[LVThemeManager sharedThemeManager].currentTheme.number highlightIn: attrString range: atom.token.range depth: deepness]; break; // TODO: true, false, and nil should have their own theme keys
            case LVAtomTypeFalse: [[LVThemeManager sharedThemeManager].currentTheme.number highlightIn: attrString range: atom.token.range depth: deepness]; break;
            case LVAtomTypeNil: [[LVThemeManager sharedThemeManager].currentTheme.number highlightIn: attrString range: atom.token.range depth: deepness]; break;
            case LVAtomTypeComment: [[LVThemeManager sharedThemeManager].currentTheme.comment highlightIn: attrString range: atom.token.range depth: deepness]; break;
            case LVAtomTypeTypeOp: [[LVThemeManager sharedThemeManager].currentTheme.typeop highlightIn: attrString range: atom.token.range depth: deepness]; break;
            case LVAtomTypeQuote: [[LVThemeManager sharedThemeManager].currentTheme.quote highlightIn: attrString range: atom.token.range depth: deepness]; break;
            case LVAtomTypeUnquote: [[LVThemeManager sharedThemeManager].currentTheme.unquote highlightIn: attrString range: atom.token.range depth: deepness]; break;
            case LVAtomTypeSyntaxQuote: [[LVThemeManager sharedThemeManager].currentTheme.syntaxquote highlightIn: attrString range: atom.token.range depth: deepness]; break;
            case LVAtomTypeSplice: [[LVThemeManager sharedThemeManager].currentTheme.splice highlightIn: attrString range: atom.token.range depth: deepness]; break;
        }
    }
}

@end
