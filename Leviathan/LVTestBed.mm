//
//  LVTestBed.m
//  Leviathan
//
//  Created by Steven on 10/19/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVTestBed.h"

#include "token.h"

@implementation LVTestBed

+ (void) runTests {
    {
        std::string raw = "(foobar)";
        std::vector<leviathan::token> tokens = leviathan::lex(raw);
        for( std::vector<leviathan::token>::iterator i = tokens.begin(); i != tokens.end(); ++i)
            std::cout << *i << ' ';
        std::cout << std::endl;
    }
    
    {
        std::string raw = "foobar";
        std::vector<leviathan::token> tokens = leviathan::lex(raw);
        for( std::vector<leviathan::token>::iterator i = tokens.begin(); i != tokens.end(); ++i)
            std::cout << *i << ' ';
        std::cout << std::endl;
    }
    
    {
        std::string raw = "(   foobar";
        std::vector<leviathan::token> tokens = leviathan::lex(raw);
        for( std::vector<leviathan::token>::iterator i = tokens.begin(); i != tokens.end(); ++i)
            std::cout << *i << ' ';
        std::cout << std::endl;
    }
    
    printf("ok\n");
}

@end
