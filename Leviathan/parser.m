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

static LVElement* parseOne(LVToken** iter) {
    return NULL;
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
        LVLinkedListAppend(coll->children, child);
    }
    
    size_t i = 0;
    for (LVLinkedListNode* node = coll->children->head; node; node = node->next) {
        LVElement* child = node->val;
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





//    Coll* parseColl(bool live, std::vector<Token*>::iterator& iter, Coll::Type collType, Token::Type endTokenType);
//
//    Element* parseOne(bool live, std::vector<Token*>::iterator& iter) {
//        Token* currentToken = *iter;
//        
////        std::cout << currentToken->val << std::endl;
//        
//        if (currentToken->type & Token::LParen) {
//            return parseColl(live, iter, Coll::List, Token::RParen);
//        }
//        else if (currentToken->type & Token::LBracket) {
//            return parseColl(live, iter, Coll::Vector, Token::RBracket);
//        }
//        else if (currentToken->type & Token::LBrace) {
//            return parseColl(live, iter, Coll::Map, Token::RBrace);
//        }
//        else if (currentToken->type & Token::AnonFnStart) {
//            return parseColl(live, iter, Coll::AnonFn, Token::RParen);
//        }
//        else if (currentToken->type & Token::RParen) {
//            throw ParserError{ParserError::UnopenedCollClosed};
//        }
//        else if (currentToken->type & Token::Symbol) {
//            iter++;
//            if (!live) return NULL;
//            if (currentToken->type & Token::TrueSymbol) return new Atom(Atom::Symbol | Atom::TrueAtom, currentToken);
//            if (currentToken->type & Token::FalseSymbol) return new Atom(Atom::Symbol | Atom::FalseAtom, currentToken);
//            if (currentToken->type & Token::NilSymbol) return new Atom(Atom::Symbol | Atom::NilAtom, currentToken);
//            return new Atom(Atom::Symbol, currentToken);
//        }
//        else if (currentToken->type & Token::Spaces) {
//            iter++;
//            return (live? new Atom(Atom::Spaces, currentToken) : NULL);
//        }
//        else if (currentToken->type & Token::Number) {
//            iter++;
//            return (live? new Atom(Atom::Number, currentToken) : NULL);
//        }
//        else if (currentToken->type & Token::Keyword) {
//            iter++;
//            return (live? new Atom(Atom::Keyword, currentToken) : NULL);
//        }
//        
//        printf("Can't handle this token type: %llu, %s\n", currentToken->type, currentToken->val.c_str());
//        exit(1);
//    }
