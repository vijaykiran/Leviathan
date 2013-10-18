//
//  SDColl.m
//  Leviathan
//
//  Created by Steven on 10/12/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVColl.h"

#import "LVThemeManager.h"
#import "LVHighlighter.h"

#import "LVAtom.h"

@implementation LVColl

@synthesize parent;
@synthesize idx;

@synthesize fullyEnclosedRange;

- (BOOL) isColl { return YES; }
- (BOOL) isAtom { return NO; }
- (LVColl*) asColl { return self; }
- (LVAtom*) asAtom { return nil; }

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
        if ([child isKindOfClass:[LVDefinition self]]) {
            [defs addObject:child];
        }
        
        if ([child isColl]) {
            [[child asColl] findDefinitions:defs];
        }
    }
}

@end

@implementation LVDefinition

@end
