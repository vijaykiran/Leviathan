//
//  BWToken.m
//  Beowulf
//
//  Created by Steven on 9/11/13.
//
//

#import "SDToken.h"

@implementation SDToken

+ (SDToken*) token:(BWTokenType)type val:(NSString*)val at:(NSUInteger)i len:(NSUInteger)len {
    SDToken* t = [[SDToken alloc] init];
    t.type = type;
    t.val = val;
    t.range = NSMakeRange(i, len);
    return t;
}

+ (SDToken*) token:(BWTokenType)type at:(NSUInteger)i len:(NSUInteger)len {
    return [self token:type val:nil at:i len:len];
}

+ (SDToken*) symbol:(NSString*)val at:(NSUInteger)i {
    return [self token:BW_TOK_SYMBOL val:val at:i len:[val length]];
}

+ (SDToken*) keyword:(NSString*)val at:(NSUInteger)i {
    return [self token:BW_TOK_KEYWORD val:val at:i len:[val length]];
}

+ (SDToken*) comment:(NSString*)val at:(NSUInteger)i {
    return [self token:BW_TOK_COMMENT val:val at:i len:[val length]];
}

+ (SDToken*) string:(NSString*)val at:(NSUInteger)i {
    return [self token:BW_TOK_STRING val:val at:i len:[val length]];
}

+ (SDToken*) regex:(NSString*)val at:(NSUInteger)i {
    return [self token:BW_TOK_REGEX val:val at:i len:[val length]];
}

+ (SDToken*) number:(NSString*)val at:(NSUInteger)i {
    return [self token:BW_TOK_NUMBER val:val at:i len:[val length]];
}

- (NSString*) description {
    return [NSString stringWithFormat:@"[%@ [type] %d [val] %@ at %lu len %lu]", [self class], self.type, self.val, self.range.location, self.range.length];
}

- (BOOL) isEqual:(SDToken*)other {
    if (![self isKindOfClass:[other class]])
        return NO;
    
    if (self.type != other.type)
        return NO;
    
    return (self == other) || (self.val == other.val) || [self.val isEqualToString: other.val];
}

- (NSUInteger) hash {
    return self.type ^ [self.val hash];
}

+ (NSRange) rangeUntil:(NSCharacterSet*)charSet in:(NSString*)str startingAt:(NSUInteger)start {
    NSUInteger loc = [str rangeOfCharacterFromSet:charSet options:0 range:NSMakeRange(start, [str length] - start)].location;
    if (loc == NSNotFound) loc = [str length];
    return NSMakeRange(start, loc - start);
}

//+ (NSRange) rangeUntilRegex:(NSString*)regex in:(NSString*)str startingAt:(NSUInteger)start {
//    NSUInteger loc = [str rangeOfString:regex options:NSRegularExpressionSearch range:NSMakeRange(start, [str length] - start)].location;
//    if (loc == NSNotFound) loc = [str length];
//    return NSMakeRange(start, loc - start);
//}

