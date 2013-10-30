//
//  configs.m
//  Leviathan
//
//  Created by Steven Degutis on 10/24/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "configs.h"

#import "Beowulf.h"

id LVParseConfigFromString(NSString* str) {
    BWEnv* env = [Beowulf basicEnv];
    NSString* prelude = [NSString stringWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"prelude" withExtension:@"bwlf"] encoding:NSUTF8StringEncoding error:NULL];
    [Beowulf eval:prelude env:env error:NULL];
    return [Beowulf eval:str env:env error:NULL];
}
