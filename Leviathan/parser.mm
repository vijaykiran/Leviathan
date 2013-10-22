//
//  parser.mm
//  Leviathan
//
//  Created by Steven on 10/19/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#include "parser.h"

namespace Leviathan {
    
    std::pair<coll*, ParserError> parse(std::string const& raw) {
        coll* top_level_coll = new coll;
        top_level_coll->collType = coll::TopLevel;
        ParserError error;
        
        return std::make_pair(top_level_coll, error);
    }
    
}
