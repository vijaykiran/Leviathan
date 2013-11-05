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
    LVDoc* doc = malloc(sizeof(LVDoc));
    LVStorage* storage = malloc(sizeof(LVStorage));
    
    NSUInteger max = ([raw length] + 2);
    storage->tokens = malloc(sizeof(LVToken) * max);
    storage->atoms = malloc(sizeof(LVAtom) * max);
    storage->colls = malloc(sizeof(LVColl) * max / 2);
    
    storage->tokenCount = 0;
    storage->atomCount = 0;
    storage->collCount = 0;
    
    storage->wholeString = (__bridge_retained CFStringRef)raw;
    doc->storage = storage;
    
    @try {
        doc->firstToken = LVLex(storage);
        doc->topLevelColl = LVParseTokens(storage, doc->firstToken);
    }
    @catch (LVParseError *exception) {
        LVDocDestroy(doc);
        return NULL;
    }
    
    return doc;
}

void LVDocDestroy(LVDoc* doc) {
    if (!doc)
        return;
    
    CFRelease(doc->storage->wholeString);
    
    for (int i = 0; i < doc->storage->tokenCount; i++) {
        CFStringRef s = doc->storage->tokens[i].string;
        CFRelease(s);
    }
    
    for (int i = 0; i < doc->storage->collCount; i++) {
        LVColl coll = doc->storage->colls[i];
        free(coll.children);
    }
    
    free(doc->storage->tokens);
    free(doc->storage->atoms);
    free(doc->storage->colls);
    
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

LVAtom* LVFindAtomFollowingIndex(LVDoc* doc, NSUInteger pos) {
    LVToken* tok = doc->firstToken->nextToken;
    for (; tok->nextToken; tok = tok->nextToken) {
        if (pos >= tok->pos && pos < tok->pos + CFStringGetLength(tok->string))
            return tok->atom;
    }
    return tok->atom;
}

LVColl* LVFindElementAtPosition(LVDoc* doc, NSUInteger pos, NSUInteger* childIndex) {
    LVAtom* atom = LVFindAtomFollowingIndex(doc, pos);
    
    LVElement* el = (void*)atom;
    if (el == atom->parent->children[0])
        el = (void*)atom->parent;
    
    *childIndex = LVGetElementIndexInSiblings(el);
    return el->parent;
}

LVElement* LVFindNextSemanticChildStartingAt(LVDoc* doc, NSUInteger idx) {
    NSUInteger childIndex;
    LVColl* parent = LVFindElementAtPosition(doc, idx, &childIndex);
    
    LVElement* semanticChildren[parent->childrenLen];
    NSUInteger semanticChildrenCount;
    LVGetSemanticDirectChildren(parent, childIndex, semanticChildren, &semanticChildrenCount);
    
    for (int i = 0; i < semanticChildrenCount; i++) {
        LVElement* semanticChild = semanticChildren[i];
        
        NSUInteger posAfterElement = LVGetAbsolutePosition(semanticChild) + LVElementLength(semanticChild);
        
        // are we in the middle of the semantic element?
        // if so, great! we'll use this one
        if (idx < posAfterElement)
            return semanticChild;
    }
    return NULL;
}





















// new and good

// returns the atom where (cursor >= atom.pos + 1) and (cursor <= atom.pos + atom.length), or the first token's atom if pos = 0
LVAtom* LVFindAtomPrecedingIndex(LVDoc* doc, NSUInteger pos) {
    for (LVToken* tok = doc->firstToken->nextToken; tok; tok = tok->nextToken) {
        if (pos >= tok->pos + 1 && pos <= tok->pos + CFStringGetLength(tok->string))
            return tok->atom;
    }
    return doc->firstToken->atom;
}
