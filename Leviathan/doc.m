//
//  doc.m
//  Leviathan
//
//  Created by Steven on 10/27/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "doc.h"

#import "lexer.h"
#import "parser.h"

#import "LVParseError.h"

LVDoc* LVDocCreate(NSString* raw) {
    @try {
        LVDoc* doc = malloc(sizeof(LVDoc));
        doc->string = (__bridge_retained CFStringRef)raw;
        doc->firstToken = LVLex(doc->string);
        doc->topLevelColl = LVParseTokens(doc->firstToken);
        return doc;
    }
    @catch (LVParseError *exception) {
        return nil;
    }
}

void LVDocDestroy(LVDoc* doc) {
    if (!doc)
        return;
    
    LVCollDestroy(doc->topLevelColl);
    CFRelease(doc->string);
    free(doc);
}

static void LVFindDefinitionsFromColl(LVColl* coll, NSMutableArray* defs) {
    for (int i = 0; i < coll->childrenLen; i++) {
        LVColl* child = (void*)coll->children[i];
        
        if (child->isAtom)
            continue;
        
        if (child->collType & LVCollType_Definition) {
            LVDefinition* def = [[LVDefinition alloc] init];
            
            for (int ii = 0; ii < child->childrenLen; ii++) {
                LVAtom* grandchild = (void*)child->children[ii];
                
                if (!grandchild->isAtom)
                    continue;
                
                if (grandchild->atomType & LVAtomType_DefType) {
                    def.defType = grandchild;
                    continue;
                }
                
                if (grandchild->atomType & LVAtomType_DefName) {
                    def.defName = grandchild;
                    break;
                }
            }
            
            [defs addObject: def];
        }
        
        LVFindDefinitionsFromColl(child, defs);
    }
}

void LVFindDefinitions(LVDoc* doc, NSMutableArray* defs) {
    LVFindDefinitionsFromColl(doc->topLevelColl, defs);
}











// questionable but in-use

LVAtom* LVFindAtomFollowingIndex(LVDoc* doc, size_t pos) {
    LVToken* tok = doc->firstToken->nextToken;
    for (; tok->nextToken; tok = tok->nextToken) {
        if (pos >= tok->pos && pos < tok->pos + CFStringGetLength(tok->string))
            return tok->atom;
    }
    return tok->atom;
}

LVColl* LVFindElementAtPosition(LVDoc* doc, size_t pos, size_t* childIndex) {
    LVAtom* atom = LVFindAtomFollowingIndex(doc, pos);
    
    LVElement* el = (void*)atom;
    if (el == atom->parent->children[0])
        el = (void*)atom->parent;
    
    *childIndex = LVGetElementIndexInSiblings(el);
    return el->parent;
}

LVElement* LVFindNextSemanticChildStartingAt(LVDoc* doc, size_t idx) {
    size_t childIndex;
    LVColl* parent = LVFindElementAtPosition(doc, idx, &childIndex);
    
    LVElement* semanticChildren[parent->childrenLen];
    size_t semanticChildrenCount;
    LVGetSemanticDirectChildren(parent, childIndex, semanticChildren, &semanticChildrenCount);
    
    for (int i = 0; i < semanticChildrenCount; i++) {
        LVElement* semanticChild = semanticChildren[i];
        
        size_t posAfterElement = LVGetAbsolutePosition(semanticChild) + LVElementLength(semanticChild);
        
        // are we in the middle of the semantic element?
        // if so, great! we'll use this one
        if (idx < posAfterElement)
            return semanticChild;
    }
    return NULL;
}





















// new and good

// returns the atom where (cursor >= atom.pos + 1) and (cursor <= atom.pos + atom.length), or NULL if pos = 0
LVAtom* LVFindAtomPrecedingIndex(LVDoc* doc, NSUInteger pos) {
    for (LVToken* tok = doc->firstToken->nextToken; tok; tok = tok->nextToken) {
        if (pos >= tok->pos + 1 && pos <= tok->pos + CFStringGetLength(tok->string))
            return tok->atom;
    }
    return NULL;
}
