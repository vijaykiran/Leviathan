//
//  BWToken.h
//  Beowulf
//
//  Created by Steven on 9/11/13.
//
//

#import <Foundation/Foundation.h>

#import "SDParserError.h"

typedef enum __BWTokenType {
    BW_TOK_LPAREN,
    BW_TOK_RPAREN,
    BW_TOK_LBRACKET,
    BW_TOK_RBRACKET,
    BW_TOK_LBRACE,
    BW_TOK_RBRACE,
    BW_TOK_SYMBOL,
    BW_TOK_NUMBER,
    BW_TOK_STRING,
    BW_TOK_REGEX,
    BW_TOK_QUOTE,
    BW_TOK_SYNTAXQUOTE,
    BW_TOK_UNQUOTE,
    BW_TOK_KEYWORD,
    BW_TOK_SPLICE,
    BW_TOK_TYPEOP,
    BW_TOK_COMMENT,
    BW_TOK_READER_COMMENT,
    BW_TOK_ANON_FN_START,
    BW_TOK_SET_START,
    BW_TOK_VAR_START,
    BW_TOK_FILE_BEGIN,
    BW_TOK_FILE_END,
} BWTokenType;

@interface SDToken : NSObject

@property BWTokenType type;
@property NSString* val;
@property NSRange range;

+ (SDToken*) token:(BWTokenType)type at:(NSUInteger)i len:(NSUInteger)len;
+ (SDToken*) symbol:(NSString*)val at:(NSUInteger)i;
+ (SDToken*) number:(NSString*)val at:(NSUInteger)i;
+ (SDToken*) string:(NSString*)val at:(NSUInteger)i;

+ (NSArray*) tokenize:(NSString*)raw error:(SDParseError*__autoreleasing*)error;

@end
