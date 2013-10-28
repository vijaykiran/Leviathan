//
//  parser.h
//  Leviathan
//
//  Created by Steven on 10/19/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "coll.h"
#import "token.h"

//LVColl* LVParse(const char* raw); // TODO: deprecated, only used in tests.
LVColl* LVParseTokens(LVToken** tokens);
