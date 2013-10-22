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
    
//    std::pair<Coll*, ParserError> parseColl() {
//        
//    }
    
    std::pair<Coll*, ParserError> parse(std::string const& raw) {
        std::pair<std::vector<Token*>, ParserError> result = lex(raw);
        
        std::vector<Token*> tokens = result.first;
        ParserError error = result.second;
        
        Coll* top_level_coll;
        
        if (result.second.type != ParserError::NoError) {
//            size_t ended;
//            std::pair<std::vector<Token*>, ParserError> result = parseColl(tokens, 0, &ended, Coll::TopLevel, Token::End);
//            
//            top_level_coll = new Coll;
//            top_level_coll->collType = Coll::TopLevel;
        }
        
        return std::make_pair(top_level_coll, error);
    }
    
}
