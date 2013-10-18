////
////  LeviathanTests.m
////  LeviathanTests
////
////  Created by Steven Degutis on 10/6/13.
////  Copyright (c) 2013 Steven Degutis. All rights reserved.
////
//
//#import <XCTest/XCTest.h>
//#import "SDExpectation.h"
//
//#import "LVParser.h"
//
//@interface LeviathanTests : XCTestCase
//@end
//
//@implementation LeviathanTests
//
//- (void)testExample {
//    
//    {
//        LVParseError* error;
//        NSArray* elements = [LVParser parse:@"#" error:&error].childElements;
//        
//        [expect(elements) toEqual: Nil];
//        [expect(@(error.errorType)) toEqual: @(LVParseErrorTypeUnfinishedDispatch)];
//        [expect(@(error.badRange.location)) toEqual: @(0)];
//        [expect(@(error.badRange.length)) toEqual: @(1)];
//    }
//    
//    {
//        LVParseError* error;
//        NSArray* elements = [LVParser parse:@"\"foo" error:&error].childElements;
//        
//        [expect(elements) toEqual: Nil];
//        [expect(@(error.errorType)) toEqual: @(LVParseErrorTypeUnclosedString)];
//        [expect(@(error.badRange.location)) toEqual: @(0)];
//        [expect(@(error.badRange.length)) toEqual: @(4)];
//    }
//    
//    {
//        LVParseError* error;
//        NSArray* elements = [LVParser parse:@"(" error:&error].childElements;
//        
//        [expect(elements) toEqual: Nil];
//        [expect(@(error.errorType)) toEqual: @(LVParseErrorTypeUnclosedOpener)];
//        [expect(@(error.badRange.location)) toEqual: @(0)];
//        [expect(@(error.badRange.length)) toEqual: @(1)];
//    }
//    
//    {
//        LVParseError* error;
//        NSArray* elements = [LVParser parse:@")" error:&error].childElements;
//        
//        [expect(elements) toEqual: Nil];
//        [expect(@(error != Nil)) toEqual: @YES];
//        [expect(@(error.errorType)) toEqual: @(LVParseErrorTypeUnopenedCloser)];
//        [expect(@(error.badRange.location)) toEqual: @(0)];
//        [expect(@(error.badRange.length)) toEqual: @(1)];
//    }
//    
//    {
//        LVParseError* error;
//        NSArray* elements = [LVParser parse:@"foo" error:&error].childElements;
//        
//        [expect(error) toEqual: Nil];
//        [expect(@([elements count])) toEqual: @1];
//        
//        SDAtom* thing = [elements lastObject];
//        
//        [expect(@([thing isKindOfClass: [SDAtomSymbol class]])) toEqual: @YES];
//        [expect(@(thing.token.type)) toEqual: @(LV_TOK_SYMBOL)];
//        [expect(@(thing.token.range.location)) toEqual: @(0)];
//        [expect(@(thing.token.range.length)) toEqual: @(3)];
//    }
//    
//    {
//        LVParseError* error;
//        NSArray* elements = [LVParser parse:@"foo bar )" error:&error].childElements;
//        
//        [expect(elements) toEqual: Nil];
//        [expect(@(error != Nil)) toEqual: @YES];
//        [expect(@(error.errorType)) toEqual: @(LVParseErrorTypeUnopenedCloser)];
//        [expect(@(error.badRange.location)) toEqual: @(8)];
//        [expect(@(error.badRange.length)) toEqual: @(1)];
//    }
//    
//    {
//        LVParseError* error;
//        NSArray* elements = [LVParser parse:@"()" error:&error].childElements;
//        
//        [expect(error) toEqual: Nil];
//        [expect(@([elements count])) toEqual: @1];
//        
//        SDColl* thing = [elements lastObject];
//        
//        [expect(@(thing.collType)) toEqual: @(LVCollTypeList)];
//        [expect(@(thing.openingToken.type)) toEqual: @(LV_TOK_LPAREN)];
//        [expect(@(thing.openingToken.range.location)) toEqual: @(0)];
//        [expect(@(thing.openingToken.range.length)) toEqual: @(1)];
//        [expect(@(thing.closingToken.type)) toEqual: @(LV_TOK_RPAREN)];
//        [expect(@(thing.closingToken.range.location)) toEqual: @(1)];
//        [expect(@(thing.closingToken.range.length)) toEqual: @(1)];
//    }
//    
//    {
//        LVParseError* error;
//        NSArray* elements = [LVParser parse:@"(())" error:&error].childElements;
//        
//        [expect(error) toEqual: Nil];
//        [expect(@([elements count])) toEqual: @1];
//        
//        SDColl* thing = [elements lastObject];
//        
//        [expect(@(thing.collType)) toEqual: @(LVCollTypeList)];
//        [expect(@(thing.openingToken.type)) toEqual: @(LV_TOK_LPAREN)];
//        [expect(@(thing.openingToken.range.location)) toEqual: @(0)];
//        [expect(@(thing.openingToken.range.length)) toEqual: @(1)];
//        [expect(@(thing.closingToken.type)) toEqual: @(LV_TOK_RPAREN)];
//        [expect(@(thing.closingToken.range.location)) toEqual: @(3)];
//        [expect(@(thing.closingToken.range.length)) toEqual: @(1)];
//    }
//    
//    {
//        LVParseError* error;
//        NSArray* elements = [LVParser parse:@"(()" error:&error].childElements;
//        
//        [expect(elements) toEqual: Nil];
//        [expect(@(error.errorType)) toEqual: @(LVParseErrorTypeUnclosedOpener)];
//        [expect(@(error.badRange.location)) toEqual: @(0)];
//        [expect(@(error.badRange.length)) toEqual: @(1)];
//    }
//    
//    
//    // finding elements by pos
//    
//    
//    void(^deepTester)(NSString* raw, LVCollType foundCollType, NSUInteger childIndex) = ^(NSString* raw, LVCollType foundCollType, NSUInteger childIndex) {
//        LVParseError* error;
//        SDColl* coll = [LVParser parse:[raw stringByReplacingOccurrencesOfString:@"|" withString:@""] error:&error];
//        
//        if (error != Nil) {
//            XCTFail(@"wanted it to be nil etc...");
//        }
//        
//        [expect(@(error == Nil)) toEqual: @YES];
//        
//        NSUInteger gotChildIndex;
//        SDColl* inner = [coll deepestCollAtPos:[raw rangeOfString:@"|"].location childsIndex:&gotChildIndex];
//        
//        if (inner.collType != foundCollType) {
//            XCTFail(@"ERROR: for %@ wanted colltype %d got %d", raw, foundCollType, inner.collType);
//        }
//        
//        if (gotChildIndex != childIndex) {
//            XCTFail(@"ERROR: for %@ wanted child index %ld got %ld", raw, childIndex, gotChildIndex);
//        }
//    };
//    
//    deepTester(@"|", LVCollTypeTopLevel, 0);
//    deepTester(@"   |", LVCollTypeTopLevel, 0);
//    deepTester(@"   |   ", LVCollTypeTopLevel, 0);
//    deepTester(@"|   ", LVCollTypeTopLevel, 0);
//    
//    deepTester(@"|foo", LVCollTypeTopLevel, 0);
//    deepTester(@"fo|o", LVCollTypeTopLevel, 0);
//    deepTester(@"foo|", LVCollTypeTopLevel, 1);
//    
//    deepTester(@"(|)", LVCollTypeList, 0);
//    deepTester(@"|()", LVCollTypeTopLevel, 0);
//    deepTester(@"()|", LVCollTypeTopLevel, 1);
//    
//    deepTester(@"(foo| bar)", LVCollTypeList, 1);
//    deepTester(@"(fo|o bar)", LVCollTypeList, 0);
//    deepTester(@"(foo |bar)", LVCollTypeList, 1);
//    deepTester(@"(foo bar|)", LVCollTypeList, 2);
//    deepTester(@"(foo ba|r)", LVCollTypeList, 1);
//    deepTester(@"(foo bar)|", LVCollTypeTopLevel, 1);
//    
//    deepTester(@"(foo [|bar])", LVCollTypeVector, 0);
//    deepTester(@"(foo [|])", LVCollTypeVector, 0);
//    deepTester(@"(foo [bar|])", LVCollTypeVector, 1);
//    deepTester(@"(foo [bar]|)", LVCollTypeList, 2);
//    
//    deepTester(@"(foo [  |  ])", LVCollTypeVector, 0);
//    deepTester(@"(foo [bar    |])", LVCollTypeVector, 1);
//    
//    deepTester(@"(|foo [bar])", LVCollTypeList, 0);
//    deepTester(@"(f|oo [bar])", LVCollTypeList, 0);
//    deepTester(@"(fo|o [bar])", LVCollTypeList, 0);
//    deepTester(@"(foo| [bar])", LVCollTypeList, 1);
//    deepTester(@"(foo |[bar])", LVCollTypeList, 1);
//    deepTester(@"(foo [|bar])", LVCollTypeVector, 0);
//    
//    
//    
//    
//    
//    
//    
//    
//    
//    id na;
//    
//    na =
//    @"foo";
//    // type = symbol
//    // parent = nil
//    // token = (the only token)
//    
//    na =
//    @":foo";
//    // type = keyword
//    // parent = nil
//    // token = (the only token)
//    
//    na =
//    @"true";
//    // type = true
//    // parent = nil
//    // token = (the only token)
//    
//    na =
//    @"(foo bar)";
//    // type = list
//    // parent = nil
//    // open token = token for "("
//    // close token = token for "("
//    // children = [<foo>, <bar>]
//    
//    // foo and bar:
//    // type = symbol
//    // parent = <list>
//    // token = (the only token)
//    
//    na =
//    @"\"foo\"";
//    // type = string
//    // parent = nil
//    // token = (the only token)
//    
//    na =
//    @"'";
//    // type = quote
//    // parent = nil
//    // token = (the only token)
//    
//    na =
//    @"(";
//    // ERROR: "unclosed list", point to list-opening token
//    
//    na =
//    @")";
//    // ERROR: "closing unopened list", point to list-closing token
//    
//    //    [expect(@4) toEqual: @4];
//}
//
//@end
