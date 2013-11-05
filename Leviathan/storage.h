//
//  storage.h
//  Leviathan
//
//  Created by Steven Degutis on 11/5/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "coll.h"
#import "token.h"

typedef struct __LVStorage {
    CFStringRef wholeString;
    
    LVToken* tokens;
    LVAtom* atoms;
    LVColl* colls;
    CFStringRef* substrings;
    
    NSUInteger tokenCount;
    NSUInteger atomCount;
    NSUInteger collCount;
    NSUInteger substringCount;
} LVStorage;
