//
//  coll.mm
//  Leviathan
//
//  Created by Steven on 10/20/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "coll.h"
#import "token.h"

LVColl* LVCollCreate() {
    LVColl* coll = malloc(sizeof(LVColl));
    coll->elementType = LVElementType_Coll;
    return coll;
}

void LVCollDestroy(LVColl* coll) {
    LVTokenDelete(coll->open_token);
    LVTokenDelete(coll->close_token);
    
    // TODO: delete each child
    // TODO: linked list
    
    free(coll);
}




//    size_t Coll::length() {
//        size_t len = this->open_token->val.length() + this->close_token->val.length();
//        for (Element* child : this->children) {
//            len += child->length();
//        }
//        return len;
//    }
