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
    coll->children = LVLinkedListCreate();
    return coll;
}

void LVCollDestroy(LVColl* coll) {
    for (LVLinkedListNode* node = coll->children->head; node; node = node->next) {
        LVElement* element = node->val;
        if (element->elementType & LVElementType_Coll) {
            LVCollDestroy((LVColl*)element);
        }
        else if (element->elementType & LVElementType_Atom) {
//            LVAtomDestroy((LVAtom*)element);
        }
    }
    
    LVLinkedListDestroy(coll->children);
    LVTokenDelete(coll->open_token);
    LVTokenDelete(coll->close_token);
    free(coll);
}




//    size_t Coll::length() {
//        size_t len = this->open_token->val.length() + this->close_token->val.length();
//        for (Element* child : this->children) {
//            len += child->length();
//        }
//        return len;
//    }
