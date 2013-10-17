//
//  SDColl.m
//  Leviathan
//
//  Created by Steven on 10/12/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDColl.h"

#import "SDTheme.h"

@implementation SDColl

@synthesize parent;
@synthesize idx;

@synthesize fullyEnclosedRange;

- (BOOL) isColl { return YES; }
- (BOOL) isAtom { return NO; }
- (SDColl*) asColl { return self; }
- (SDAtom*) asAtom { return nil; }

- (void) highlightIn:(NSTextStorage*)attrString atLevel:(int)deepness {
    if (self.collType != SDCollTypeTopLevel) {
        SDApplyStyle(attrString, SDThemeForRainbowParens, self.openingToken.range, deepness);
        SDApplyStyle(attrString, SDThemeForRainbowParens, self.closingToken.range, deepness);
    }
    
    for (id<SDElement> child in self.childElements) {
        [child highlightIn:attrString atLevel:deepness + 1];
    }
}

- (SDColl*) deepestCollAtPos:(NSUInteger)pos childsIndex:(NSUInteger*)childsIndex {
    int i = 0;
    
    if (pos <= NSMaxRange(self.openingToken.range)) {
        *childsIndex = 0;
        return self;
    }
    
    for (id<SDElement> child in self.childElements) {
        
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

@end
