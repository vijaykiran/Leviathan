//
//  parser.mm
//  Leviathan
//
//  Created by Steven on 10/19/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#include "parser.h"

#include "lexer.h"

namespace Leviathan {
    
    Coll* parseColl(bool live, std::vector<Token*>::iterator iter, Coll::Type collType, Token::Type endTokenType) {
        Token* openToken = *iter;
        Token* closeToken;
        iter++;
        
        std::list<Element*> children;
        
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
            
            // parse one, add to children
            
        }
        
        if (live) {
            Coll* coll = new Coll;
            coll->collType = collType;
            coll->open_token = openToken;
            coll->close_token = closeToken;
            
            // move children to child->chilren;
            
            for (Element* child : coll->children) {
                child->parent = coll;
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
        
        if (error.type == ParserError::NoError) {
            try {
                error.type = ParserError::NoError;
                parseColl(false, tokens.begin(), Coll::TopLevel, Token::FileEnd); // dry-run
                
                top_level_coll = parseColl(true, tokens.begin(), Coll::TopLevel, Token::FileEnd);
            } catch (ParserError& e) {
                error = e;
                // delete tokens
            }
        }
        else {
            // TODO: lexing had an error, so delete all token* ptrs in "tokens"
        }
        
        return std::make_pair(top_level_coll, error);
    }
    
}
