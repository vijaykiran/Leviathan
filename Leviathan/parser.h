//
//  parser.h
//  Leviathan
//
//  Created by Steven on 10/19/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "coll.h"
#import "token.h"

struct __LVDocStorage;

LVColl* LVParseTokens(struct __LVDocStorage* storage, LVToken* firstToken);
