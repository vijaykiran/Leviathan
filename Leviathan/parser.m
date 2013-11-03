//
//  parser.mm
//  Leviathan
//
//  Created by Steven on 10/19/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "parser.h"

#import "lexer.h"
#import "atom.h"

#import "LVParseError.h"

static LVColl* parseColl(LVToken** iter, LVCollType collType, LVTokenType endTokenType);

static LVElement* parseOne(LVToken** iter) {
    LVToken* currentToken = *iter;
    
    if (currentToken->tokenType & LVTokenType_LParen) {
        return (LVElement*)parseColl(iter, LVCollType_List, LVTokenType_RParen);
    }
    else if (currentToken->tokenType & LVTokenType_LBracket) {
        return (LVElement*)parseColl(iter, LVCollType_Vector, LVTokenType_RBracket);
    }
    else if (currentToken->tokenType & LVTokenType_LBrace) {
        return (LVElement*)parseColl(iter, LVCollType_Map, LVTokenType_RBrace);
    }
    else if (currentToken->tokenType & LVTokenType_AnonFnStart) {
        return (LVElement*)parseColl(iter, LVCollType_AnonFn, LVTokenType_RParen);
    }
    else if (currentToken->tokenType & LVTokenType_SetStart) {
        return (LVElement*)parseColl(iter, LVCollType_Set, LVTokenType_RBrace);
    }
    else if (currentToken->tokenType & LVTokenType_Spaces) {
        *iter = (*iter)->nextToken;
        return (LVElement*)LVAtomCreate(LVAtomType_Spaces, currentToken);
    }
    else if (currentToken->tokenType & LVTokenType_Var) {
        *iter = (*iter)->nextToken;
        return (LVElement*)LVAtomCreate(LVAtomType_Var, currentToken);
    }
    else if (currentToken->tokenType & LVTokenType_ReaderMacro) {
        *iter = (*iter)->nextToken;
        return (LVElement*)LVAtomCreate(LVAtomType_ReaderMacro, currentToken);
    }
    else if (currentToken->tokenType & LVTokenType_Number) {
        *iter = (*iter)->nextToken;
        return (LVElement*)LVAtomCreate(LVAtomType_Number, currentToken);
    }
    else if (currentToken->tokenType & LVTokenType_TypeOp) {
        *iter = (*iter)->nextToken;
        return (LVElement*)LVAtomCreate(LVAtomType_TypeOp, currentToken);
    }
    else if (currentToken->tokenType & LVTokenType_Quote) {
        *iter = (*iter)->nextToken;
        return (LVElement*)LVAtomCreate(LVAtomType_Quote, currentToken);
    }
    else if (currentToken->tokenType & LVTokenType_Unquote) {
        *iter = (*iter)->nextToken;
        return (LVElement*)LVAtomCreate(LVAtomType_Unquote, currentToken);
    }
    else if (currentToken->tokenType & LVTokenType_SyntaxQuote) {
        *iter = (*iter)->nextToken;
        return (LVElement*)LVAtomCreate(LVAtomType_SyntaxQuote, currentToken);
    }
    else if (currentToken->tokenType & LVTokenType_Splice) {
        *iter = (*iter)->nextToken;
        return (LVElement*)LVAtomCreate(LVAtomType_Splice, currentToken);
    }
    else if (currentToken->tokenType & LVTokenType_Keyword) {
        *iter = (*iter)->nextToken;
        return (LVElement*)LVAtomCreate(LVAtomType_Keyword, currentToken);
    }
    else if (currentToken->tokenType & LVTokenType_String) {
        *iter = (*iter)->nextToken;
        return (LVElement*)LVAtomCreate(LVAtomType_String, currentToken);
    }
    else if (currentToken->tokenType & LVTokenType_Regex) {
        *iter = (*iter)->nextToken;
        return (LVElement*)LVAtomCreate(LVAtomType_Regex, currentToken);
    }
    else if (currentToken->tokenType & LVTokenType_CommentLiteral) {
        *iter = (*iter)->nextToken;
        return (LVElement*)LVAtomCreate(LVAtomType_Comment, currentToken);
    }
    else if (currentToken->tokenType & LVTokenType_Newlines) {
        *iter = (*iter)->nextToken;
        return (LVElement*)LVAtomCreate(LVAtomType_Newlines, currentToken);
    }
    else if (currentToken->tokenType & LVTokenType_Comma) {
        *iter = (*iter)->nextToken;
        return (LVElement*)LVAtomCreate(LVAtomType_Comma, currentToken);
    }
    else if (currentToken->tokenType & LVTokenType_ReaderCommentStart) {
        // TODO: reader-comments could be considered a type of list, with "#_" as the opening token and "" as the closing
        *iter = (*iter)->nextToken;
        return (LVElement*)LVAtomCreate(LVAtomType_ReaderComment, currentToken);
    }
    else if (currentToken->tokenType & LVTokenType_Symbol) {
        *iter = (*iter)->nextToken;
        LVAtom* atom = LVAtomCreate(LVAtomType_Symbol, currentToken);
        
             if (currentToken->tokenType & LVTokenType_TrueSymbol)  atom->atomType |= LVAtomType_TrueAtom;
        else if (currentToken->tokenType & LVTokenType_FalseSymbol) atom->atomType |= LVAtomType_FalseAtom;
        else if (currentToken->tokenType & LVTokenType_NilSymbol)   atom->atomType |= LVAtomType_NilAtom;
        
        return (LVElement*)atom;
    }
    else if (currentToken->tokenType & LVTokenType_FileEnd) {
        printf("reached end of tokens too early\n");
        @throw [LVParseError exceptionWithName:@"uhh" reason:@"heh" userInfo:nil];
    }
    
    printf("Can't handle this token type: %llu, %s\n", currentToken->tokenType, CFStringGetCStringPtr(currentToken->string, kCFStringEncodingUTF8));
    @throw [LVParseError exceptionWithName:@"uhh" reason:@"heh" userInfo:nil];
}

