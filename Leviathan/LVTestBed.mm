//
//  LVTestBed.m
//  Leviathan
//
//  Created by Steven on 10/19/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVTestBed.h"

#include "lexer.h"

@implementation LVTestBed

+ (void) runTests {
    {
        std::string raw = "(foobar)";
        std::vector<leviathan::lexer::token> tokens = leviathan::lexer::lex(raw);
        for( std::vector<leviathan::lexer::token>::iterator i = tokens.begin(); i != tokens.end(); ++i)
            std::cout << *i << ' ';
        std::cout << std::endl;
    }
    
    {
        std::string raw = "foobar";
        std::vector<leviathan::lexer::token> tokens = leviathan::lexer::lex(raw);
        for( std::vector<leviathan::lexer::token>::iterator i = tokens.begin(); i != tokens.end(); ++i)
            std::cout << *i << ' ';
        std::cout << std::endl;
    }
    
    {
        std::string raw = "(   foobar";
        std::vector<leviathan::lexer::token> tokens = leviathan::lexer::lex(raw);
        for( std::vector<leviathan::lexer::token>::iterator i = tokens.begin(); i != tokens.end(); ++i)
            std::cout << *i << ' ';
        std::cout << std::endl;
    }
    
    printf("ok\n");
}

@end
