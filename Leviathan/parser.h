//
//  parser.h
//  Leviathan
//
//  Created by Steven on 10/19/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#ifndef __Leviathan__parser__
#define __Leviathan__parser__

#include <iostream>

#include "parse_error.h"
#include "coll.h"

namespace leviathan {
    
    std::pair<coll*, ParserError> parse(std::string const& raw);
    
}

#endif /* defined(__Leviathan__parser__) */
