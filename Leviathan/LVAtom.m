//
//  SDAtom.m
//  Leviathan
//
//  Created by Steven on 10/12/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVAtom.h"

#import "LVColl.h"
#import "LVTheme.h"

@implementation LVAtom

@synthesize parent;
@synthesize idx;

@synthesize fullyEnclosedRange;

- (BOOL) isColl { return NO; }
- (BOOL) isAtom { return YES; }
- (LVColl*) asColl { return nil; }
- (LVAtom*) asAtom { return self; }

+ (LVAtom*) with:(LVToken*)tok of:(LVAtomType)atomType {
    LVAtom* atom = [[self alloc] init];
    atom.token = tok;
    atom.atomType = atomType;
    atom.fullyEnclosedRange = tok.range;
    return atom;
}

- (void) highlightIn:(NSTextStorage*)attrString atLevel:(int)deepness {
    switch (self.atomType) {
        case LVAtomTypeSymbol: SDApplyStyle(attrString, SDThemeForSymbol, self.token.range, deepness); break;
        case LVAtomTypeKeyword: SDApplyStyle(attrString, SDThemeForKeyword, self.token.range, deepness); break;
        case LVAtomTypeString: SDApplyStyle(attrString, SDThemeForString, self.token.range, deepness); break;
        case LVAtomTypeRegex: SDApplyStyle(attrString, SDThemeForRegex, self.token.range, deepness); break;
        case LVAtomTypeNumber: SDApplyStyle(attrString, SDThemeForNumber, self.token.range, deepness); break;
        case LVAtomTypeTrue: SDApplyStyle(attrString, SDThemeForNumber, self.token.range, deepness); break;
        case LVAtomTypeFalse: SDApplyStyle(attrString, SDThemeForNumber, self.token.range, deepness); break;
        case LVAtomTypeNil: SDApplyStyle(attrString, SDThemeForNumber, self.token.range, deepness); break;
        case LVAtomTypeComment: SDApplyStyle(attrString, SDThemeForComment, self.token.range, deepness); break;
        case LVAtomTypeTypeOp: SDApplyStyle(attrString, SDThemeForTypeOp, self.token.range, deepness); break;
        case LVAtomTypeQuote: SDApplyStyle(attrString, SDThemeForQuote, self.token.range, deepness); break;
        case LVAtomTypeUnquote: SDApplyStyle(attrString, SDThemeForUnquote, self.token.range, deepness); break;
        case LVAtomTypeSyntaxQuote: SDApplyStyle(attrString, SDThemeForSyntaxQuote, self.token.range, deepness); break;
        case LVAtomTypeSplice: SDApplyStyle(attrString, SDThemeForSplice, self.token.range, deepness); break;
    }
}

@end
