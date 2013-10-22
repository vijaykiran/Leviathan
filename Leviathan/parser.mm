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
    
    std::pair<Coll*, ParserError> parse(std::string const& raw) {
        Coll* top_level_coll = new Coll;
        top_level_coll->collType = Coll::TopLevel;
        ParserError error;
        
        return std::make_pair(top_level_coll, error);
    }
    
}
