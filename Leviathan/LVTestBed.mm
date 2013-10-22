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

using namespace Leviathan;

static void LVLexerShouldError(std::string raw, ParserError::Type error, NSRange badRange) {
    std::pair<std::vector<Token*>, ParserError> result = lex(raw);
    std::vector<Token*> tokens = result.first;
    ParserError e = result.second;
    if (e.type == ParserError::NoError) {
        std::cout << "Didn't see expected error: " << raw << std::endl;
//        std::cout << tokens << std::endl;
        exit(1);
    }
    else {
        if (e.type != error) {
            std::cout << raw << std::endl;
//            std::cout << tokens << std::endl;
            printf("expected parser error to be %d, got %d\n", error, e.type);
            exit(1);
        }
        if (!NSEqualRanges(badRange, NSMakeRange(e.pos, e.len))) {
//            std::cout << tokens << std::endl;
            NSLog(@"thought: %@, got: %@", NSStringFromRange(badRange), NSStringFromRange(NSMakeRange(e.pos, e.len)));
            exit(1);
        }
    }
}

static bool LVTokensEqual(std::vector<Token*> expected, std::vector<Token*> got) {
    if (got.size() != expected.size()) {
        return false;
    }
    
    for (size_t i = 0; i < got.size(); i++) {
        Token* t1 = got[i];
        Token* t2 = expected[i];
        
        if (t1->type != t2->type || t1->val != t2->val) {
            return false;
        }
    }
    
    return true;
}

static void LVLexerShouldEqual(std::string raw, std::vector<Token*> expected) {
    expected.insert(expected.begin(), new Token{Token::FileBegin, ""});
    expected.push_back(new Token{Token::FileEnd, ""});
    
    std::pair<std::vector<Token*>, ParserError> result = lex(raw);
    std::vector<Token*> tokens = result.first;
    ParserError e = result.second;
    
    if (e.type == ParserError::NoError) {
        if (!LVTokensEqual(expected, tokens)) {
            std::cout << "Tokens not equal: " << tokens.size() << std::endl;
            exit(1);
        }
    }
    else {
        std::cout << "Got error: " << tokens.size() << std::endl;
        exit(1);
    }
}

@implementation LVTestBed

+ (void) runTests {
    LVLexerShouldEqual("(foobar)", {new Token{Token::LParen, "("}, new Token{Token::Symbol, "foobar"}, new Token{Token::RParen, ")"}});
    LVLexerShouldEqual("foobar", {new Token{Token::Symbol, "foobar"}});
    LVLexerShouldEqual("(    foobar", {new Token{Token::LParen, "("}, new Token{Token::Spaces, "    "}, new Token{Token::Symbol, "foobar"}});
    
    LVLexerShouldEqual("~", {new Token{Token::Unquote, "~"}});
    LVLexerShouldEqual("~@", {new Token{Token::Splice, "~@"}});
    
    LVLexerShouldEqual("\"yes\"", {new Token{Token::String, "\"yes\""}});
    LVLexerShouldEqual("\"y\\\"es\"", {new Token{Token::String, "\"y\\\"es\""}});
    
    LVLexerShouldEqual(";foobar\nhello", {new Token{Token::Comment, ";foobar"}, new Token{Token::Newline, "\n"}, new Token{Token::Symbol, "hello"}});
    
    LVLexerShouldEqual("foo 123 :hello", {new Token{Token::Symbol, "foo"}, new Token{Token::Spaces, " "}, new Token{Token::Number, "123"}, new Token{Token::Spaces, " "}, new Token{Token::Keyword, ":hello"}});
    
    LVLexerShouldError("\"yes", ParserError::UnclosedString, NSMakeRange(0, 4));
    LVLexerShouldError("\"yes\\\"", ParserError::UnclosedString, NSMakeRange(0, 6));
    LVLexerShouldError("yes\"", ParserError::UnclosedString, NSMakeRange(3, 1));
    
    LVLexerShouldError("#\"yes", ParserError::UnclosedRegex, NSMakeRange(0, 5));
    LVLexerShouldError("#\"yes\\\"", ParserError::UnclosedRegex, NSMakeRange(0, 7));
    LVLexerShouldError("yes #\"", ParserError::UnclosedRegex, NSMakeRange(4, 2));
    
    LVLexerShouldError("foo #", ParserError::UnclosedDispatch, NSMakeRange(4, 1));
    
    LVLexerShouldEqual("#'foo", {new Token{Token::Var, "#'foo"}});
    LVLexerShouldEqual("#(foo)", {new Token{Token::AnonFnStart, "#("}, new Token{Token::Symbol, "foo"}, new Token{Token::RParen, ")"}});
    LVLexerShouldEqual("#{foo}", {new Token{Token::SetStart, "#{"}, new Token{Token::Symbol, "foo"}, new Token{Token::RBrace, "}"}});
    LVLexerShouldEqual("#_foo", {new Token{Token::ReaderCommentStart, "#_"}, new Token{Token::Symbol, "foo"}});
    LVLexerShouldEqual("#foo bar", {new Token{Token::ReaderMacro, "#foo"}, new Token{Token::Spaces, " "}, new Token{Token::Symbol, "bar"}});
    
    LVLexerShouldEqual("#\"yes\"", {new Token{Token::Regex, "#\"yes\""}});
    LVLexerShouldEqual("#\"y\\\"es\"", {new Token{Token::Regex, "#\"y\\\"es\""}});
    
    // bad test, delete me:
//    LVLexerShouldEqual(";fo obar\nhello", {{token::Comment, ";foobar"}, {token::Newline, "\n"}, {token::Symbol, "hello"}});
    
    {
        // NOTE: this is how you delete a list of tokens (not that we generally want to!)
        std::pair<std::vector<Token*>, ParserError> result = lex("foobar");
        auto tokens = result.first;
        for (std::vector<Token*>::iterator i = tokens.begin(); i != tokens.end(); ++i) {
            delete *i;
        }
    }
    
    {
        std::pair<Coll*, ParserError> result = parse("foo");
        assert(result.second.type == ParserError::NoError);
        assert(result.first->collType == Coll::TopLevel);
        delete result.first;
    }
    
    {
        std::pair<Coll*, ParserError> result = parse("(foo");
        assert(result.second.type == ParserError::UnclosedColl);
    }
    
    {
        std::pair<Coll*, ParserError> result = parse("(foo)");
        assert(result.second.type == ParserError::NoError);
        assert(result.first->collType == Coll::TopLevel);
        delete result.first;
    }
    
    {
        std::pair<Coll*, ParserError> result = parse("123");
        assert(result.second.type == ParserError::NoError);
        assert(result.first->collType == Coll::TopLevel);
        delete result.first;
    }
    
    printf("ok\n");
    [NSApp terminate:self];
}

@end