static LVColl* parseColl(LVToken** iter, LVCollType collType, LVTokenType endTokenType) {
    LVColl* coll = LVCollCreate();
    coll->collType = collType;
    
    LVElementListAppend(coll, (LVElement*)LVAtomCreate(LVAtomType_CollDelim | LVAtomType_CollOpener, *iter));
    
    *iter = (*iter)->nextToken;
    
    for (LVToken* currentToken; ; ) {
        currentToken = *iter;
        
        if (currentToken->tokenType == endTokenType) {
            LVElementListAppend(coll, (LVElement*)LVAtomCreate(LVAtomType_CollDelim | LVAtomType_CollCloser, currentToken));
            *iter = (*iter)->nextToken;
            break;
        }
        
        if (currentToken->tokenType == LVTokenType_FileEnd) {
            printf("unclosed coll somewhere :(\n");
            @throw [LVParseError exceptionWithName:@"uhh" reason:@"heh" userInfo:nil];
        }
        
        LVElement* child = parseOne(iter);
        LVElementListAppend(coll, child);
    }
    
    if (coll->collType & LVCollType_List) {
        LVElement* semanticChildren[coll->childrenLen];
        NSUInteger semanticChildrenCount;
        LVGetSemanticDirectChildren(coll, 0, semanticChildren, &semanticChildrenCount);
        
        if (semanticChildrenCount >= 1) {
            LVAtom* firstAtom = (LVAtom*)semanticChildren[0];
            
            if (firstAtom->isAtom) {
                if (firstAtom->token->tokenType & LVTokenType_Deflike) {
                    coll->collType |= LVCollType_Definition;
                    firstAtom->atomType |= LVAtomType_DefType;
                    
                    for (int i = 1; i < semanticChildrenCount; i++) {
                        LVAtom* semanticChild = (LVAtom*)semanticChildren[i];
                        if (semanticChild->isAtom && semanticChild->atomType & LVAtomType_Symbol) {
                            semanticChild->atomType |= LVAtomType_DefName;
                            break;
                        }
                    }
                }
                else if (firstAtom->token->tokenType & LVTokenType_Symbol) {
                    firstAtom->atomType |= LVAtomType_Operator;
                }
            }
        }
    }
    
    return coll;
}

LVColl* LVParseTokens(LVToken* firstToken) {
    LVColl* topLevelColl = parseColl(&firstToken, LVCollType_TopLevel, LVTokenType_FileEnd);
    topLevelColl->parent = NULL;
    return topLevelColl;
}
