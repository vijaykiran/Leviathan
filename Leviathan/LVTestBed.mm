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
        std::cout << tokens << std::endl;
    }
    
    {
        std::string raw = "foobar";
        std::vector<leviathan::lexer::token> tokens = leviathan::lexer::lex(raw);
        std::cout << tokens << std::endl;
    }
    
    {
        std::string raw = "(   foobar";
        std::vector<leviathan::lexer::token> tokens = leviathan::lexer::lex(raw);
        std::cout << tokens << std::endl;
    }
    
    {
        std::string raw = "\"yes\"";
        std::vector<leviathan::lexer::token> tokens = leviathan::lexer::lex(raw);
        std::cout << tokens << std::endl;
    }
    
    {
        try {
            std::string raw = "\"yes";
            std::vector<leviathan::lexer::token> tokens = leviathan::lexer::lex(raw);
            std::cout << tokens << std::endl;
        }
        catch (leviathan::ParserError &e) {
            printf("expected parser error %d == %d\n", e.type, leviathan::ParserError::UnclosedString);
        }
    }
    
    {
        try {
            std::string raw = "yes\"";
            std::vector<leviathan::lexer::token> tokens = leviathan::lexer::lex(raw);
            std::cout << tokens << std::endl;
        }
        catch (leviathan::ParserError &e) {
            printf("expected parser error %d == %d\n", e.type, leviathan::ParserError::UnclosedString);
        }
    }
    
    {
        std::string raw = "\"y\\\"es\"";
        std::vector<leviathan::lexer::token> tokens = leviathan::lexer::lex(raw);
        std::cout << tokens << std::endl;
    }
    
    {
        try {
            std::string raw = "\"yes\\\"";
            std::vector<leviathan::lexer::token> tokens = leviathan::lexer::lex(raw);
            std::cout << tokens << std::endl;
        }
        catch (leviathan::ParserError &e) {
            printf("expected parser error %d == %d\n", e.type, leviathan::ParserError::UnclosedString);
        }
    }
    
    printf("ok\n");
}

@end
