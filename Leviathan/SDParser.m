//
//  BWParser.m
//  Beowulf
//
//  Created by Steven on 9/21/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDParser.h"

#import "SDToken.h"



@implementation SDParseError

+ (SDParseError*) kind:(SDParseErrorType)kind with:(SDToken*)tok {
    SDParseError* err = [[SDParseError alloc] init];
    err.offendingToken = tok;
    err.errorType = kind;
    return err;
}

@end



@implementation SDParser

+ (id) parseColl:(NSArray*)tokens start:(NSUInteger)i ended:(NSUInteger*)ended collType:(SDCollType)collType endType:(BWTokenType)endType error:(SDParseError*__autoreleasing*)error {
    SDToken* firstToken = [tokens objectAtIndex:i];
    i++;
    
    NSMutableArray* children = [NSMutableArray array];
    
    SDToken* endToken;
    
    while (true) {
        
        endToken = [tokens objectAtIndex:i];
        if (endToken.type == endType) {
            *ended = i + 1;
            break;
        }
        else if (endToken.type == BW_TOK_FILE_END) {
            *error = [SDParseError kind:SDParseErrorTypeUnclosedOpener with:firstToken];
            return nil;
        }
        
        id<SDElement> child = [self parseOne:tokens start:i ended:ended error:error];
        if (*error)
            return nil;
        
        [children addObject:child];
        i = *ended;
    }
    
    SDColl* coll = [[SDColl alloc] init];
    coll.collType = collType;
    coll.openingToken = firstToken;
    coll.closingToken = endToken;
    coll.childElements = children;
    coll.fullyEnclosedRange = NSUnionRange(coll.openingToken.range, coll.closingToken.range);
    
    NSUInteger idx = 0;
    for (id<SDElement> child in coll.childElements) {
        child.parent = coll;
        child.idx = idx++;
    }
    return coll;
}

+ (id) parseOne:(NSArray*)tokens start:(NSUInteger)i ended:(NSUInteger*)ended error:(SDParseError*__autoreleasing*)error {
    SDToken* token = [tokens objectAtIndex:i];
    
    if (token.type == BW_TOK_SYMBOL) {
        *ended = i + 1;
        
        if ([token.val isEqualToString: @"true"])
            return [SDAtomTrue with:token];
        else if ([token.val isEqualToString: @"false"])
            return [SDAtomFalse with:token];
        else if ([token.val isEqualToString: @"nil"])
            return [SDAtomNil with:token];
        else
            return [SDAtomSymbol with:token];
    }
    else if (token.type == BW_TOK_NUMBER) {
        *ended = i + 1;
        return [SDAtomNumber with:token];
    }
    else if (token.type == BW_TOK_TYPEOP) {
        *ended = i + 1;
        return [SDAtomTypeOp with:token];
    }
    else if (token.type == BW_TOK_QUOTE) {
        *ended = i + 1;
        return [SDAtomQuote with:token];
    }
    else if (token.type == BW_TOK_UNQUOTE) {
        *ended = i + 1;
        return [SDAtomUnquote with:token];
    }
    else if (token.type == BW_TOK_SYNTAXQUOTE) {
        *ended = i + 1;
        return [SDAtomSyntaxQuote with:token];
    }
    else if (token.type == BW_TOK_SPLICE) {
        *ended = i + 1;
        return [SDAtomSplice with:token];
    }
    else if (token.type == BW_TOK_STRING) {
        *ended = i + 1;
        return [SDAtomString with:token];
    }
    else if (token.type == BW_TOK_REGEX) {
        *ended = i + 1;
        return [SDAtomRegex with:token];
    }
    else if (token.type == BW_TOK_COMMENT) {
        *ended = i + 1;
        return [SDAtomComment with:token];
    }
    else if (token.type == BW_TOK_KEYWORD) {
        *ended = i + 1;
        return [SDAtomKeyword with:token];
    }
    else if (token.type == BW_TOK_RPAREN || token.type == BW_TOK_RBRACKET || token.type == BW_TOK_RBRACE) {
        *error = [SDParseError kind:SDParseErrorTypeUnopenedCloser with:token];
        return nil;
    }
    else if (token.type == BW_TOK_LPAREN) {
        return [self parseColl:tokens start:i ended:ended collType:SDCollTypeList endType:BW_TOK_RPAREN error:error];
    }
    else if (token.type == BW_TOK_LBRACKET) {
        return [self parseColl:tokens start:i ended:ended collType:SDCollTypeVector endType:BW_TOK_RBRACKET error:error];
    }
    else if (token.type == BW_TOK_LBRACE) {
        return [self parseColl:tokens start:i ended:ended collType:SDCollTypeMap endType:BW_TOK_RBRACE error:error];
    }
    
    [NSException raise:@"ParserFoundBadToken" format:@"Parser doesn't handle token: %@", [token description]];
    __builtin_unreachable();
}

+ (SDColl*) parse:(NSString*)raw error:(SDParseError*__autoreleasing*)error {
    NSArray* tokens = [SDToken tokenize:raw];
    NSUInteger ended;
    return [self parseColl:tokens start:0 ended:&ended collType:SDCollTypeTopLevel endType:BW_TOK_FILE_END error:error];
}

@end
