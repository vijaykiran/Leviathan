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
    std::pair<std::vector<leviathan::lexer::token>, leviathan::ParserError> result = leviathan::lexer::lex(raw);
    std::vector<leviathan::lexer::token> tokens = result.first;
    leviathan::ParserError e = result.second;
    if (e.type == leviathan::ParserError::NoError) {
        std::cout << "Didn't fail: " << raw << std::endl;
        assert(false);
    }
    else {
//        printf("expected parser error %d == %d\n", e.type, leviathan::ParserError::UnclosedString);
//        NSLog(@"thought: %@, got: %@", NSStringFromRange(badRange), NSStringFromRange(e.badRange));
        assert(e.type == error);
        assert(NSEqualRanges(badRange, e.badRange));
    }
}

using namespace leviathan::lexer;

static void LVLexerShouldEqual(std::string raw, std::vector<leviathan::lexer::token> expected) {
    expected.insert(expected.begin(), token{token::Begin, ""});
    expected.push_back(token{token::End, ""});
    
    std::pair<std::vector<leviathan::lexer::token>, leviathan::ParserError> result = leviathan::lexer::lex(raw);
    std::vector<leviathan::lexer::token> tokens = result.first;
    leviathan::ParserError e = result.second;
    
    if (e.type == leviathan::ParserError::NoError) {
        if (tokens != expected) {
            std::cout << tokens << std::endl;
        }
    }
    else {
        std::cout << tokens << std::endl;
        assert(false);
    }
}

@implementation LVTestBed

+ (void) runTests {
    LVLexerShouldEqual("(foobar)", {{token::LParen, "("}, {token::Symbol, "foobar"}, {token::RParen, ")"}});
    LVLexerShouldEqual("foobar", {{token::Symbol, "foobar"}});
    LVLexerShouldEqual("(    foobar", {{token::LParen, "("}, {token::Spaces, "    "}, {token::Symbol, "foobar"}});
    
    LVLexerShouldEqual("\"yes\"", {{token::String, "\"yes\""}});
    LVLexerShouldEqual("\"y\\\"es\"", {{token::String, "\"y\\\"es\""}});
    
    LVLexerShouldEqual(";foobar\nhello", {{token::Comment, ";foobar"}, {token::Newline, "\n"}, {token::Symbol, "hello"}});
    
    LVLexerShouldError("\"yes", leviathan::ParserError::UnclosedString, NSMakeRange(0, 4));
    LVLexerShouldError("yes\"", leviathan::ParserError::UnclosedString, NSMakeRange(3, 1));
    LVLexerShouldError("\"yes\\\"", leviathan::ParserError::UnclosedString, NSMakeRange(0, 6));
    
    printf("ok\n");
}

@end
