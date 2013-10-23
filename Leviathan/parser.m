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

static LVColl* parseColl(LVToken** iter, LVCollType collType, LVTokenType endTokenType);

static LVElement* parseOne(LVToken** iter) {
    LVToken* currentToken = *iter;
    
    if (currentToken->type & LVTokenType_LParen) {
        return (LVElement*)parseColl(iter, LVCollType_List, LVTokenType_RParen);
    }
    else if (currentToken->type & LVTokenType_LBracket) {
        return (LVElement*)parseColl(iter, LVCollType_Vector, LVTokenType_RBracket);
    }
    else if (currentToken->type & LVTokenType_LBrace) {
        return (LVElement*)parseColl(iter, LVCollType_Map, LVTokenType_RBrace);
    }
    else if (currentToken->type & LVTokenType_AnonFnStart) {
        return (LVElement*)parseColl(iter, LVCollType_AnonFn, LVTokenType_RParen);
    }
    else if (currentToken->type & LVTokenType_Spaces) {
        iter++;
        return (LVElement*)LVAtomCreate(LVAtomType_Spaces, currentToken);
    }
    else if (currentToken->type & LVTokenType_Number) {
        iter++;
        return (LVElement*)LVAtomCreate(LVAtomType_Number, currentToken);
    }
    else if (currentToken->type & LVTokenType_Keyword) {
        iter++;
        return (LVElement*)LVAtomCreate(LVAtomType_Keyword, currentToken);
    }
    else if (currentToken->type & LVTokenType_Symbol) {
        iter++;
        LVAtom* atom = LVAtomCreate(LVAtomType_Symbol, currentToken);
        
             if (currentToken->type & LVTokenType_TrueSymbol)  atom->atomType |= LVAtomType_TrueAtom;
        else if (currentToken->type & LVTokenType_FalseSymbol) atom->atomType |= LVAtomType_FalseAtom;
        else if (currentToken->type & LVTokenType_NilSymbol)   atom->atomType |= LVAtomType_NilAtom;
        
        return (LVElement*)atom;
    }
    
    printf("Can't handle this token type: %llu, %s\n", currentToken->type, currentToken->val->data);
    exit(1);
}

static LVColl* parseColl(LVToken** iter, LVCollType collType, LVTokenType endTokenType) {
    LVColl* coll = LVCollCreate();
    coll->collType = collType;
    coll->open_token = *iter;
    iter++;
    
    for (LVToken* currentToken; ; ) {
        currentToken = *iter;
        
        if (currentToken->type == endTokenType) {
            coll->close_token = currentToken;
            iter++;
            break;
        }
        
        if (currentToken->type == LVTokenType_FileEnd) {
            printf("unclosed coll somewhere :(\n");
            exit(1);
        }
        
        LVElement* child = parseOne(iter);
        LVCollChildrenAppend((&coll->children), child);
    }
    
    for (int i = 0; i < coll->children.len; i++) {
        LVElement* child = coll->children.elements[i];
        child->parent = coll;
        child->index = i++;
    }
    
    return coll;
}

LVColl* LVParse(char* raw) {
    size_t tok_n;
    LVToken** tokens = LVLex(raw, &tok_n);
    
    LVColl* topLevelColl = parseColl(tokens, LVCollType_TopLevel, LVTokenType_FileEnd);
    topLevelColl->parent = NULL;
    
    free(tokens);
    
    return topLevelColl;
}
