//
//  LVTestBed.m
//  Leviathan
//
//  Created by Steven on 10/19/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVTestBed.h"

#include "lexer.h"

static void LVLexerShouldError(std::string raw, leviathan::ParserError::ParserErrorType error, NSRange badRange) {
    try {
        std::cout << "Testing: " << raw << std::endl;
        std::vector<leviathan::lexer::token> tokens = leviathan::lexer::lex(raw);
        assert(false);
    }
    catch (leviathan::ParserError &e) {
//        printf("expected parser error %d == %d\n", e.type, leviathan::ParserError::UnclosedString);
//        NSLog(@"thought: %@, got: %@", NSStringFromRange(badRange), NSStringFromRange(e.badRange));
        assert(e.type == error);
        assert(NSEqualRanges(badRange, e.badRange));
    }
}

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
        std::string raw = "\"y\\\"es\"";
        std::vector<leviathan::lexer::token> tokens = leviathan::lexer::lex(raw);
        std::cout << tokens << std::endl;
    }
    
    LVLexerShouldError("\"yes", leviathan::ParserError::UnclosedString, NSMakeRange(0, 4));
    LVLexerShouldError("yes\"", leviathan::ParserError::UnclosedString, NSMakeRange(3, 1));
    LVLexerShouldError("\"yes\\\"", leviathan::ParserError::UnclosedString, NSMakeRange(0, 6));
    
    printf("ok\n");
}

@end
