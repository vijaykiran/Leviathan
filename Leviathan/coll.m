//
//  coll.mm
//  Leviathan
//
//  Created by Steven on 10/20/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "coll.h"
#import "token.h"
#import "atom.h"

LVColl* LVCollCreate() {
    LVColl* coll = malloc(sizeof(LVColl));
    coll->elementType = LVElementType_Coll;
    coll->children = LVLinkedListCreate();
    return coll;
}

void LVCollDestroy(LVColl* coll) {
    for (LVLinkedListNode* node = coll->children->head; node; node = node->next) {
        LVElementDestroy(node->val);
    }
    
    LVLinkedListDestroy(coll->children);
    LVTokenDelete(coll->open_token);
    LVTokenDelete(coll->close_token);
    free(coll);
}
