//
//  coll.mm
//  Leviathan
//
//  Created by Steven on 10/20/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#include "coll.h"

static char const* const coll_type_strs[] = {
#define X(a) #a,
#include "coll_types.def"
#undef X
};

