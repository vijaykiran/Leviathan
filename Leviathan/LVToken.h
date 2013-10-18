//
//  BWToken.h
//  Beowulf
//
//  Created by Steven on 9/11/13.
//
//

#import <Foundation/Foundation.h>

#import "LVParserError.h"

typedef enum __BWTokenType {
    LV_TOK_LPAREN,
    LV_TOK_RPAREN,
    LV_TOK_LBRACKET,
    LV_TOK_RBRACKET,
    LV_TOK_LBRACE,
    LV_TOK_RBRACE,
    LV_TOK_SYMBOL,
    LV_TOK_NUMBER,
    LV_TOK_STRING,
    LV_TOK_REGEX,
    LV_TOK_QUOTE,
    LV_TOK_SYNTAXQUOTE,
    LV_TOK_UNQUOTE,
    LV_TOK_KEYWORD,
    LV_TOK_SPLICE,
    LV_TOK_TYPEOP,
    LV_TOK_COMMENT,
    LV_TOK_READER_COMMENT,
    LV_TOK_ANON_FN_START,
    LV_TOK_SET_START,
    LV_TOK_VAR_START,
    LV_TOK_READER_MACRO_START,
    LV_TOK_FILE_BEGIN,
    LV_TOK_FILE_END,
} BWTokenType;

@interface LVToken : NSObject

@property BWTokenType type;
@property NSString* val;
@property NSRange range;

+ (LVToken*) token:(BWTokenType)type at:(NSUInteger)i len:(NSUInteger)len;
+ (LVToken*) symbol:(NSString*)val at:(NSUInteger)i;
+ (LVToken*) number:(NSString*)val at:(NSUInteger)i;
+ (LVToken*) string:(NSString*)val at:(NSUInteger)i;

+ (NSArray*) tokenize:(NSString*)raw error:(LVParseError*__autoreleasing*)error;

@end
