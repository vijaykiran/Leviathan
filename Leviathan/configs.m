//
//  configs.m
//  Leviathan
//
//  Created by Steven Degutis on 10/24/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "configs.h"

#import "parser.h"
#import "atom.h"

id LVContainerFromColl(LVColl* coll);

id LVSingleFromAtom(LVAtom* atom) {
    if (atom->atom_type & LVAtomType_Keyword) {
        struct tagbstring kw_val;
        bmid2tbstr(kw_val, atom->token->string, 1, atom->token->string->slen - 1);
        return [NSString stringWithFormat:@"%s", kw_val.data];
    }
    else if (atom->atom_type & LVAtomType_TrueAtom) { 
        return @YES;
    }
    else if (atom->atom_type & LVAtomType_FalseAtom) {
        return @NO;
    }
    else if (atom->atom_type & LVAtomType_String) {
        bstring kw_val = bmidstr(atom->token->string, 1, atom->token->string->slen - 2);
        id s = [NSString stringWithFormat:@"%s", kw_val->data];
        bdestroy(kw_val);
        return s;
    }
    abort();
}

NSArray* LVArrayFromColl(LVColl* list) {
    NSMutableArray* array = [NSMutableArray array];
    
    for (int i = 1; i < list->children_len; i++) {
        LVElement* child = list->children[i];
        
        id found;
        
        if (child->is_atom) {
            LVAtom* atom = (void*)child;
            
            if (!LVAtomIsSemantic(atom))
                continue;
            
            found = LVSingleFromAtom(atom);
        }
        else {
            found = LVContainerFromColl((void*)child);
        }
        
        [array addObject: found];
    }
    
    return array;
}

NSDictionary* LVDictionaryFromColl(LVColl* map) {
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    
    id key;
    
    for (int i = 1; i < map->children_len; i++) {
        LVElement* child = map->children[i];
        
        id found;
        
        if (child->is_atom) {
            LVAtom* atom = (void*)child;
            
            if (!LVAtomIsSemantic(atom))
                continue;
            
            found = LVSingleFromAtom(atom);
        }
        else {
            found = LVContainerFromColl((void*)child);
        }
        
        if (!key) {
            key = found;
        }
        else {
            [dict setObject:found forKey:key];
            key = nil;
        }
    }
    
    return dict;
}

id LVContainerFromColl(LVColl* coll) {
    if (coll->coll_type & LVCollType_Map)
        return LVDictionaryFromColl(coll);
    else if (coll->coll_type & LVCollType_Vector)
        return LVArrayFromColl(coll);
    
    abort();
}

id LVParseConfigFromString(NSString* str) {
    LVColl* coll = LVParse([str UTF8String]);
    NSDictionary* configs = LVContainerFromColl((void*)coll->children[1]);
    LVCollDestroy(coll);
    return configs;
}
