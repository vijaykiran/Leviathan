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
    std::pair<LVParseError*, std::vector<leviathan::token>> result = leviathan::lex(raw);
    
    std::vector<leviathan::token> tokens = result.second;
    
//    std::cout << result.second;
    
    for( std::vector<leviathan::token>::iterator i = tokens.begin(); i != tokens.end(); ++i)
        std::cout << i->type << ' ';
    
//    NSLog(@"%ld", result.second.size());
    
    std::cout << std::endl;
    
    NSLog(@"ok");
}

@end
