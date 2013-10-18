//
//  LeviathanTests.m
//  LeviathanTests
//
//  Created by Steven Degutis on 10/6/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SDExpectation.h"

#import "SDParser.h"

@interface LeviathanTests : XCTestCase
@end

@implementation LeviathanTests

- (void)testExample {
    
    {
        SDParseError* error;
        NSArray* elements = [SDParser parse:@"#" error:&error].childElements;
        
        [expect(elements) toEqual: Nil];
        [expect(@(error.errorType)) toEqual: @(SDParseErrorTypeUnfinishedDispatch)];
        [expect(@(error.badRange.location)) toEqual: @(0)];
        [expect(@(error.badRange.length)) toEqual: @(1)];
    }
    
    {
        SDParseError* error;
        NSArray* elements = [SDParser parse:@"\"foo" error:&error].childElements;
        
        [expect(elements) toEqual: Nil];
        [expect(@(error.errorType)) toEqual: @(SDParseErrorTypeUnclosedString)];
        [expect(@(error.badRange.location)) toEqual: @(0)];
        [expect(@(error.badRange.length)) toEqual: @(4)];
    }
    
    {
        SDParseError* error;
        NSArray* elements = [SDParser parse:@"(" error:&error].childElements;
        
        [expect(elements) toEqual: Nil];
        [expect(@(error.errorType)) toEqual: @(SDParseErrorTypeUnclosedOpener)];
        [expect(@(error.badRange.location)) toEqual: @(0)];
        [expect(@(error.badRange.length)) toEqual: @(1)];
    }
    
    {
        SDParseError* error;
        NSArray* elements = [SDParser parse:@")" error:&error].childElements;
        
        [expect(elements) toEqual: Nil];
        [expect(@(error != Nil)) toEqual: @YES];
        [expect(@(error.errorType)) toEqual: @(SDParseErrorTypeUnopenedCloser)];
        [expect(@(error.badRange.location)) toEqual: @(0)];
        [expect(@(error.badRange.length)) toEqual: @(1)];
    }
    
    {
        SDParseError* error;
        NSArray* elements = [SDParser parse:@"foo" error:&error].childElements;
        
        [expect(error) toEqual: Nil];
        [expect(@([elements count])) toEqual: @1];
        
        SDAtom* thing = [elements lastObject];
        
        [expect(@([thing isKindOfClass: [SDAtomSymbol class]])) toEqual: @YES];
        [expect(@(thing.token.type)) toEqual: @(BW_TOK_SYMBOL)];
        [expect(@(thing.token.range.location)) toEqual: @(0)];
        [expect(@(thing.token.range.length)) toEqual: @(3)];
    }
    
    {
        SDParseError* error;
        NSArray* elements = [SDParser parse:@"foo bar )" error:&error].childElements;
        
        [expect(elements) toEqual: Nil];
        [expect(@(error != Nil)) toEqual: @YES];
        [expect(@(error.errorType)) toEqual: @(SDParseErrorTypeUnopenedCloser)];
        [expect(@(error.badRange.location)) toEqual: @(8)];
        [expect(@(error.badRange.length)) toEqual: @(1)];
    }
    
    {
        SDParseError* error;
        NSArray* elements = [SDParser parse:@"()" error:&error].childElements;
        
        [expect(error) toEqual: Nil];
        [expect(@([elements count])) toEqual: @1];
        
        SDColl* thing = [elements lastObject];
        
        [expect(@(thing.collType)) toEqual: @(SDCollTypeList)];
        [expect(@(thing.openingToken.type)) toEqual: @(BW_TOK_LPAREN)];
        [expect(@(thing.openingToken.range.location)) toEqual: @(0)];
        [expect(@(thing.openingToken.range.length)) toEqual: @(1)];
        [expect(@(thing.closingToken.type)) toEqual: @(BW_TOK_RPAREN)];
        [expect(@(thing.closingToken.range.location)) toEqual: @(1)];
        [expect(@(thing.closingToken.range.length)) toEqual: @(1)];
    }
    
    {
        SDParseError* error;
        NSArray* elements = [SDParser parse:@"(())" error:&error].childElements;
        
        [expect(error) toEqual: Nil];
        [expect(@([elements count])) toEqual: @1];
        
        SDColl* thing = [elements lastObject];
        
        [expect(@(thing.collType)) toEqual: @(SDCollTypeList)];
        [expect(@(thing.openingToken.type)) toEqual: @(BW_TOK_LPAREN)];
        [expect(@(thing.openingToken.range.location)) toEqual: @(0)];
        [expect(@(thing.openingToken.range.length)) toEqual: @(1)];
        [expect(@(thing.closingToken.type)) toEqual: @(BW_TOK_RPAREN)];
        [expect(@(thing.closingToken.range.location)) toEqual: @(3)];
        [expect(@(thing.closingToken.range.length)) toEqual: @(1)];
    }
    
    {
        SDParseError* error;
        NSArray* elements = [SDParser parse:@"(()" error:&error].childElements;
        
        [expect(elements) toEqual: Nil];
        [expect(@(error.errorType)) toEqual: @(SDParseErrorTypeUnclosedOpener)];
        [expect(@(error.badRange.location)) toEqual: @(0)];
        [expect(@(error.badRange.length)) toEqual: @(1)];
    }
    
    
    // finding elements by pos
    
    
    void(^deepTester)(NSString* raw, SDCollType foundCollType, NSUInteger childIndex) = ^(NSString* raw, SDCollType foundCollType, NSUInteger childIndex) {
        SDParseError* error;
        SDColl* coll = [SDParser parse:[raw stringByReplacingOccurrencesOfString:@"|" withString:@""] error:&error];
        
        if (error != Nil) {
            XCTFail(@"wanted it to be nil etc...");
        }
        
        [expect(@(error == Nil)) toEqual: @YES];
        
        NSUInteger gotChildIndex;
        SDColl* inner = [coll deepestCollAtPos:[raw rangeOfString:@"|"].location childsIndex:&gotChildIndex];
        
        if (inner.collType != foundCollType) {
            XCTFail(@"ERROR: for %@ wanted colltype %d got %d", raw, foundCollType, inner.collType);
        }
        
        if (gotChildIndex != childIndex) {
            XCTFail(@"ERROR: for %@ wanted child index %ld got %ld", raw, childIndex, gotChildIndex);
        }
    };
    
    deepTester(@"|", SDCollTypeTopLevel, 0);
    deepTester(@"   |", SDCollTypeTopLevel, 0);
    deepTester(@"   |   ", SDCollTypeTopLevel, 0);
    deepTester(@"|   ", SDCollTypeTopLevel, 0);
    
    deepTester(@"|foo", SDCollTypeTopLevel, 0);
    deepTester(@"fo|o", SDCollTypeTopLevel, 0);
    deepTester(@"foo|", SDCollTypeTopLevel, 1);
    
    deepTester(@"(|)", SDCollTypeList, 0);
    deepTester(@"|()", SDCollTypeTopLevel, 0);
    deepTester(@"()|", SDCollTypeTopLevel, 1);
    
    deepTester(@"(foo| bar)", SDCollTypeList, 1);
    deepTester(@"(fo|o bar)", SDCollTypeList, 0);
    deepTester(@"(foo |bar)", SDCollTypeList, 1);
    deepTester(@"(foo bar|)", SDCollTypeList, 2);
    deepTester(@"(foo ba|r)", SDCollTypeList, 1);
    deepTester(@"(foo bar)|", SDCollTypeTopLevel, 1);
    
    deepTester(@"(foo [|bar])", SDCollTypeVector, 0);
    deepTester(@"(foo [|])", SDCollTypeVector, 0);
    deepTester(@"(foo [bar|])", SDCollTypeVector, 1);
    deepTester(@"(foo [bar]|)", SDCollTypeList, 2);
    
    deepTester(@"(foo [  |  ])", SDCollTypeVector, 0);
    deepTester(@"(foo [bar    |])", SDCollTypeVector, 1);
    
    deepTester(@"(|foo [bar])", SDCollTypeList, 0);
    deepTester(@"(f|oo [bar])", SDCollTypeList, 0);
    deepTester(@"(fo|o [bar])", SDCollTypeList, 0);
    deepTester(@"(foo| [bar])", SDCollTypeList, 1);
    deepTester(@"(foo |[bar])", SDCollTypeList, 1);
    deepTester(@"(foo [|bar])", SDCollTypeVector, 0);
    
    
    
    
    
    
    
    
    
    id na;
    
    na =
    @"foo";
    // type = symbol
    // parent = nil
    // token = (the only token)
    
    na =
    @":foo";
    // type = keyword
    // parent = nil
    // token = (the only token)
    
    na =
    @"true";
    // type = true
    // parent = nil
    // token = (the only token)
    
    na =
    @"(foo bar)";
    // type = list
    // parent = nil
    // open token = token for "("
    // close token = token for "("
    // children = [<foo>, <bar>]
    
    // foo and bar:
    // type = symbol
    // parent = <list>
    // token = (the only token)
    
    na =
    @"\"foo\"";
    // type = string
    // parent = nil
    // token = (the only token)
    
    na =
    @"'";
    // type = quote
    // parent = nil
    // token = (the only token)
    
    na =
    @"(";
    // ERROR: "unclosed list", point to list-opening token
    
    na =
    @")";
    // ERROR: "closing unopened list", point to list-closing token
    
    //    [expect(@4) toEqual: @4];
}

@end
