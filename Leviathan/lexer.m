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

LVToken* LVLex(LVStorage* storage) {
    NSUInteger inputStringLength = CFStringGetLength(storage->wholeString);
    
    UniChar chars[inputStringLength];
    CFStringGetCharacters(storage->wholeString, CFRangeMake(0, inputStringLength), chars);
    
    LVToken* head = NULL;
    LVToken* last = NULL;
    
    static CFCharacterSetRef endAtomCharSet;
    if (!endAtomCharSet) endAtomCharSet = CFCharacterSetCreateWithCharactersInString(NULL, CFSTR("()[]{}, \"\r\n\t;"));
    
    head = LVTokenCreate(storage, 0, 0, LVTokenType_FileBegin);
    head->prevToken = NULL;
    head->nextToken = NULL;
    
    last = head;
    
    NSUInteger i = 0;
    while (i < inputStringLength) {
        
        UniChar c = chars[i];
        
        switch (c) {
                
            case '(': LVAppendToken(&last, LVTokenCreate(storage, i, 1, LVTokenType_LParen)); break;
            case ')': LVAppendToken(&last, LVTokenCreate(storage, i, 1, LVTokenType_RParen)); break;
                
            case '[': LVAppendToken(&last, LVTokenCreate(storage, i, 1, LVTokenType_LBracket)); break;
            case ']': LVAppendToken(&last, LVTokenCreate(storage, i, 1, LVTokenType_RBracket)); break;
                
            case '{': LVAppendToken(&last, LVTokenCreate(storage, i, 1, LVTokenType_LBrace)); break;
            case '}': LVAppendToken(&last, LVTokenCreate(storage, i, 1, LVTokenType_RBrace)); break;
                
            case '\'': LVAppendToken(&last, LVTokenCreate(storage, i, 1, LVTokenType_Quote)); break;
            case '^': LVAppendToken(&last, LVTokenCreate(storage, i, 1, LVTokenType_TypeOp)); break;
            case '`': LVAppendToken(&last, LVTokenCreate(storage, i, 1, LVTokenType_SyntaxQuote)); break;
                
            case ',': LVAppendToken(&last, LVTokenCreate(storage, i, 1, LVTokenType_Comma)); break;
                
            case '\n': {
                NSUInteger start = i;
                while (chars[++i] == '\n');
                LVAppendToken(&last, LVTokenCreate(storage, start, i - start, LVTokenType_Newlines));
                i--;
                
                break;
            }
                
            case '~': {
                if (i + 1 < inputStringLength && chars[i+1] == '@') {
                    LVAppendToken(&last, LVTokenCreate(storage, i, 2, LVTokenType_Splice));
                    i++;
                }
                else {
                    LVAppendToken(&last, LVTokenCreate(storage, i, 1, LVTokenType_Unquote));
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
                Boolean found = CFStringFindCharacterFromSet(storage->wholeString, nonSpaceCharSet, CFRangeMake(i, inputStringLength - i), 0, &range);
                CFIndex n = (found ? range.location : inputStringLength);
                
                LVAppendToken(&last, LVTokenCreate(storage, i, n - i, LVTokenType_Spaces));
                i = n-1;
                break;
            }
                
            case ':': {
                CFRange range;
                Boolean found = CFStringFindCharacterFromSet(storage->wholeString, endAtomCharSet, CFRangeMake(i, inputStringLength - i), 0, &range);
                CFIndex n = (found ? range.location : inputStringLength);
                
                LVAppendToken(&last, LVTokenCreate(storage, i, n - i, LVTokenType_Keyword));
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
                
                LVAppendToken(&last, LVTokenCreate(storage, i, seeker - i + 1, LVTokenType_String));
                i = seeker;
                
                break;
            }
                
            case ';': {
                CFRange range;
                Boolean found = CFStringFindWithOptions(storage->wholeString, CFSTR("\n"), CFRangeMake(i, inputStringLength - i), 0, &range);
                CFIndex n = (found ? range.location : inputStringLength);
                
                LVAppendToken(&last, LVTokenCreate(storage, i, n - i, LVTokenType_CommentLiteral));
                i = n-1;
                
                break;
            }
                
            case '1': case '2': case '3': case '4': case '5': case '6': case '7': case '8': case '9': case '0': {
                CFRange range;
                Boolean found = CFStringFindCharacterFromSet(storage->wholeString, endAtomCharSet, CFRangeMake(i, inputStringLength - i), 0, &range);
                CFIndex n = (found ? range.location : inputStringLength);
                
                LVAppendToken(&last, LVTokenCreate(storage, i, n - i, LVTokenType_Number));
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
                        
                        LVAppendToken(&last, LVTokenCreate(storage, i, seeker - i + 1, LVTokenType_Regex));
                        i = seeker;
                        
                        break;
                    }
                        
                    case '\'': {
                        CFRange range;
                        Boolean found = CFStringFindCharacterFromSet(storage->wholeString, endAtomCharSet, CFRangeMake(i, inputStringLength - i), 0, &range);
                        CFIndex n = (found ? range.location : inputStringLength);
                        
                        LVAppendToken(&last, LVTokenCreate(storage, i, n - i, LVTokenType_Var));
                        i = n-1;
                        break;
                    }
                        
                    case '(': LVAppendToken(&last, LVTokenCreate(storage, i, 2, LVTokenType_AnonFnStart)); i++; break;
                    case '{': LVAppendToken(&last, LVTokenCreate(storage, i, 2, LVTokenType_SetStart)); i++; break;
                    case '_': LVAppendToken(&last, LVTokenCreate(storage, i, 2, LVTokenType_ReaderCommentStart)); i++; break;
                        
                    default: {
                        CFRange range;
                        Boolean found = CFStringFindCharacterFromSet(storage->wholeString, endAtomCharSet, CFRangeMake(i, inputStringLength - i), 0, &range);
                        CFIndex n = (found ? range.location : inputStringLength);
                        
                        LVAppendToken(&last, LVTokenCreate(storage, i, n - i, LVTokenType_ReaderMacro));
                        i = n-1;
                        break;
                    }
                }
                
                break;
            }
                
            default: {
                CFRange range;
                Boolean found = CFStringFindCharacterFromSet(storage->wholeString, endAtomCharSet, CFRangeMake(i, inputStringLength - i), 0, &range);
                CFIndex n = (found ? range.location : inputStringLength);
                
                LVToken* tok = LVTokenCreate(storage, i, n - i, LVTokenType_Symbol);
                CFStringRef substring = tok->string;
                
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
    
    LVAppendToken(&last, LVTokenCreate(storage, i, 0, LVTokenType_FileEnd));
    last->nextToken = NULL;
    
    return head;
}
