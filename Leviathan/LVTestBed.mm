//
//  LVTestBed.m
//  Leviathan
//
//  Created by Steven on 10/19/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVTestBed.h"

#include "token.h"
#include "lexer.h"
#include "atom.h"
#include "parser.h"

static void LVLexerShouldError(std::string raw, leviathan::ParserError::ParserErrorType error, NSRange badRange) {
    std::pair<std::vector<leviathan::token*>, leviathan::ParserError> result = leviathan::lex(raw);
    std::vector<leviathan::token*> tokens = result.first;
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
        if (!NSEqualRanges(badRange, NSMakeRange(e.pos, e.len))) {
            std::cout << tokens << std::endl;
            NSLog(@"thought: %@, got: %@", NSStringFromRange(badRange), NSStringFromRange(NSMakeRange(e.pos, e.len)));
            exit(1);
        }
    }
}

using namespace leviathan;

static bool LVTokensEqual(std::vector<leviathan::token*> expected, std::vector<leviathan::token*> got) {
    if (got.size() != expected.size()) {
        return false;
    }
    
    for (size_t i = 0; i < got.size(); i++) {
        leviathan::token* t1 = got[i];
        leviathan::token* t2 = expected[i];
        if (!(*t1 == *t2)) {
            return false;
        }
    }
    
    return true;
}

static void LVLexerShouldEqual(std::string raw, std::vector<leviathan::token*> expected) {
    expected.insert(expected.begin(), new token{token::Begin, ""});
    expected.push_back(new token{token::End, ""});
    
    std::pair<std::vector<leviathan::token*>, leviathan::ParserError> result = leviathan::lex(raw);
    std::vector<leviathan::token*> tokens = result.first;
    leviathan::ParserError e = result.second;
    
    if (e.type == leviathan::ParserError::NoError) {
        if (!LVTokensEqual(expected, tokens)) {
            std::cout << "Tokens not equal: " << tokens << std::endl;
        }
    }
    else {
        std::cout << "Got error: " << tokens << std::endl;
        exit(1);
    }
}

@implementation LVTestBed

+ (void) runTests {
    LVLexerShouldEqual("(foobar)", {new token{token::LParen, "("}, new token{token::Symbol, "foobar"}, new token{token::RParen, ")"}});
    LVLexerShouldEqual("foobar", {new token{token::Symbol, "foobar"}});
    LVLexerShouldEqual("(    foobar", {new token{token::LParen, "("}, new token{token::Spaces, "    "}, new token{token::Symbol, "foobar"}});
    
    LVLexerShouldEqual("~", {new token{token::Unquote, "~"}});
    LVLexerShouldEqual("~@", {new token{token::Splice, "~@"}});
    
    LVLexerShouldEqual("\"yes\"", {new token{token::String, "\"yes\""}});
    LVLexerShouldEqual("\"y\\\"es\"", {new token{token::String, "\"y\\\"es\""}});
    
    LVLexerShouldEqual(";foobar\nhello", {new token{token::Comment, ";foobar"}, new token{token::Newline, "\n"}, new token{token::Symbol, "hello"}});
    
    LVLexerShouldEqual("foo 123 :hello", {new token{token::Symbol, "foo"}, new token{token::Spaces, " "}, new token{token::Number, "123"}, new token{token::Spaces, " "}, new token{token::Keyword, ":hello"}});
    
    LVLexerShouldError("\"yes", leviathan::ParserError::UnclosedString, NSMakeRange(0, 4));
    LVLexerShouldError("\"yes\\\"", leviathan::ParserError::UnclosedString, NSMakeRange(0, 6));
    LVLexerShouldError("yes\"", leviathan::ParserError::UnclosedString, NSMakeRange(3, 1));
    
    LVLexerShouldError("#\"yes", leviathan::ParserError::UnclosedRegex, NSMakeRange(0, 5));
    LVLexerShouldError("#\"yes\\\"", leviathan::ParserError::UnclosedRegex, NSMakeRange(0, 7));
    LVLexerShouldError("yes #\"", leviathan::ParserError::UnclosedRegex, NSMakeRange(4, 2));
    
    LVLexerShouldError("foo #", leviathan::ParserError::UnclosedDispatch, NSMakeRange(4, 1));
    
    LVLexerShouldEqual("#'foo", {new token{token::Var, "#'foo"}});
    LVLexerShouldEqual("#(foo)", {new token{token::AnonFnStart, "#("}, new token{token::Symbol, "foo"}, new token{token::RParen, ")"}});
    LVLexerShouldEqual("#{foo}", {new token{token::SetStart, "#{"}, new token{token::Symbol, "foo"}, new token{token::RBrace, "}"}});
    LVLexerShouldEqual("#_foo", {new token{token::ReaderCommentStart, "#_"}, new token{token::Symbol, "foo"}});
    LVLexerShouldEqual("#foo bar", {new token{token::ReaderMacro, "#foo"}, new token{token::Spaces, " "}, new token{token::Symbol, "bar"}});
    
    LVLexerShouldEqual("#\"yes\"", {new token{token::Regex, "#\"yes\""}});
    LVLexerShouldEqual("#\"y\\\"es\"", {new token{token::Regex, "#\"y\\\"es\""}});
    
    // bad test, delete me:
//    LVLexerShouldEqual(";fo obar\nhello", {{token::Comment, ";foobar"}, {token::Newline, "\n"}, {token::Symbol, "hello"}});
    
    {
        // NOTE: this is how you delete a list of tokens (not that we generally want to!)
        std::pair<std::vector<leviathan::token*>, leviathan::ParserError> result = leviathan::lex("foobar");
        auto tokens = result.first;
        for (std::vector<leviathan::token*>::iterator i = tokens.begin(); i != tokens.end(); ++i) {
            delete *i;
        }
    }
    
    leviathan::parse("foo");
    
    printf("ok\n");
    [NSApp terminate:self];
}

@end
