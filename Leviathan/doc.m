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
        NSUInteger max = [raw length];
        
        LVStorage* storage = malloc(sizeof(LVStorage));
        
        storage->tokens = malloc(sizeof(LVToken) * max);
        storage->atoms = malloc(sizeof(LVAtom) * max);
        storage->colls = malloc(sizeof(LVColl) * max);
        storage->substrings = malloc(sizeof(CFStringRef) * max);
        
        storage->tokenCount = 0;
        storage->atomCount = 0;
        storage->collCount = 0;
        storage->substringCount = 0;
        
        storage->wholeString = (__bridge_retained CFStringRef)raw;
        doc->storage = storage;
        doc->firstToken = LVLex(storage);
        doc->topLevelColl = LVParseTokens(storage, doc->firstToken);
        return doc;
    }
    @catch (LVParseError *exception) {
        return nil;
    }
}

void LVDocDestroy(LVDoc* doc) {
    if (!doc)
        return;
    
    CFRelease(doc->storage->wholeString);
    
    for (int i = 0; i < doc->storage->substringCount; i++) {
        CFStringRef ss = doc->storage->substrings[i];
        CFRelease(ss);
    }
    
    free(doc->storage->tokens);
    free(doc->storage->atoms);
    free(doc->storage->colls);
    free(doc->storage->substrings);
    
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
