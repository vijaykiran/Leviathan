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
            LVApplyStyle(attrString, SDThemeForRainbowParens, coll.openingToken.range, deepness);
            LVApplyStyle(attrString, SDThemeForRainbowParens, coll.closingToken.range, deepness);
        }
        
        for (id<LVElement> child in coll.childElements) {
            [self highlight:child in:attrString atLevel:deepness + 1];
        }
        
        if ([element isKindOfClass:[LVDefinition self]]) {
            LVDefinition* def = element;
            LVApplyStyle(attrString, SDThemeForDef, def.defType.token.range, deepness);
            LVApplyStyle(attrString, SDThemeForDefName, def.defName.token.range, deepness);
        }
    }
    else if ([element isKindOfClass:[LVAtom self]]) {
        LVAtom* atom = element;
        
        switch (atom.atomType) {
            case LVAtomTypeSymbol: LVApplyStyle(attrString, SDThemeForSymbol, atom.token.range, deepness); break;
            case LVAtomTypeKeyword: LVApplyStyle(attrString, SDThemeForKeyword, atom.token.range, deepness); break;
            case LVAtomTypeString: LVApplyStyle(attrString, SDThemeForString, atom.token.range, deepness); break;
            case LVAtomTypeRegex: LVApplyStyle(attrString, SDThemeForRegex, atom.token.range, deepness); break;
            case LVAtomTypeNumber: LVApplyStyle(attrString, SDThemeForNumber, atom.token.range, deepness); break;
            case LVAtomTypeTrue: LVApplyStyle(attrString, SDThemeForNumber, atom.token.range, deepness); break; // TODO: true, false, and nil should have their own theme keys
            case LVAtomTypeFalse: LVApplyStyle(attrString, SDThemeForNumber, atom.token.range, deepness); break;
            case LVAtomTypeNil: LVApplyStyle(attrString, SDThemeForNumber, atom.token.range, deepness); break;
            case LVAtomTypeComment: LVApplyStyle(attrString, SDThemeForComment, atom.token.range, deepness); break;
            case LVAtomTypeTypeOp: LVApplyStyle(attrString, SDThemeForTypeOp, atom.token.range, deepness); break;
            case LVAtomTypeQuote: LVApplyStyle(attrString, SDThemeForQuote, atom.token.range, deepness); break;
            case LVAtomTypeUnquote: LVApplyStyle(attrString, SDThemeForUnquote, atom.token.range, deepness); break;
            case LVAtomTypeSyntaxQuote: LVApplyStyle(attrString, SDThemeForSyntaxQuote, atom.token.range, deepness); break;
            case LVAtomTypeSplice: LVApplyStyle(attrString, SDThemeForSplice, atom.token.range, deepness); break;
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
    
    if (styleName == SDThemeForRainbowParens) {
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
