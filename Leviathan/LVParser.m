//
//  BWParser.m
//  Beowulf
//
//  Created by Steven on 9/21/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVParser.h"

#import "LVToken.h"

@implementation LVParser

+ (id) parseColl:(NSArray*)tokens start:(NSUInteger)i ended:(NSUInteger*)ended collType:(LVCollType)collType endType:(BWTokenType)endType error:(LVParseError*__autoreleasing*)error {
    LVToken* firstToken = [tokens objectAtIndex:i];
    i++;
    
    NSMutableArray* children = [NSMutableArray array];
    
    LVToken* endToken;
    
    while (true) {
        
        endToken = [tokens objectAtIndex:i];
        if (endToken.type == endType) {
            *ended = i + 1;
            break;
        }
        else if (endToken.type == LV_TOK_FILE_END) {
            *error = [LVParseError kind:LVParseErrorTypeUnclosedOpener with:firstToken.range];
            return nil;
        }
        
        id<LVElement> child = [self parseOne:tokens start:i ended:ended error:error];
        if (*error)
            return nil;
        
        [children addObject:child];
        i = *ended;
    }
    
    BOOL isDef = NO;
    LVAtom* defType;
    LVAtom* defName;
    
    if (collType == LVCollTypeList) {
        if ([children count] >= 2) {
            LVAtom* firstChild = [children objectAtIndex:0];
            if ([firstChild isAtom]) {
                if ([[[firstChild token] val] hasPrefix:@"def"]) {
                    isDef = YES;
                    defType = firstChild;
                    
                    for (NSUInteger i = 1; i < [children count]; i++) {
                        LVAtom* child = [children objectAtIndex:i];
                        
                        if (child.atomType == LVAtomTypeSymbol) {
                            defName = child;
                            break;
                        }
                    }
                }
            }
        }
    }
    
    LVColl* coll;
    
    if (isDef) {
        LVDefinition* def = [[LVDefinition alloc] init];
        
        def.defName = defName;
        def.defType = defType;
        
        coll = def;
    }
    else {
        coll = [[LVColl alloc] init];
    }
    
    coll.collType = collType;
    coll.openingToken = firstToken;
    coll.closingToken = endToken;
    coll.childElements = children;
    coll.fullyEnclosedRange = NSUnionRange(coll.openingToken.range, coll.closingToken.range);
    
    NSUInteger idx = 0;
    for (id<LVElement> child in coll.childElements) {
        child.parent = coll;
        child.idx = idx++;
    }
    
    return coll;
}

