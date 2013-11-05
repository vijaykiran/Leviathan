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

static LVColl* parseColl(LVDocStorage* storage, LVToken** iter, LVCollType collType, LVTokenType endTokenType);

static LVElement* parseOne(LVDocStorage* storage, LVToken** iter) {
    LVToken* currentToken = *iter;
    
    if (currentToken->tokenType & LVTokenType_LParen) {
        return (LVElement*)parseColl(storage, iter, LVCollType_List, LVTokenType_RParen);
    }
    else if (currentToken->tokenType & LVTokenType_LBracket) {
        return (LVElement*)parseColl(storage, iter, LVCollType_Vector, LVTokenType_RBracket);
    }
    else if (currentToken->tokenType & LVTokenType_LBrace) {
        return (LVElement*)parseColl(storage, iter, LVCollType_Map, LVTokenType_RBrace);
    }
    else if (currentToken->tokenType & LVTokenType_AnonFnStart) {
        return (LVElement*)parseColl(storage, iter, LVCollType_AnonFn, LVTokenType_RParen);
    }
    else if (currentToken->tokenType & LVTokenType_SetStart) {
        return (LVElement*)parseColl(storage, iter, LVCollType_Set, LVTokenType_RBrace);
    }
    else if (currentToken->tokenType & LVTokenType_Spaces) {
        *iter = (*iter)->nextToken;
        return (LVElement*)LVAtomCreate(storage, LVAtomType_Spaces, currentToken);
    }
    else if (currentToken->tokenType & LVTokenType_Var) {
        *iter = (*iter)->nextToken;
        return (LVElement*)LVAtomCreate(storage, LVAtomType_Var, currentToken);
    }
    else if (currentToken->tokenType & LVTokenType_ReaderMacro) {
        *iter = (*iter)->nextToken;
        return (LVElement*)LVAtomCreate(storage, LVAtomType_ReaderMacro, currentToken);
    }
    else if (currentToken->tokenType & LVTokenType_Number) {
        *iter = (*iter)->nextToken;
        return (LVElement*)LVAtomCreate(storage, LVAtomType_Number, currentToken);
    }
    else if (currentToken->tokenType & LVTokenType_TypeOp) {
        *iter = (*iter)->nextToken;
        return (LVElement*)LVAtomCreate(storage, LVAtomType_TypeOp, currentToken);
    }
    else if (currentToken->tokenType & LVTokenType_Quote) {
        *iter = (*iter)->nextToken;
        return (LVElement*)LVAtomCreate(storage, LVAtomType_Quote, currentToken);
    }
    else if (currentToken->tokenType & LVTokenType_Unquote) {
        *iter = (*iter)->nextToken;
        return (LVElement*)LVAtomCreate(storage, LVAtomType_Unquote, currentToken);
    }
    else if (currentToken->tokenType & LVTokenType_SyntaxQuote) {
        *iter = (*iter)->nextToken;
        return (LVElement*)LVAtomCreate(storage, LVAtomType_SyntaxQuote, currentToken);
    }
    else if (currentToken->tokenType & LVTokenType_Splice) {
        *iter = (*iter)->nextToken;
        return (LVElement*)LVAtomCreate(storage, LVAtomType_Splice, currentToken);
    }
    else if (currentToken->tokenType & LVTokenType_Keyword) {
        *iter = (*iter)->nextToken;
        return (LVElement*)LVAtomCreate(storage, LVAtomType_Keyword, currentToken);
    }
    else if (currentToken->tokenType & LVTokenType_String) {
        *iter = (*iter)->nextToken;
        return (LVElement*)LVAtomCreate(storage, LVAtomType_String, currentToken);
    }
    else if (currentToken->tokenType & LVTokenType_Regex) {
        *iter = (*iter)->nextToken;
        return (LVElement*)LVAtomCreate(storage, LVAtomType_Regex, currentToken);
    }
    else if (currentToken->tokenType & LVTokenType_CommentLiteral) {
        *iter = (*iter)->nextToken;
        return (LVElement*)LVAtomCreate(storage, LVAtomType_Comment, currentToken);
    }
    else if (currentToken->tokenType & LVTokenType_Newlines) {
        *iter = (*iter)->nextToken;
        return (LVElement*)LVAtomCreate(storage, LVAtomType_Newlines, currentToken);
    }
    else if (currentToken->tokenType & LVTokenType_Comma) {
        *iter = (*iter)->nextToken;
        return (LVElement*)LVAtomCreate(storage, LVAtomType_Comma, currentToken);
    }
    else if (currentToken->tokenType & LVTokenType_ReaderCommentStart) {
        // TODO: reader-comments could be considered a type of list, with "#_" as the opening token and "" as the closing
        *iter = (*iter)->nextToken;
        return (LVElement*)LVAtomCreate(storage, LVAtomType_ReaderComment, currentToken);
    }
    else if (currentToken->tokenType & LVTokenType_Symbol) {
        *iter = (*iter)->nextToken;
        LVAtom* atom = LVAtomCreate(storage, LVAtomType_Symbol, currentToken);
        
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

static LVColl* parseColl(LVDocStorage* storage, LVToken** iter, LVCollType collType, LVTokenType endTokenType) {
    LVColl* coll = LVCollCreate(storage);
    coll->collType = collType;
    
    LVElementListAppend(coll, (LVElement*)LVAtomCreate(storage, LVAtomType_CollDelim | LVAtomType_CollOpener, *iter));
    
    *iter = (*iter)->nextToken;
    
    for (LVToken* currentToken; ; ) {
        currentToken = *iter;
        
        if (currentToken->tokenType == endTokenType) {
            LVElementListAppend(coll, (LVElement*)LVAtomCreate(storage, LVAtomType_CollDelim | LVAtomType_CollCloser, currentToken));
            *iter = (*iter)->nextToken;
            break;
        }
        
        if (currentToken->tokenType == LVTokenType_FileEnd) {
            printf("unclosed coll somewhere :(\n");
            @throw [LVParseError exceptionWithName:@"uhh" reason:@"heh" userInfo:nil];
        }
        
        LVElement* child = parseOne(storage, iter);
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

LVColl* LVParseTokens(LVDocStorage* storage, LVToken* firstToken) {
    LVColl* topLevelColl = parseColl(storage, &firstToken, LVCollType_TopLevel, LVTokenType_FileEnd);
    topLevelColl->parent = NULL;
    return topLevelColl;
}
