//
//  SDColl.m
//  Leviathan
//
//  Created by Steven on 10/12/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVColl.h"

#import "LVTheme.h"

#import "LVAtom.h"

@implementation LVColl

@synthesize parent;
@synthesize idx;

@synthesize fullyEnclosedRange;

- (BOOL) isColl { return YES; }
- (BOOL) isAtom { return NO; }
- (LVColl*) asColl { return self; }
- (LVAtom*) asAtom { return nil; }

- (void) highlightIn:(NSTextStorage*)attrString atLevel:(int)deepness {
    if (self.collType != LVCollTypeTopLevel) {
        SDApplyStyle(attrString, SDThemeForRainbowParens, self.openingToken.range, deepness);
        SDApplyStyle(attrString, SDThemeForRainbowParens, self.closingToken.range, deepness);
    }
    
    for (id<LVElement> child in self.childElements) {
        [child highlightIn:attrString atLevel:deepness + 1];
    }
}

- (LVColl*) deepestCollAtPos:(NSUInteger)pos childsIndex:(NSUInteger*)childsIndex {
    int i = 0;
    
    if (pos <= NSMaxRange(self.openingToken.range)) {
        *childsIndex = 0;
        return self;
    }
    
    for (id<LVElement> child in self.childElements) {
        
        if (pos < NSMaxRange([child fullyEnclosedRange])) {
            
            if ([child isAtom]) {
                *childsIndex = i;
                return self;
            }
            else {
                if (pos <= [child fullyEnclosedRange].location) {
                    *childsIndex = i;
                    return self;
                }
                else {
                    return [[child asColl] deepestCollAtPos:pos childsIndex:childsIndex];
                }
            }
            
        }
        
        i++;
    }
    
    *childsIndex = i;
    return self;
}

- (void) findDefinitions:(NSMutableArray*)defs {
    for (id<LVElement> child in self.childElements) {
        if ([child isKindOfClass:[SDDefinition self]]) {
            [defs addObject:child];
        }
        
        if ([child isColl]) {
            [[child asColl] findDefinitions:defs];
        }
    }
}

@end

@implementation SDDefinition

- (void) highlightIn:(NSTextStorage*)attrString atLevel:(int)deepness {
    [super highlightIn:attrString atLevel:deepness];
    
    SDApplyStyle(attrString, SDThemeForDef, self.defType.token.range, deepness);
    SDApplyStyle(attrString, SDThemeForDefName, self.defName.token.range, deepness);
}

@end
