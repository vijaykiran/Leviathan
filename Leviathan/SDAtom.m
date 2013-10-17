//
//  SDAtom.m
//  Leviathan
//
//  Created by Steven on 10/12/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDAtom.h"

#import "SDColl.h"
#import "SDTheme.h"

@implementation SDAtom

@synthesize parent;
@synthesize idx;

@synthesize fullyEnclosedRange;

- (BOOL) isColl { return NO; }
- (BOOL) isAtom { return YES; }
- (SDColl*) asColl { return nil; }
- (SDAtom*) asAtom { return self; }

+ (SDAtom*) with:(SDToken*)tok {
    SDAtom* atom = [[self alloc] init];
    atom.token = tok;
    atom.fullyEnclosedRange = tok.range;
    return atom;
}

- (void) highlightIn:(NSTextStorage*)attrString atLevel:(int)deepness {
}

@end



@implementation SDAtomSymbol

- (void) highlightIn:(NSTextStorage*)attrString atLevel:(int)deepness {
    if ([self.token.val hasPrefix:@"def"]
        && [self.parent isColl]
        && self.parent.asColl.collType == SDCollTypeList
        && self.idx == 0)
    {
        SDApplyStyle(attrString, SDThemeForDef, self.token.range, deepness);
    }
    else if (self.idx == 1
             && self.parent.asColl.collType == SDCollTypeList
             && [[self.parent.asColl.childElements objectAtIndex:0] isAtom]
             && [[[self.parent.asColl.childElements objectAtIndex:0] asAtom] isKindOfClass: [SDAtomSymbol self]]
             && [[[[[self.parent.asColl.childElements objectAtIndex:0] asAtom] token] val] hasPrefix: @"def"])
    {
        SDApplyStyle(attrString, SDThemeForDefName, self.token.range, deepness);
    }
    else {
        SDApplyStyle(attrString, SDThemeForSymbol, self.token.range, deepness);
    }
}

@end

@implementation SDAtomKeyword

- (void) highlightIn:(NSTextStorage*)attrString atLevel:(int)deepness {
    SDApplyStyle(attrString, SDThemeForKeyword, self.token.range, deepness);
}

@end

@implementation SDAtomString

- (void) highlightIn:(NSTextStorage*)attrString atLevel:(int)deepness {
    SDApplyStyle(attrString, SDThemeForString, self.token.range, deepness);
}

@end

@implementation SDAtomRegex

- (void) highlightIn:(NSTextStorage*)attrString atLevel:(int)deepness {
    SDApplyStyle(attrString, SDThemeForRegex, self.token.range, deepness);
}

@end

@implementation SDAtomNumber

- (void) highlightIn:(NSTextStorage*)attrString atLevel:(int)deepness {
    SDApplyStyle(attrString, SDThemeForNumber, self.token.range, deepness);
}

@end

@implementation SDAtomTrue

- (void) highlightIn:(NSTextStorage*)attrString atLevel:(int)deepness {
    SDApplyStyle(attrString, SDThemeForNumber, self.token.range, deepness);
}

@end

@implementation SDAtomFalse

- (void) highlightIn:(NSTextStorage*)attrString atLevel:(int)deepness {
    SDApplyStyle(attrString, SDThemeForNumber, self.token.range, deepness);
}

@end

@implementation SDAtomNil

- (void) highlightIn:(NSTextStorage*)attrString atLevel:(int)deepness {
    SDApplyStyle(attrString, SDThemeForNumber, self.token.range, deepness);
}

@end

@implementation SDAtomComment

- (void) highlightIn:(NSTextStorage*)attrString atLevel:(int)deepness {
    SDApplyStyle(attrString, SDThemeForComment, self.token.range, deepness);
}

@end

@implementation SDAtomTypeOp

- (void) highlightIn:(NSTextStorage*)attrString atLevel:(int)deepness {
    SDApplyStyle(attrString, SDThemeForTypeOp, self.token.range, deepness);
}

@end

@implementation SDAtomQuote

- (void) highlightIn:(NSTextStorage*)attrString atLevel:(int)deepness {
    SDApplyStyle(attrString, SDThemeForQuote, self.token.range, deepness);
}

@end

@implementation SDAtomUnquote

- (void) highlightIn:(NSTextStorage*)attrString atLevel:(int)deepness {
    SDApplyStyle(attrString, SDThemeForUnquote, self.token.range, deepness);
}

@end

@implementation SDAtomSyntaxQuote

- (void) highlightIn:(NSTextStorage*)attrString atLevel:(int)deepness {
    SDApplyStyle(attrString, SDThemeForSyntaxQuote, self.token.range, deepness);
}

@end

@implementation SDAtomSplice

- (void) highlightIn:(NSTextStorage*)attrString atLevel:(int)deepness {
    SDApplyStyle(attrString, SDThemeForSplice, self.token.range, deepness);
}

@end
