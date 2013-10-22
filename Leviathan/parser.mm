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
    
    Element* parseOne(bool live, std::vector<Token*>::iterator& iter) {
        Token* currentToken = *iter;
        
        std::cout << *currentToken << std::endl;
        
        if (currentToken->type & Token::Symbol) {
            iter++;
            if (live)
                return new Atom{};
            else
                return NULL;
        }
        
        return NULL;
        
    }
    
    Coll* parseColl(bool live, std::vector<Token*>::iterator& iter, Coll::Type collType, Token::Type endTokenType) {
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
            
            Element* child = parseOne(live, iter);
            
            children.push_back(child);
            
        }
        
        if (live) {
            Coll* coll = new Coll;
            coll->collType = collType;
            coll->open_token = openToken;
            coll->close_token = closeToken;
            
            std::move(children.begin(), children.end(), std::back_inserter(coll->children));
            
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
        
        if (error.type == ParserError::NoError) {
            try {
                error.type = ParserError::NoError;
                auto iter = tokens.begin();
                
                parseColl(false, iter, Coll::TopLevel, Token::FileEnd); // dry-run
                
                // if we're still here, then there's no errors
                
                iter = tokens.begin();
                top_level_coll = parseColl(true, iter, Coll::TopLevel, Token::FileEnd); // real thing
                top_level_coll->parent = NULL;
            } catch (ParserError& e) {
                error = e;
                
                std::cout << "uhh, error!" << std::endl;
                
                // delete tokens
            }
        }
        else {
            // TODO: lexing had an error, so delete all token* ptrs in "tokens"
        }
        
        return std::make_pair(top_level_coll, error);
    }
    
}
