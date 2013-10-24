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

#define LV_COLL_CHUNK_SIZE (20)

LVColl* LVCollCreate() {
    LVColl* coll = malloc(sizeof(LVColl));
    coll->elementType = LVElementType_Coll;
    
    coll->children.cap = LV_COLL_CHUNK_SIZE;
    coll->children.len = 0;
    coll->children.elements = malloc(sizeof(LVElement*) * coll->children.cap);
    
    return coll;
}

void LVCollDestroy(LVColl* coll) {
    for (int i = 0; i < coll->children.len; i++) {
        LVElement* child = coll->children.elements[i];
        LVElementDestroy(child);
    }
    
    free(coll->children.elements);
    LVTokenDelete(coll->open_token);
    LVTokenDelete(coll->close_token);
    free(coll);
}

void LVElementListAppend(LVColl* coll, LVElement* child) {
    if (coll->children.len == coll->children.cap) {
        coll->children.cap += LV_COLL_CHUNK_SIZE;
        coll->children.elements = realloc(coll->children.elements, sizeof(LVElement*) * coll->children.cap);
    }
//    printf("adding child %p to %p at %lu\n", child, coll, coll->children.len);
    coll->children.elements[coll->children.len] = child;
//    printf("child added: child %p, should == %p which is at index %lu\n", child, coll->children.elements[coll->children.len], coll->children.len);
    coll->children.len++;
}



//- (LVColl*) deepestCollAtPos:(NSUInteger)pos childsIndex:(NSUInteger*)childsIndex {
//    int i = 0;
//    
//    if (pos <= NSMaxRange(self.openingToken.range)) {
//        *childsIndex = 0;
//        return self;
//    }
//    
//    for (id<LVElement> child in self.childElements) {
//        
//        if (pos < NSMaxRange([child fullyEnclosedRange])) {
//            
//            if ([child isAtom]) {
//                *childsIndex = i;
//                return self;
//            }
//            else {
//                if (pos <= [child fullyEnclosedRange].location) {
//                    *childsIndex = i;
//                    return self;
//                }
//                else {
//                    return [[child asColl] deepestCollAtPos:pos childsIndex:childsIndex];
//                }
//            }
//            
//        }
//        
//        i++;
//    }
//    
//    *childsIndex = i;
//    return self;
//}
//
//- (void) findDefinitions:(NSMutableArray*)defs {
//    for (id<LVElement> child in self.childElements) {
//        if ([child isKindOfClass:[LVDefinition self]]) {
//            [defs addObject:child];
//        }
//        
//        if ([child isColl]) {
//            [[child asColl] findDefinitions:defs];
//        }
//    }
//}
//
//- (LVColl*) highestParentColl {
//    LVColl* coll = self;
//    
//    while (coll.parent.parent)
//        coll = coll.parent;
//        
//        if (coll.collType == LVCollTypeTopLevel)
//            return nil;
//        else
//            return coll;
//}
