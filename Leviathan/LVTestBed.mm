//
//  LVTestBed.m
//  Leviathan
//
//  Created by Steven on 10/19/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVTestBed.h"

#include "parser.h"

@implementation LVTestBed

+ (void) runTests {
    std::string raw = "(foobar)";
    std::vector<leviathan::token> tokens = leviathan::lex(raw);
    
//    std::cout << leviathan::LParen << std::endl;
    
    for( std::vector<leviathan::token>::iterator i = tokens.begin(); i != tokens.end(); ++i)
        std::cout << *i << ' ';
    
    std::cout << std::endl;
    
    NSLog(@"ok");
}

@end
