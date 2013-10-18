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
            LVApplyStyle(attrString, LVStyleForRainbowParens, coll.openingToken.range, deepness);
            LVApplyStyle(attrString, LVStyleForRainbowParens, coll.closingToken.range, deepness);
        }
        
        for (id<LVElement> child in coll.childElements) {
            [self highlight:child in:attrString atLevel:deepness + 1];
        }
        
        if ([element isKindOfClass:[LVDefinition self]]) {
            LVDefinition* def = element;
            LVApplyStyle(attrString, LVStyleForDef, def.defType.token.range, deepness);
            LVApplyStyle(attrString, LVStyleForDefName, def.defName.token.range, deepness);
        }
    }
    else if ([element isKindOfClass:[LVAtom self]]) {
        LVAtom* atom = element;
        
        switch (atom.atomType) {
            case LVAtomTypeSymbol: LVApplyStyle(attrString, LVStyleForSymbol, atom.token.range, deepness); break;
            case LVAtomTypeKeyword: LVApplyStyle(attrString, LVStyleForKeyword, atom.token.range, deepness); break;
            case LVAtomTypeString: LVApplyStyle(attrString, LVStyleForString, atom.token.range, deepness); break;
            case LVAtomTypeRegex: LVApplyStyle(attrString, LVStyleForRegex, atom.token.range, deepness); break;
            case LVAtomTypeNumber: LVApplyStyle(attrString, LVStyleForNumber, atom.token.range, deepness); break;
            case LVAtomTypeTrue: LVApplyStyle(attrString, LVStyleForNumber, atom.token.range, deepness); break; // TODO: true, false, and nil should have their own theme keys
            case LVAtomTypeFalse: LVApplyStyle(attrString, LVStyleForNumber, atom.token.range, deepness); break;
            case LVAtomTypeNil: LVApplyStyle(attrString, LVStyleForNumber, atom.token.range, deepness); break;
            case LVAtomTypeComment: LVApplyStyle(attrString, LVStyleForComment, atom.token.range, deepness); break;
            case LVAtomTypeTypeOp: LVApplyStyle(attrString, LVStyleForTypeOp, atom.token.range, deepness); break;
            case LVAtomTypeQuote: LVApplyStyle(attrString, LVStyleForQuote, atom.token.range, deepness); break;
            case LVAtomTypeUnquote: LVApplyStyle(attrString, LVStyleForUnquote, atom.token.range, deepness); break;
            case LVAtomTypeSyntaxQuote: LVApplyStyle(attrString, LVStyleForSyntaxQuote, atom.token.range, deepness); break;
            case LVAtomTypeSplice: LVApplyStyle(attrString, LVStyleForSplice, atom.token.range, deepness); break;
        }
    }
}

@end

NSColor* LVColorFromHex(NSString* hex) {
    unsigned container = 0;
    [[NSScanner scannerWithString:hex] scanHexInt:&container];
    return [NSColor colorWithCalibratedRed:(CGFloat)(unsigned char)(container >> 16) / 0xff
                                     green:(CGFloat)(unsigned char)(container >> 8) / 0xff
                                      blue:(CGFloat)(unsigned char)(container) / 0xff
                                     alpha:1.0];
}


NSFont* LVFixFont(NSFont* font, BOOL haveIt, int trait) {
    NSFontManager* fm = [NSFontManager sharedFontManager];
    return (haveIt ? [fm convertFont:font toHaveTrait:trait] : [fm convertFont:font toNotHaveTrait:trait]);
}

void LVApplyStyle(NSMutableAttributedString* attrString, NSString* styleName, NSRange range, NSUInteger deepness) {
    NSDictionary* customAttrs;
    
    if (styleName == LVStyleForRainbowParens) {
        NSArray* attrsList = [[[LVThemeManager sharedThemeManager] currentTheme] objectForKey: styleName];
        customAttrs = [attrsList objectAtIndex: deepness % [attrsList count]];
    }
    else {
        customAttrs = [[[LVThemeManager sharedThemeManager] currentTheme] objectForKey: styleName];
    }
    
    NSMutableDictionary* newStyle = [NSMutableDictionary dictionary];
    
    NSFont* font = [attrString attribute:NSFontAttributeName atIndex:range.location effectiveRange:NULL];
    font = LVFixFont(font, [customAttrs[@"Bold"] boolValue], NSFontBoldTrait);
    font = LVFixFont(font, [customAttrs[@"Italic"] boolValue], NSFontItalicTrait);
    newStyle[NSForegroundColorAttributeName] = LVColorFromHex(customAttrs[@"Color"]);
    newStyle[NSFontAttributeName] = font;
    
    [attrString addAttributes:newStyle
                        range:range];
}
