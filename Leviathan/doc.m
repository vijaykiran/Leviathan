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

LVDoc* LVDocCreate(const char* raw) {
    LVDoc* doc = malloc(sizeof(LVDoc));
    doc->string = bfromcstr(raw);
    doc->tokens = LVLex(doc->string, &doc->tokens_len);
    doc->topLevelColl = LVParseTokens(doc->tokens);
    return doc;
}

void LVDocDestroy(LVDoc* doc) {
    if (!doc)
        return;
    
    LVCollDestroy(doc->topLevelColl);
    bdestroy(doc->string);
    free(doc->tokens);
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
    LVFindDefinitionsFromColl(doc->topLevelColl, defs);
}

//LVAtom* LVFindAtom(LVDoc* doc, size_t pos) {
//    LVToken** iter = doc->tokens + 1;
//    for (int i = 1; i < doc->tokens_len; i++) {
//        LVToken* tok = *iter++;
//        if (pos >= tok->pos && pos < tok->pos + tok->string->slen)
//            return tok->atom;
//    }
//    abort();
//}
