////
////  token.cpp
////  Leviathan
////
////  Created by Steven on 10/19/13.
////  Copyright (c) 2013 Steven Degutis. All rights reserved.
////

#include "lexer.h"

#import "LVParseError.h"

void LVAppendToken(LVToken** lastPtr, LVToken* newToken) {
    (*lastPtr)->nextToken = newToken;
    newToken->prevToken = *lastPtr;
    *lastPtr = newToken;
}

LVToken* LVLex(CFStringRef raw) {
    NSUInteger inputStringLength = CFStringGetLength(raw);
    
    UniChar chars[inputStringLength];
    CFStringGetCharacters(raw, CFRangeMake(0, inputStringLength), chars);
    
    LVToken* head = NULL;
    LVToken* last = NULL;
    
    static CFCharacterSetRef endAtomCharSet;
    if (!endAtomCharSet) endAtomCharSet = CFCharacterSetCreateWithCharactersInString(NULL, CFSTR("()[]{}, \"\r\n\t;"));
    
    head = LVTokenCreate(0, LVTokenType_FileBegin, CFSTR(""));
    head->prevToken = NULL;
    head->nextToken = NULL;
    
    last = head;
    
    NSUInteger i = 0;
    while (i < inputStringLength) {
        
        UniChar c = chars[i];
        
        switch (c) {
                
            case '(': LVAppendToken(&last, LVTokenCreate(i, LVTokenType_LParen, CFStringCreateWithSubstring(NULL, raw, CFRangeMake(i, 1)))); break;
            case ')': LVAppendToken(&last, LVTokenCreate(i, LVTokenType_RParen, CFStringCreateWithSubstring(NULL, raw, CFRangeMake(i, 1)))); break;
                
            case '[': LVAppendToken(&last, LVTokenCreate(i, LVTokenType_LBracket, CFStringCreateWithSubstring(NULL, raw, CFRangeMake(i, 1)))); break;
            case ']': LVAppendToken(&last, LVTokenCreate(i, LVTokenType_RBracket, CFStringCreateWithSubstring(NULL, raw, CFRangeMake(i, 1)))); break;
                
            case '{': LVAppendToken(&last, LVTokenCreate(i, LVTokenType_LBrace, CFStringCreateWithSubstring(NULL, raw, CFRangeMake(i, 1)))); break;
            case '}': LVAppendToken(&last, LVTokenCreate(i, LVTokenType_RBrace, CFStringCreateWithSubstring(NULL, raw, CFRangeMake(i, 1)))); break;
                
            case '\'': LVAppendToken(&last, LVTokenCreate(i, LVTokenType_Quote, CFStringCreateWithSubstring(NULL, raw, CFRangeMake(i, 1)))); break;
            case '^': LVAppendToken(&last, LVTokenCreate(i, LVTokenType_TypeOp, CFStringCreateWithSubstring(NULL, raw, CFRangeMake(i, 1)))); break;
            case '`': LVAppendToken(&last, LVTokenCreate(i, LVTokenType_SyntaxQuote, CFStringCreateWithSubstring(NULL, raw, CFRangeMake(i, 1)))); break;
                
            case ',': LVAppendToken(&last, LVTokenCreate(i, LVTokenType_Comma, CFStringCreateWithSubstring(NULL, raw, CFRangeMake(i, 1)))); break;
                
            case '\n': {
                NSUInteger start = i;
                while (chars[++i] == '\n');
                LVAppendToken(&last, LVTokenCreate(start, LVTokenType_Newlines, CFStringCreateWithSubstring(NULL, raw, CFRangeMake(start, i - start))));
                i--;
                
                break;
            }
                
            case '~': {
                if (i + 1 < inputStringLength && chars[i+1] == '@') {
                    LVAppendToken(&last, LVTokenCreate(i, LVTokenType_Splice, CFStringCreateWithSubstring(NULL, raw, CFRangeMake(i, 2))));
                    i++;
                }
                else {
                    LVAppendToken(&last, LVTokenCreate(i, LVTokenType_Unquote, CFStringCreateWithSubstring(NULL, raw, CFRangeMake(i, 1))));
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
                Boolean found = CFStringFindCharacterFromSet(raw, nonSpaceCharSet, CFRangeMake(i, inputStringLength - i), 0, &range);
                CFIndex n = (found ? range.location : inputStringLength);
                
                LVAppendToken(&last, LVTokenCreate(i, LVTokenType_Spaces, CFStringCreateWithSubstring(NULL, raw, CFRangeMake(i, (n - i)))));
                i = n-1;
                break;
            }
                
            case ':': {
                CFRange range;
                Boolean found = CFStringFindCharacterFromSet(raw, endAtomCharSet, CFRangeMake(i, inputStringLength - i), 0, &range);
                CFIndex n = (found ? range.location : inputStringLength);
                
                LVAppendToken(&last, LVTokenCreate(i, LVTokenType_Keyword, CFStringCreateWithSubstring(NULL, raw, CFRangeMake(i, (n - i)))));
                i = n-1;
                break;
            }
                
            case '"': {
                NSUInteger seeker = i;
                do {
                    do seeker++; while (seeker < inputStringLength && chars[seeker] != '"');
                    if (seeker == inputStringLength) {
                        printf("error: unclosed string\n");
                        @throw [LVParseError exceptionWithName:@"uhh" reason:@"heh" userInfo:nil];
                    }
                } while (chars[seeker - 1] == '\\');
                
                CFStringRef substring = CFStringCreateWithSubstring(NULL, raw, CFRangeMake(i, seeker - i + 1));
                LVToken* tok = LVTokenCreate(i, LVTokenType_String, substring);
                LVAppendToken(&last, tok);
                i = seeker;
                
                break;
            }
                
            case ';': {
                CFRange range;
                Boolean found = CFStringFindWithOptions(raw, CFSTR("\n"), CFRangeMake(i, inputStringLength - i), 0, &range);
                CFIndex n = (found ? range.location : inputStringLength);
                
                CFStringRef substring = CFStringCreateWithSubstring(NULL, raw, CFRangeMake(i, n - i));
                LVToken* tok = LVTokenCreate(i, LVTokenType_CommentLiteral, substring);
                LVAppendToken(&last, tok);
                i = n-1;
                
                break;
            }
                
            case '1': case '2': case '3': case '4': case '5': case '6': case '7': case '8': case '9': case '0': {
                CFRange range;
                Boolean found = CFStringFindCharacterFromSet(raw, endAtomCharSet, CFRangeMake(i, inputStringLength - i), 0, &range);
                CFIndex n = (found ? range.location : inputStringLength);
                
                LVAppendToken(&last, LVTokenCreate(i, LVTokenType_Number, CFStringCreateWithSubstring(NULL, raw, CFRangeMake(i, n - i))));
                i = n-1;
                break;
            }
                
            case '#': {
                if (i + 1 == inputStringLength) {
                    printf("error: unclosed dispatch\n");
                    @throw [LVParseError exceptionWithName:@"uhh" reason:@"heh" userInfo:nil];
                }
                
                UniChar next = chars[i + 1];
                
                switch (next) {
                    case '"': {
                        NSUInteger seeker = i + 1;
                        do {
                            do seeker++; while (seeker < inputStringLength && chars[seeker] != '"');
                            if (seeker == inputStringLength) {
                                printf("error: unclosed regex\n");
                                @throw [LVParseError exceptionWithName:@"uhh" reason:@"heh" userInfo:nil];
                            }
                        } while (chars[seeker - 1] == '\\');
                        
                        CFStringRef substring = CFStringCreateWithSubstring(NULL, raw, CFRangeMake(i, seeker - i + 1));
                        LVToken* tok = LVTokenCreate(i, LVTokenType_Regex, substring);
                        LVAppendToken(&last, tok);
                        i = seeker;
                        
                        break;
                    }
                        
                    case '\'': {
                        CFRange range;
                        Boolean found = CFStringFindCharacterFromSet(raw, endAtomCharSet, CFRangeMake(i, inputStringLength - i), 0, &range);
                        CFIndex n = (found ? range.location : inputStringLength);
                        
                        LVAppendToken(&last, LVTokenCreate(i, LVTokenType_Var, CFStringCreateWithSubstring(NULL, raw, CFRangeMake(i, n - i))));
                        i = n-1;
                        break;
                    }
                        
                    case '(': LVAppendToken(&last, LVTokenCreate(i, LVTokenType_AnonFnStart, CFStringCreateWithSubstring(NULL, raw, CFRangeMake(i, 2)))); i++; break;
                    case '{': LVAppendToken(&last, LVTokenCreate(i, LVTokenType_SetStart, CFStringCreateWithSubstring(NULL, raw, CFRangeMake(i, 2)))); i++; break;
                    case '_': LVAppendToken(&last, LVTokenCreate(i, LVTokenType_ReaderCommentStart, CFStringCreateWithSubstring(NULL, raw, CFRangeMake(i, 2)))); i++; break;
                        
                    default: {
                        CFRange range;
                        Boolean found = CFStringFindCharacterFromSet(raw, endAtomCharSet, CFRangeMake(i, inputStringLength - i), 0, &range);
                        CFIndex n = (found ? range.location : inputStringLength);
                        
                        LVAppendToken(&last, LVTokenCreate(i, LVTokenType_ReaderMacro, CFStringCreateWithSubstring(NULL, raw, CFRangeMake(i, n - i))));
                        i = n-1;
                        break;
                    }
                }
                
                break;
            }
                
            default: {
                CFRange range;
                Boolean found = CFStringFindCharacterFromSet(raw, endAtomCharSet, CFRangeMake(i, inputStringLength - i), 0, &range);
                CFIndex n = (found ? range.location : inputStringLength);
                
                CFStringRef substring = CFStringCreateWithSubstring(NULL, raw, CFRangeMake(i, n - i));
                LVToken* tok = LVTokenCreate(i, LVTokenType_Symbol, substring);
                
                static CFStringRef trueConstant = CFSTR("true");
                static CFStringRef falseConstant = CFSTR("false");
                static CFStringRef nilConstant = CFSTR("nil");
                static CFStringRef defConstant = CFSTR("def");
                
//                static CFMutableArrayRef functionLikes; if (!functionLikes) {
//                    functionLikes = CFArrayCreateMutable(NULL, 0, &kCFTypeArrayCallBacks);
//                    CFArrayAppendValue(functionLikes, CFSTR("ns"));
//                    CFArrayAppendValue(functionLikes, CFSTR("let"));
//                    CFArrayAppendValue(functionLikes, CFSTR("for"));
//                    CFArrayAppendValue(functionLikes, CFSTR("assoc"));
//                    CFArrayAppendValue(functionLikes, CFSTR("if"));
//                    CFArrayAppendValue(functionLikes, CFSTR("if-let"));
//                    CFArrayAppendValue(functionLikes, CFSTR("cond"));
//                    CFArrayAppendValue(functionLikes, CFSTR("case"));
//                }
                
                if (CFEqual(substring, trueConstant)) tok->tokenType |= LVTokenType_TrueSymbol;
                else if (CFEqual(substring, falseConstant)) tok->tokenType |= LVTokenType_FalseSymbol;
                else if (CFEqual(substring, nilConstant)) tok->tokenType |= LVTokenType_NilSymbol;
                else if (CFStringHasPrefix(substring, defConstant)) tok->tokenType |= LVTokenType_Deflike;
//                else if (CFArrayContainsValue(functionLikes, CFRangeMake(0, CFArrayGetCount(functionLikes)), substring)) tok->tokenType |= LVTokenType_IndentLikeFn;
                
                LVAppendToken(&last, tok);
                i = n-1;
                
                break;
            }
        }
        
        i++;
        
    }
    
    LVAppendToken(&last, LVTokenCreate(i, LVTokenType_FileEnd, CFSTR("")));
    last->nextToken = NULL;
    
    return head;
}
