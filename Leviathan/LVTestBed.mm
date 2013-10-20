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
        std::cout << tokens << std::endl;
        exit(1);
    }
    else {
        if (e.type != error) {
            std::cout << raw << std::endl;
            std::cout << tokens << std::endl;
            printf("expected parser error to be %d, got %d\n", error, e.type);
            exit(1);
        }
        if (!NSEqualRanges(badRange, e.badRange)) {
            std::cout << tokens << std::endl;
            NSLog(@"thought: %@, got: %@", NSStringFromRange(badRange), NSStringFromRange(e.badRange));
            exit(1);
        }
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
        std::cout << "Got error: " << tokens << std::endl;
        exit(1);
    }
}

@implementation LVTestBed

+ (void) runTests {
    LVLexerShouldEqual("(foobar)", {{token::LParen, "("}, {token::Symbol, "foobar"}, {token::RParen, ")"}});
    LVLexerShouldEqual("foobar", {{token::Symbol, "foobar"}});
    LVLexerShouldEqual("(    foobar", {{token::LParen, "("}, {token::Spaces, "    "}, {token::Symbol, "foobar"}});
    
    LVLexerShouldEqual("~", {{token::Unquote, "~"}});
    LVLexerShouldEqual("~@", {{token::Splice, "~@"}});
    
    LVLexerShouldEqual("\"yes\"", {{token::String, "\"yes\""}});
    LVLexerShouldEqual("\"y\\\"es\"", {{token::String, "\"y\\\"es\""}});
    
    LVLexerShouldEqual(";foobar\nhello", {{token::Comment, ";foobar"}, {token::Newline, "\n"}, {token::Symbol, "hello"}});
    
    LVLexerShouldEqual("foo 123 :hello", {{token::Symbol, "foo"}, {token::Spaces, " "}, {token::Number, "123"}, {token::Spaces, " "}, {token::Keyword, ":hello"}});
    
    LVLexerShouldError("\"yes", leviathan::ParserError::UnclosedString, NSMakeRange(0, 4));
    LVLexerShouldError("\"yes\\\"", leviathan::ParserError::UnclosedString, NSMakeRange(0, 6));
    LVLexerShouldError("yes\"", leviathan::ParserError::UnclosedString, NSMakeRange(3, 1));
    
    LVLexerShouldError("#\"yes", leviathan::ParserError::UnclosedRegex, NSMakeRange(0, 5));
    LVLexerShouldError("#\"yes\\\"", leviathan::ParserError::UnclosedRegex, NSMakeRange(0, 7));
    LVLexerShouldError("yes #\"", leviathan::ParserError::UnclosedRegex, NSMakeRange(4, 2));
    
    LVLexerShouldEqual("#\"yes\"", {{token::Regex, "#\"yes\""}});
    LVLexerShouldEqual("#\"y\\\"es\"", {{token::Regex, "#\"y\\\"es\""}});
    
    printf("ok\n");
}

@end
