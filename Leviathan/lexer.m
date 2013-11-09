////
////  token.cpp
////  Leviathan
////
////  Created by Steven on 10/19/13.
////  Copyright (c) 2013 Steven Degutis. All rights reserved.
////

#include "lexer.h"

void LVAppendToken(LVToken** lastPtr, LVToken* newToken) {
    (*lastPtr)->nextToken = newToken;
    newToken->prevToken = *lastPtr;
    *lastPtr = newToken;
}

static BOOL LVIsTrueSymbol(UniChar* chars, CFIndex i, CFIndex len) {
    if (len != 4) return NO;
    return (chars[i+0] == 't' && chars[i+1] == 'r' && chars[i+2] == 'u' && chars[i+3] == 'e');
}

static BOOL LVIsFalseSymbol(UniChar* chars, CFIndex i, CFIndex len) {
    if (len != 5) return NO;
    return (chars[i+0] == 'f' && chars[i+1] == 'a' && chars[i+2] == 'l' && chars[i+3] == 's' && chars[i+4] == 'e');
}

static BOOL LVIsNilSymbol(UniChar* chars, CFIndex i, CFIndex len) {
    if (len != 3) return NO;
    return (chars[i+0] == 'n' && chars[i+1] == 'i' && chars[i+2] == 'l');
}

static BOOL LVIsDeflikeSymbol(UniChar* chars, CFIndex i, CFIndex len) {
    if (len < 3) return NO;
    return (chars[i+0] == 'd' && chars[i+1] == 'e' && chars[i+2] == 'f');
}

LVToken* LVLex(LVDocStorage* storage, BOOL* parseError) {
    NSUInteger inputStringLength = CFStringGetLength(storage->wholeString);
    
    UniChar chars[inputStringLength];
    CFStringGetCharacters(storage->wholeString, CFRangeMake(0, inputStringLength), chars);
    
    LVToken* head = NULL;
    LVToken* last = NULL;
    
    static char* endAtomCharSet = "()[]{}, \"\r\n\t;";
    
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
                CFIndex n = i;
                do n++; while (n < inputStringLength && chars[n] == '\n');
                LVAppendToken(&last, LVTokenCreate(storage, i, n - i, LVTokenType_Newlines));
                i = n - 1;
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
                CFIndex n = i;
                do n++; while (n < inputStringLength && chars[n] == ' ');
                LVAppendToken(&last, LVTokenCreate(storage, i, n - i, LVTokenType_Spaces));
                i = n-1;
                break;
            }
                
            case ':': {
                CFIndex n = i;
                do n++; while (n < inputStringLength && !strchr(endAtomCharSet, chars[n]));
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
                        *parseError = YES;
                        return NULL;
                    }
                } while (chars[seeker - 1] == '\\');
                
                LVAppendToken(&last, LVTokenCreate(storage, i, seeker - i + 1, LVTokenType_String));
                i = seeker;
                
                break;
            }
                
            case ';': {
                CFIndex n = i;
                do n++; while (n < inputStringLength && chars[n] != '\n');
                LVAppendToken(&last, LVTokenCreate(storage, i, n - i, LVTokenType_CommentLiteral));
                i = n - 1;
                break;
            }
                
            case '1': case '2': case '3': case '4': case '5': case '6': case '7': case '8': case '9': case '0': {
                CFIndex n = i;
                do n++; while (n < inputStringLength && !strchr(endAtomCharSet, chars[n]));
                
                LVAppendToken(&last, LVTokenCreate(storage, i, n - i, LVTokenType_Number));
                i = n-1;
                break;
            }
                
            case '#': {
                if (i + 1 == inputStringLength) {
                    printf("error: unclosed dispatch\n");
                    *parseError = YES;
                    return NULL;
                }
                
                UniChar next = chars[i + 1];
                
                switch (next) {
                    case '"': {
                        NSUInteger seeker = i + 1;
                        do {
                            do seeker++; while (seeker < inputStringLength && chars[seeker] != '"');
                            if (seeker == inputStringLength) {
                                printf("error: unclosed regex\n");
                                *parseError = YES;
                                return NULL;
                            }
                        } while (chars[seeker - 1] == '\\');
                        
                        LVAppendToken(&last, LVTokenCreate(storage, i, seeker - i + 1, LVTokenType_Regex));
                        i = seeker;
                        
                        break;
                    }
                        
                    case '\'': {
                        CFIndex n = i;
                        do n++; while (n < inputStringLength && !strchr(endAtomCharSet, chars[n]));
                        
                        LVAppendToken(&last, LVTokenCreate(storage, i, n - i, LVTokenType_Var));
                        i = n-1;
                        break;
                    }
                        
                    case '(': LVAppendToken(&last, LVTokenCreate(storage, i, 2, LVTokenType_AnonFnStart)); i++; break;
                    case '{': LVAppendToken(&last, LVTokenCreate(storage, i, 2, LVTokenType_SetStart)); i++; break;
                    case '_': LVAppendToken(&last, LVTokenCreate(storage, i, 2, LVTokenType_ReaderCommentStart)); i++; break;
                        
                    default: {
                        CFIndex n = i;
                        do n++; while (n < inputStringLength && !strchr(endAtomCharSet, chars[n]));
                        
                        LVAppendToken(&last, LVTokenCreate(storage, i, n - i, LVTokenType_ReaderMacro));
                        i = n-1;
                        break;
                    }
                }
                
                break;
            }
                
            default: {
                CFIndex n = i;
                do n++; while (n < inputStringLength && !strchr(endAtomCharSet, chars[n]));
                
                NSUInteger tokLen = n - i;
                LVToken* tok = LVTokenCreate(storage, i, tokLen, LVTokenType_Symbol);
                
                if (LVIsTrueSymbol(chars, i, tokLen)) tok->tokenType |= LVTokenType_TrueSymbol;
                else if (LVIsFalseSymbol(chars, i, tokLen)) tok->tokenType |= LVTokenType_FalseSymbol;
                else if (LVIsNilSymbol(chars, i, tokLen)) tok->tokenType |= LVTokenType_NilSymbol;
                else if (LVIsDeflikeSymbol(chars, i, tokLen)) tok->tokenType |= LVTokenType_Deflike;
                
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
