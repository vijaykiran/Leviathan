//
//  parser.mm
//  Leviathan
//
//  Created by Steven on 10/19/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#include "parser.h"

#include "lexer.h"
#include "atom.h"

namespace Leviathan {
    
    Coll* parseColl(bool live, std::vector<Token*>::iterator& iter, Coll::Type collType, Token::Type endTokenType);
    
    Element* parseOne(bool live, std::vector<Token*>::iterator& iter) {
        Token* currentToken = *iter;
        
//        std::cout << currentToken->val << std::endl;
        
        if (currentToken->type & Token::LParen) {
            return parseColl(live, iter, Coll::List, Token::RParen);
        }
        if (currentToken->type & Token::Symbol) {
            iter++;
            if (live)
                return new Atom(Atom::Symbol, currentToken);
            else
                return NULL;
        }
        if (currentToken->type & Token::Spaces) {
            iter++;
            if (live)
                return new Atom(Atom::Spaces, currentToken);
            else
                return NULL;
        }
        else if (currentToken->type & Token::Number) {
            iter++;
            if (live)
                return new Atom(Atom::Number, currentToken);
            else
                return NULL;
        }
        
        return NULL;
        
    }
    
    Coll* parseColl(bool live, std::vector<Token*>::iterator& iter, Coll::Type collType, Token::Type endTokenType) {
        Token* openToken = *iter;
        Token* closeToken;
        iter++;
        
        Coll* coll = (live ? new Coll : NULL);
        
        for(Token* currentToken ; ; ) {
            
            currentToken = *iter;
            
            if (currentToken->type == endTokenType) {
                closeToken = currentToken;
                iter++;
                break;
            }
            
            if (currentToken->type == Token::FileEnd) {
                throw ParserError{ParserError::UnclosedColl};
            }
            
            Element* child = parseOne(live, iter);
            
            if (live) {
                coll->children.push_back(child);
            }
        }
        
        if (live) {
            coll->collType = collType;
            coll->open_token = openToken;
            coll->close_token = closeToken;
            
            size_t i = 0;
            for (Element* child : coll->children) {
                child->parent = coll;
                child->index = i++;
            }
            
            return coll;
        }
        else {
            return NULL;
        }
    }
    
    std::pair<Coll*, ParserError> parse(std::string const& raw) {
        std::pair<std::vector<Token*>, ParserError> result = lex(raw);
        
        std::vector<Token*> tokens = result.first;
        ParserError error = result.second;
        
        Coll* top_level_coll;
        
        if (error.type != ParserError::NoError) {
            for (Token* token : tokens) delete token;
            return std::make_pair(top_level_coll, error);
        }
        
        try {
            // dry-run
            auto iter = tokens.begin();
            parseColl(false, iter, Coll::TopLevel, Token::FileEnd);
        }
        catch (ParserError& e) {
            for (Token* token : tokens) delete token;
            return std::make_pair(top_level_coll, e);
        }
        
        auto iter = tokens.begin();
        top_level_coll = parseColl(true, iter, Coll::TopLevel, Token::FileEnd);
        top_level_coll->parent = NULL;
        
        return std::make_pair(top_level_coll, error);
    }
    
}
