//
//  SDAtom.m
//  Leviathan
//
//  Created by Steven on 10/12/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVAtom.h"

#import "LVColl.h"

#import "LVThemeManager.h"
#import "LVHighlighter.h"

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

@end
