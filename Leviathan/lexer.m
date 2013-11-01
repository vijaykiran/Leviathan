////
////  token.cpp
////  Leviathan
////
////  Created by Steven on 10/19/13.
////  Copyright (c) 2013 Steven Degutis. All rights reserved.
////

#include "lexer.h"

#import "LVParseError.h"

LVToken** LVLex(CFStringRef raw, size_t* n_tok) {
    size_t input_string_length = CFStringGetLength(raw);
    size_t num_tokens = 0;
    
    UniChar chars[input_string_length];
    CFStringGetCharacters(raw, CFRangeMake(0, input_string_length), chars);
    
    LVToken** tokens = malloc(sizeof(LVToken*) * (input_string_length + 2));
    
    static CFCharacterSetRef endAtomCharSet;
    if (!endAtomCharSet) endAtomCharSet = CFCharacterSetCreateWithCharactersInString(NULL, CFSTR("()[]{}, \"\r\n\t;"));
    
    tokens[num_tokens++] = LVTokenCreate(0, LVTokenType_FileBegin, CFSTR(""));
    
    size_t i = 0;
    while (i < input_string_length) {
        
        UniChar c = chars[i];
        
        switch (c) {
                
            case '(': tokens[num_tokens++] = LVTokenCreate(i, LVTokenType_LParen, CFStringCreateWithSubstring(NULL, raw, CFRangeMake(i, 1))); break;
            case ')': tokens[num_tokens++] = LVTokenCreate(i, LVTokenType_RParen, CFStringCreateWithSubstring(NULL, raw, CFRangeMake(i, 1))); break;
                
            case '[': tokens[num_tokens++] = LVTokenCreate(i, LVTokenType_LBracket, CFStringCreateWithSubstring(NULL, raw, CFRangeMake(i, 1))); break;
            case ']': tokens[num_tokens++] = LVTokenCreate(i, LVTokenType_RBracket, CFStringCreateWithSubstring(NULL, raw, CFRangeMake(i, 1))); break;
                
            case '{': tokens[num_tokens++] = LVTokenCreate(i, LVTokenType_LBrace, CFStringCreateWithSubstring(NULL, raw, CFRangeMake(i, 1))); break;
            case '}': tokens[num_tokens++] = LVTokenCreate(i, LVTokenType_RBrace, CFStringCreateWithSubstring(NULL, raw, CFRangeMake(i, 1))); break;
                
            case '\'': tokens[num_tokens++] = LVTokenCreate(i, LVTokenType_Quote, CFStringCreateWithSubstring(NULL, raw, CFRangeMake(i, 1))); break;
            case '^': tokens[num_tokens++] = LVTokenCreate(i, LVTokenType_TypeOp, CFStringCreateWithSubstring(NULL, raw, CFRangeMake(i, 1))); break;
            case '`': tokens[num_tokens++] = LVTokenCreate(i, LVTokenType_SyntaxQuote, CFStringCreateWithSubstring(NULL, raw, CFRangeMake(i, 1))); break;
                
            case ',': tokens[num_tokens++] = LVTokenCreate(i, LVTokenType_Comma, CFStringCreateWithSubstring(NULL, raw, CFRangeMake(i, 1))); break;
            case '\t': tokens[num_tokens++] = LVTokenCreate(i, LVTokenType_Spaces, CFSTR("  ")); break; // TODO: the way we do this means sometimes there are multiple LVTokenType_Spaces in a row, which isnt good.
                
            case '\n': {
                size_t start = i;
                while (chars[++i] == '\n');
                tokens[num_tokens++] = LVTokenCreate(start, LVTokenType_Newlines, CFStringCreateWithSubstring(NULL, raw, CFRangeMake(start, i - start)));
                i--;
                
                break;
            }
                
            case '~': {
                if (i + 1 < input_string_length && chars[i+1] == '@') {
                    tokens[num_tokens++] = LVTokenCreate(i, LVTokenType_Splice, CFStringCreateWithSubstring(NULL, raw, CFRangeMake(i, 2)));
                    i++;
                }
                else {
                    tokens[num_tokens++] = LVTokenCreate(i, LVTokenType_Unquote, CFStringCreateWithSubstring(NULL, raw, CFRangeMake(i, 1)));
                }
                break;
            }
                
            case ' ': {
                static CFCharacterSetRef nonSpaceCharSet;
                if (!nonSpaceCharSet) {
                    CFCharacterSetRef spaceCharSet = CFCharacterSetCreateWithCharactersInString(NULL, CFSTR(" "));
                    nonSpaceCharSet = CFCharacterSetCreateInvertedSet(NULL, spaceCharSet);
                    CFRelease(spaceCharSet);
                }
                
                CFRange range;
                Boolean found = CFStringFindCharacterFromSet(raw, nonSpaceCharSet, CFRangeMake(i, input_string_length - i), 0, &range);
                CFIndex n = (found ? range.location : input_string_length);
                
                tokens[num_tokens++] = LVTokenCreate(i, LVTokenType_Spaces, CFStringCreateWithSubstring(NULL, raw, CFRangeMake(i, (n - i))));
                i = n-1;
                break;
            }
                
            case ':': {
                CFRange range;
                Boolean found = CFStringFindCharacterFromSet(raw, endAtomCharSet, CFRangeMake(i, input_string_length - i), 0, &range);
                CFIndex n = (found ? range.location : input_string_length);
                
                tokens[num_tokens++] = LVTokenCreate(i, LVTokenType_Keyword, CFStringCreateWithSubstring(NULL, raw, CFRangeMake(i, (n - i))));
                i = n-1;
                break;
            }
                
            case '"': {
                size_t seeker = i;
                do {
                    do seeker++; while (seeker < input_string_length && chars[seeker] != '"');
                    if (seeker == input_string_length) {
                        printf("error: unclosed string\n");
                        @throw [LVParseError exceptionWithName:@"uhh" reason:@"heh" userInfo:nil];
                    }
                } while (chars[seeker - 1] == '\\');
                
                CFStringRef substring = CFStringCreateWithSubstring(NULL, raw, CFRangeMake(i, seeker - i + 1));
                LVToken* tok = LVTokenCreate(i, LVTokenType_String, substring);
                tokens[num_tokens++] = tok;
                i = seeker;
                
                break;
            }
                
            case ';': {
                CFRange range;
                Boolean found = CFStringFindWithOptions(raw, CFSTR("\n"), CFRangeMake(i, input_string_length - i), 0, &range);
                CFIndex n = (found ? range.location : input_string_length);
                
                CFStringRef substring = CFStringCreateWithSubstring(NULL, raw, CFRangeMake(i, n - i));
                LVToken* tok = LVTokenCreate(i, LVTokenType_CommentLiteral, substring);
                tokens[num_tokens++] = tok;
                i = n-1;
                
                break;
            }
                
            case '1': case '2': case '3': case '4': case '5': case '6': case '7': case '8': case '9': case '0': {
                CFRange range;
                Boolean found = CFStringFindCharacterFromSet(raw, endAtomCharSet, CFRangeMake(i, input_string_length - i), 0, &range);
                CFIndex n = (found ? range.location : input_string_length);
                
                tokens[num_tokens++] = LVTokenCreate(i, LVTokenType_Number, CFStringCreateWithSubstring(NULL, raw, CFRangeMake(i, n - i)));
                i = n-1;
                break;
            }
                
            case '#': {
                if (i + 1 == input_string_length) {
                    printf("error: unclosed dispatch\n");
                    @throw [LVParseError exceptionWithName:@"uhh" reason:@"heh" userInfo:nil];
                }
                
                UniChar next = chars[i + 1];
                
                switch (next) {
                    case '"': {
                        size_t seeker = i + 1;
                        do {
                            do seeker++; while (seeker < input_string_length && chars[seeker] != '"');
                            if (seeker == input_string_length) {
                                printf("error: unclosed regex\n");
                                @throw [LVParseError exceptionWithName:@"uhh" reason:@"heh" userInfo:nil];
                            }
                        } while (chars[seeker - 1] == '\\');
                        
                        CFStringRef substring = CFStringCreateWithSubstring(NULL, raw, CFRangeMake(i, seeker - i + 1));
                        LVToken* tok = LVTokenCreate(i, LVTokenType_Regex, substring);
                        tokens[num_tokens++] = tok;
                        i = seeker;
                        
                        break;
                    }
                        
                    case '\'': {
                        CFRange range;
                        Boolean found = CFStringFindCharacterFromSet(raw, endAtomCharSet, CFRangeMake(i, input_string_length - i), 0, &range);
                        CFIndex n = (found ? range.location : input_string_length);
                        
                        tokens[num_tokens++] = LVTokenCreate(i, LVTokenType_Var, CFStringCreateWithSubstring(NULL, raw, CFRangeMake(i, n - i)));
                        i = n-1;
                        break;
                    }
                        
                    case '(': tokens[num_tokens++] = LVTokenCreate(i, LVTokenType_AnonFnStart, CFStringCreateWithSubstring(NULL, raw, CFRangeMake(i, 2))); i++; break;
                    case '{': tokens[num_tokens++] = LVTokenCreate(i, LVTokenType_SetStart, CFStringCreateWithSubstring(NULL, raw, CFRangeMake(i, 2))); i++; break;
                    case '_': tokens[num_tokens++] = LVTokenCreate(i, LVTokenType_ReaderCommentStart, CFStringCreateWithSubstring(NULL, raw, CFRangeMake(i, 2))); i++; break;
                        
                    default: {
                        CFRange range;
                        Boolean found = CFStringFindCharacterFromSet(raw, endAtomCharSet, CFRangeMake(i, input_string_length - i), 0, &range);
                        CFIndex n = (found ? range.location : input_string_length);
                        
                        tokens[num_tokens++] = LVTokenCreate(i, LVTokenType_ReaderMacro, CFStringCreateWithSubstring(NULL, raw, CFRangeMake(i, n - i)));
                        i = n-1;
                        break;
                    }
                }
                
                break;
            }
                
            default: {
                CFRange range;
                Boolean found = CFStringFindCharacterFromSet(raw, endAtomCharSet, CFRangeMake(i, input_string_length - i), 0, &range);
                CFIndex n = (found ? range.location : input_string_length);
                
                CFStringRef substring = CFStringCreateWithSubstring(NULL, raw, CFRangeMake(i, n - i));
                LVToken* tok = LVTokenCreate(i, LVTokenType_Symbol, substring);
                
                static CFStringRef trueConstant = CFSTR("true");
                static CFStringRef falseConstant = CFSTR("false");
                static CFStringRef nilConstant = CFSTR("nil");
                static CFStringRef defConstant = CFSTR("def");
                
                if (CFStringCompare(substring, trueConstant, 0) == kCFCompareEqualTo) tok->token_type |= LVTokenType_TrueSymbol;
                if (CFStringCompare(substring, falseConstant, 0) == kCFCompareEqualTo) tok->token_type |= LVTokenType_FalseSymbol;
                if (CFStringCompare(substring, nilConstant, 0) == kCFCompareEqualTo) tok->token_type |= LVTokenType_NilSymbol;
                if (CFStringHasPrefix(substring, defConstant)) tok->token_type |= LVTokenType_Deflike;
                
                tokens[num_tokens++] = tok;
                i = n-1;
                
                break;
            }
        }
        
        i++;
        
    }
    
    tokens[num_tokens++] = LVTokenCreate(i, LVTokenType_FileEnd, CFSTR(""));
    
    *n_tok = num_tokens;
    return tokens;
}
