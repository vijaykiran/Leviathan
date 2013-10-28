//
//  LVHighlighter.h
//  Leviathan
//
//  Created by Steven on 10/18/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "doc.h"

typedef struct __LVHighlights {
    LVAtom* atom;
    size_t pos;
    size_t len;
    __unsafe_unretained NSDictionary* attrs;
} LVHighlights;

LVHighlights* LVHighlightsForDoc(LVDoc* doc);
NSDictionary* LVAttributesForAtom(LVAtom* atom);
