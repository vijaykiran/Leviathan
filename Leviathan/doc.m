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
        doc->first_token = LVLex(doc->string);
        doc->top_level_coll = LVParseTokens(doc->first_token);
        return doc;
    }
    @catch (LVParseError *exception) {
        return nil;
    }
}

void LVDocDestroy(LVDoc* doc) {
    if (!doc)
        return;
    
    LVCollDestroy(doc->top_level_coll);
    CFRelease(doc->string);
    free(doc);
}

static void LVFindDefinitionsFromColl(LVColl* coll, NSMutableArray* defs) {
    for (int i = 0; i < coll->children_len; i++) {
        LVColl* child = (void*)coll->children[i];
        
        if (child->is_atom)
            continue;
        
        if (child->coll_type & LVCollType_Definition) {
            LVDefinition* def = [[LVDefinition alloc] init];
            
            for (int ii = 0; ii < child->children_len; ii++) {
                LVAtom* grandchild = (void*)child->children[ii];
                
                if (!grandchild->is_atom)
                    continue;
                
                if (grandchild->atom_type & LVAtomType_DefType) {
                    def.defType = grandchild;
                    continue;
                }
                
                if (grandchild->atom_type & LVAtomType_DefName) {
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
    LVFindDefinitionsFromColl(doc->top_level_coll, defs);
}











// questionable but in-use

LVAtom* LVFindAtomFollowingIndex(LVDoc* doc, size_t pos) {
    LVToken* tok = doc->first_token->nextToken;
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
    
    LVElement* semanticChildren[parent->children_len];
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
    for (LVToken* tok = doc->first_token->nextToken; tok; tok = tok->nextToken) {
        if (pos >= tok->pos + 1 && pos <= tok->pos + CFStringGetLength(tok->string))
            return tok->atom;
    }
    return NULL;
}
