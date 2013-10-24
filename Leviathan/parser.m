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

static LVColl* parseColl(LVToken*** iter, LVCollType collType, LVTokenType endTokenType);

static LVElement* parseOne(LVToken*** iter) {
    LVToken* currentToken = **iter;
    
//    printf("token = %llu, [%s]\n", currentToken->type, currentToken->val->data);
    
    if (currentToken->token_type & LVTokenType_LParen) {
        return (LVElement*)parseColl(iter, LVCollType_List, LVTokenType_RParen);
    }
    else if (currentToken->token_type & LVTokenType_LBracket) {
        return (LVElement*)parseColl(iter, LVCollType_Vector, LVTokenType_RBracket);
    }
    else if (currentToken->token_type & LVTokenType_LBrace) {
        return (LVElement*)parseColl(iter, LVCollType_Map, LVTokenType_RBrace);
    }
    else if (currentToken->token_type & LVTokenType_AnonFnStart) {
        return (LVElement*)parseColl(iter, LVCollType_AnonFn, LVTokenType_RParen);
    }
    else if (currentToken->token_type & LVTokenType_SetStart) {
        return (LVElement*)parseColl(iter, LVCollType_Set, LVTokenType_RBrace);
    }
    else if (currentToken->token_type & LVTokenType_Spaces) {
        ++*iter;
        return (LVElement*)LVAtomCreate(LVAtomType_Spaces, currentToken);
    }
    else if (currentToken->token_type & LVTokenType_Var) {
        ++*iter;
        return (LVElement*)LVAtomCreate(LVAtomType_Var, currentToken);
    }
    else if (currentToken->token_type & LVTokenType_ReaderMacro) {
        ++*iter;
        return (LVElement*)LVAtomCreate(LVAtomType_ReaderMacro, currentToken);
    }
    else if (currentToken->token_type & LVTokenType_Number) {
        ++*iter;
        return (LVElement*)LVAtomCreate(LVAtomType_Number, currentToken);
    }
    else if (currentToken->token_type & LVTokenType_TypeOp) {
        ++*iter;
        return (LVElement*)LVAtomCreate(LVAtomType_TypeOp, currentToken);
    }
    else if (currentToken->token_type & LVTokenType_Quote) {
        ++*iter;
        return (LVElement*)LVAtomCreate(LVAtomType_Quote, currentToken);
    }
    else if (currentToken->token_type & LVTokenType_Unquote) {
        ++*iter;
        return (LVElement*)LVAtomCreate(LVAtomType_Unquote, currentToken);
    }
    else if (currentToken->token_type & LVTokenType_SyntaxQuote) {
        ++*iter;
        return (LVElement*)LVAtomCreate(LVAtomType_SyntaxQuote, currentToken);
    }
    else if (currentToken->token_type & LVTokenType_Splice) {
        ++*iter;
        return (LVElement*)LVAtomCreate(LVAtomType_Splice, currentToken);
    }
    else if (currentToken->token_type & LVTokenType_Keyword) {
        ++*iter;
        return (LVElement*)LVAtomCreate(LVAtomType_Keyword, currentToken);
    }
    else if (currentToken->token_type & LVTokenType_String) {
        ++*iter;
        return (LVElement*)LVAtomCreate(LVAtomType_String, currentToken);
    }
    else if (currentToken->token_type & LVTokenType_Regex) {
        ++*iter;
        return (LVElement*)LVAtomCreate(LVAtomType_Regex, currentToken);
    }
    else if (currentToken->token_type & LVTokenType_CommentLiteral) {
        ++*iter;
        return (LVElement*)LVAtomCreate(LVAtomType_Comment, currentToken);
    }
    else if (currentToken->token_type & LVTokenType_Newline) {
        ++*iter;
        return (LVElement*)LVAtomCreate(LVAtomType_Newline, currentToken);
    }
    else if (currentToken->token_type & LVTokenType_Comma) {
        ++*iter;
        return (LVElement*)LVAtomCreate(LVAtomType_Comma, currentToken);
    }
    else if (currentToken->token_type & LVTokenType_ReaderCommentStart) {
        // TODO: parse-next and join as one comment atom with combined tokens.
        ++*iter;
        return (LVElement*)LVAtomCreate(LVAtomType_ReaderComment, currentToken);
    }
    else if (currentToken->token_type & LVTokenType_Symbol) {
        ++*iter;
        LVAtom* atom = LVAtomCreate(LVAtomType_Symbol, currentToken);
        
             if (currentToken->token_type & LVTokenType_TrueSymbol)  atom->atom_type |= LVAtomType_TrueAtom;
        else if (currentToken->token_type & LVTokenType_FalseSymbol) atom->atom_type |= LVAtomType_FalseAtom;
        else if (currentToken->token_type & LVTokenType_NilSymbol)   atom->atom_type |= LVAtomType_NilAtom;
        
        return (LVElement*)atom;
    }
    else if (currentToken->token_type & LVTokenType_FileEnd) {
        printf("reached end of tokens too early\n");
        abort();
    }
    
    printf("Can't handle this token type: %llu, %s\n", currentToken->token_type, currentToken->string->data);
    abort();
}

static LVColl* parseColl(LVToken*** iter, LVCollType collType, LVTokenType endTokenType) {
    LVColl* coll = LVCollCreate();
    coll->coll_type = collType;
    coll->open_token = **iter;
    ++*iter;
    
//    printf("open coll type = %llu, wanting %llu, %s\n", coll->open_token->type, collType, coll->open_token->val->data);
    
    for (LVToken* currentToken; ; ) {
        currentToken = **iter;
        
        if (currentToken->token_type == endTokenType) {
            coll->close_token = currentToken;
            ++*iter;
            break;
        }
        
        if (currentToken->token_type == LVTokenType_FileEnd) {
            printf("unclosed coll somewhere :(\n");
            abort();
        }
        
        LVElement* child = parseOne(iter);
        child->parent = coll;
        LVElementListAppend(coll, child);
    }
    
//    printf("done getting children for coll type = %llu\n", collType);
    
    return coll;
}

LVColl* LVParse(const char* raw) {
    size_t tok_n;
    LVToken** tokens = LVLex(raw, &tok_n);
    
    LVToken** iter = tokens;
    LVColl* topLevelColl = parseColl(&iter, LVCollType_TopLevel, LVTokenType_FileEnd);
    topLevelColl->parent = NULL;
    
    free(tokens);
    
    return topLevelColl;
}