+ (id) parseOne:(NSArray*)tokens start:(NSUInteger)i ended:(NSUInteger*)ended error:(LVParseError*__autoreleasing*)error {
    LVToken* token = [tokens objectAtIndex:i];
    
    if (token.type == LV_TOK_SYMBOL) {
        *ended = i + 1;
        
        if ([token.val isEqualToString: @"true"])
            return [LVAtom with:token of:LVAtomTypeTrue];
        else if ([token.val isEqualToString: @"false"])
            return [LVAtom with:token of:LVAtomTypeFalse];
        else if ([token.val isEqualToString: @"nil"])
            return [LVAtom with:token of:LVAtomTypeNil];
        else
            return [LVAtom with:token of:LVAtomTypeSymbol];
    }
    else if (token.type == LV_TOK_READER_COMMENT) {
        id<LVElement> next = [self parseOne:tokens start:i + 1 ended:ended error:error];
        if (*error) {
            if ((*error).errorType == LVParseErrorTypeUnexpectedEnd) {
                *error = [LVParseError kind:LVParseErrorTypeUnopenedCloser with:token.range];
            }
            return nil;
        }
        
        NSRange fullRange = NSUnionRange(token.range, [next fullyEnclosedRange]);
        LVToken* tok = [LVToken token:LV_TOK_COMMENT at:fullRange.location len:fullRange.length];
        return [LVAtom with:tok of:LVAtomTypeComment];
    }
    else if (token.type == LV_TOK_VAR_START) {
        id<LVElement> next = [self parseOne:tokens start:i + 1 ended:ended error:error];
        if (*error) {
            if ((*error).errorType == LVParseErrorTypeUnexpectedEnd) {
                *error = [LVParseError kind:LVParseErrorTypeUnopenedCloser with:token.range];
            }
            return nil;
        }
        
        NSRange fullRange = NSUnionRange(token.range, [next fullyEnclosedRange]);
        LVToken* tok = [LVToken token:LV_TOK_COMMENT at:fullRange.location len:fullRange.length];
        return [LVAtom with:tok of:LVAtomTypeComment]; // TODO: this is really a var
    }
    else if (token.type == LV_TOK_READER_MACRO_START) {
        id<LVElement> next = [self parseOne:tokens start:i + 1 ended:ended error:error];
        if (*error) {
            if ((*error).errorType == LVParseErrorTypeUnexpectedEnd) {
                *error = [LVParseError kind:LVParseErrorTypeUnopenedCloser with:token.range];
            }
            return nil;
        }
        
        NSRange fullRange = NSUnionRange(token.range, [next fullyEnclosedRange]);
        LVToken* tok = [LVToken token:LV_TOK_COMMENT at:fullRange.location len:fullRange.length];
        return [LVAtom with:tok of:LVAtomTypeComment]; // TODO: this is really a reader macro
    }
    else if (token.type == LV_TOK_NUMBER) {
        *ended = i + 1;
        return [LVAtom with:token of:LVAtomTypeNumber];
    }
    else if (token.type == LV_TOK_TYPEOP) {
        *ended = i + 1;
        return [LVAtom with:token of:LVAtomTypeTypeOp];
    }
    else if (token.type == LV_TOK_QUOTE) {
        *ended = i + 1;
        return [LVAtom with:token of:LVAtomTypeQuote];
    }
    else if (token.type == LV_TOK_UNQUOTE) {
        *ended = i + 1;
        return [LVAtom with:token of:LVAtomTypeUnquote];
    }
    else if (token.type == LV_TOK_SYNTAXQUOTE) {
        *ended = i + 1;
        return [LVAtom with:token of:LVAtomTypeSyntaxQuote];
    }
    else if (token.type == LV_TOK_SPLICE) {
        *ended = i + 1;
        return [LVAtom with:token of:LVAtomTypeSplice];
    }
    else if (token.type == LV_TOK_STRING) {
        *ended = i + 1;
        return [LVAtom with:token of:LVAtomTypeString];
    }
    else if (token.type == LV_TOK_REGEX) {
        *ended = i + 1;
        return [LVAtom with:token of:LVAtomTypeRegex];
    }
    else if (token.type == LV_TOK_COMMENT) {
        *ended = i + 1;
        return [LVAtom with:token of:LVAtomTypeComment];
    }
    else if (token.type == LV_TOK_KEYWORD) {
        *ended = i + 1;
        return [LVAtom with:token of:LVAtomTypeKeyword];
    }
    else if (token.type == LV_TOK_FILE_END) {
        NSLog(@"reached end");
        *error = [LVParseError kind:LVParseErrorTypeUnexpectedEnd with:NSMakeRange(i - 1, 0)];
        return nil;
    }
    else if (token.type == LV_TOK_RPAREN || token.type == LV_TOK_RBRACKET || token.type == LV_TOK_RBRACE) {
        *error = [LVParseError kind:LVParseErrorTypeUnopenedCloser with:token.range];
        return nil;
    }
    else if (token.type == LV_TOK_LPAREN) {
        return [self parseColl:tokens start:i ended:ended collType:LVCollTypeList endType:LV_TOK_RPAREN error:error];
    }
    else if (token.type == LV_TOK_LBRACKET) {
        return [self parseColl:tokens start:i ended:ended collType:LVCollTypeVector endType:LV_TOK_RBRACKET error:error];
    }
    else if (token.type == LV_TOK_LBRACE) {
        return [self parseColl:tokens start:i ended:ended collType:LVCollTypeMap endType:LV_TOK_RBRACE error:error];
    }
    else if (token.type == LV_TOK_ANON_FN_START) {
        // TODO: return new FN coll type
        return [self parseColl:tokens start:i ended:ended collType:LVCollTypeList endType:LV_TOK_RPAREN error:error];
    }
    else if (token.type == LV_TOK_SET_START) {
        // TODO: return new Set coll type
        return [self parseColl:tokens start:i ended:ended collType:LVCollTypeList endType:LV_TOK_RBRACE error:error];
    }
    
    [NSException raise:@"ParserFoundBadToken" format:@"Parser doesn't handle token: %@", [token description]];
    __builtin_unreachable();
}

+ (LVColl*) parse:(NSString*)raw error:(LVParseError*__autoreleasing*)error {
    NSArray* tokens = [LVToken tokenize:raw error:error];
    
    if (*error)
        return nil;
    
    NSUInteger ended;
    return [self parseColl:tokens start:0 ended:&ended collType:LVCollTypeTopLevel endType:LV_TOK_FILE_END error:error];
}

@end