+ (NSArray*) tokenize:(NSString*)raw error:(SDParseError*__autoreleasing*)error {
    NSMutableArray* tokens = [NSMutableArray array];
    
    [tokens addObject: [SDToken token:BW_TOK_FILE_BEGIN at:0 len:0]];
    
    static NSCharacterSet* endAtomCharSet;
    if (!endAtomCharSet)
        endAtomCharSet = [NSCharacterSet characterSetWithCharactersInString:@"()[]{}, \r\n\t;"];
    
    NSUInteger i = 0;
    while (i < [raw length]) {
        unichar c = [raw characterAtIndex:i];
        
        switch (c) {
            case '(': [tokens addObject: [SDToken token:BW_TOK_LPAREN at:i len:1]]; break;
            case ')': [tokens addObject: [SDToken token:BW_TOK_RPAREN at:i len:1]]; break;
            case '[': [tokens addObject: [SDToken token:BW_TOK_LBRACKET at:i len:1]]; break;
            case ']': [tokens addObject: [SDToken token:BW_TOK_RBRACKET at:i len:1]]; break;
            case '{': [tokens addObject: [SDToken token:BW_TOK_LBRACE at:i len:1]]; break;
            case '}': [tokens addObject: [SDToken token:BW_TOK_RBRACE at:i len:1]]; break;
            case '`': [tokens addObject: [SDToken token:BW_TOK_SYNTAXQUOTE at:i len:1]]; break;
            case '\'': [tokens addObject: [SDToken token:BW_TOK_QUOTE at:i len:1]]; break;
            case '^': [tokens addObject: [SDToken token:BW_TOK_TYPEOP at:i len:1]]; break;
            case ',': break;
            case '~': {
                if ([raw characterAtIndex:i+1] == '@') {
                    [tokens addObject: [SDToken token:BW_TOK_SPLICE at:i len:2]];
                    i++;
                }
                else {
                    [tokens addObject: [SDToken token:BW_TOK_UNQUOTE at:i len:1]];
                }
                
                break;
            }
            case '#': {
                if (i == [raw length] - 1) {
                    *error = [SDParseError kind:SDParseErrorTypeUnfinishedDispatch with:NSMakeRange(i, 1)];
                    return nil;
                }
                
                if ([raw characterAtIndex:i+1] == '"') {
                    i += 2;
                    NSUInteger loc = i;
                    
                    while (true) {
                        if (loc == [raw length])
                            break;
                        
                        unichar next = [raw characterAtIndex:loc];
                        
                        if (next == '\\') {
                            loc += 2;
                            continue;
                        }
                        
                        if (next == '"')
                            break;
                        
                        loc++;
                    }
                    
                    [tokens addObject: [SDToken regex:[raw substringWithRange:NSMakeRange(i - 2, loc - i + 3)] at:i - 2]]; // janky
                    i = loc;
                    
                    break;
                }
                else {
                    *error = [SDParseError kind:SDParseErrorTypeUnfinishedDispatch with:NSMakeRange(i, 1)];
                    return nil;
                }
                
//                break;
            }
            case ' ': case '\t': case '\r': case '\n': break;
            case '1': case '2': case '3': case '4': case '5': case '6': case '7': case '8': case '9': case '0': {
                
                NSRange range = [self rangeUntil:endAtomCharSet in:raw startingAt:i];
                [tokens addObject: [SDToken number:[raw substringWithRange:range] at:range.location]];
                i = NSMaxRange(range)-1;
                
                break;
            }
            case ':': {
                
                NSRange range = [self rangeUntil:endAtomCharSet in:raw startingAt:i];
                [tokens addObject: [SDToken keyword:[raw substringWithRange:range] at:range.location]];
                i = NSMaxRange(range)-1;
                
                break;
            }
            case ';': {
                NSRange range = [self rangeUntil:[NSCharacterSet characterSetWithCharactersInString:@"\r\n"] in:raw startingAt:i];
                [tokens addObject: [SDToken comment:[raw substringWithRange:range] at:range.location]];
                i = NSMaxRange(range);
                
                break;
            }
            case '"': {
                i++;
                NSUInteger loc = i;
                
                while (true) {
                    NSLog(@"%ld, %ld", loc, [raw length]);
                    
                    if (loc == [raw length] - 1) {
                        break;
                        *error = [SDParseError kind:SDParseErrorTypeUnfinishedDispatch with:NSMakeRange(i, loc - i)];
                        return nil;
                    }
                    
                    unichar next = [raw characterAtIndex:loc];
                    
                    if (next == '\\') {
                        loc += 2;
                        continue;
                    }
                    
                    if (next == '"')
                        break;
                    
                    loc++;
                }
                
                [tokens addObject: [SDToken string:[raw substringWithRange:NSMakeRange(i - 1, loc - i + 2)] at:i - 1]]; // janky
                i = loc;
                
                break;
            }
            default: {
                // assume symbol
                
                NSRange range = [self rangeUntil:endAtomCharSet in:raw startingAt:i];
                [tokens addObject: [SDToken symbol:[raw substringWithRange:range] at:range.location]];
                i = NSMaxRange(range)-1;
                
                break;
            }
        }
        
        i++;
    }
    
    [tokens addObject: [SDToken token:BW_TOK_FILE_END at:i len:0]];
    
    return tokens;
}

@end
