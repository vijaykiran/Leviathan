//
//  LVThemeManager.m
//  Leviathan
//
//  Created by Steven on 10/18/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVThemeManager.h"

#import "parser.h"
#import "atom.h"

id LVContainerFromColl(LVColl* coll);

BOOL LVAtomIsSemantic(LVAtom* atom) { // TODO: this is generally useful, move it somewhere appropriate
    return !((atom->atom_type & LVAtomType_Comma)
             || (atom->atom_type & LVAtomType_Newline)
             || (atom->atom_type & LVAtomType_Comment)
             || (atom->atom_type & LVAtomType_Spaces));
}

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
    
    for (int i = 0; i < list->children_len; i++) {
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
    
    for (int i = 0; i < map->children_len; i++) {
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



@interface LVThemeManager ()
@end

@implementation LVThemeManager

+ (LVThemeManager*) sharedThemeManager {
    static LVThemeManager* sharedThemeManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedThemeManager = [[LVThemeManager alloc] init];
    });
    return sharedThemeManager;
}

- (void) loadThemes {
    [self copyDefaultThemeMaybe];
    [self loadCurrentTheme];
}

- (NSURL*) currentThemeFile {
    NSError *error;
    NSURL *appSupportDir = [[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory
                                                                  inDomain:NSUserDomainMask
                                                         appropriateForURL:nil
                                                                    create:YES
                                                                     error:&error];
    
    NSURL* dataDirURL = [[appSupportDir URLByAppendingPathComponent:@"Leviathan"] URLByAppendingPathComponent:@"Themes"];
    
    [[NSFileManager defaultManager] createDirectoryAtURL:dataDirURL
                             withIntermediateDirectories:YES
                                              attributes:nil
                                                   error:NULL];
    
    return [dataDirURL URLByAppendingPathComponent:@"CURRENT_THEME.clj"];
}

- (void) copyFileOrElse:(NSURL*)from to:(NSURL*)to {
    NSError*__autoreleasing error;
    if (![[NSFileManager defaultManager] copyItemAtURL:from toURL:to error:&error]) {
        [NSApp presentError:error];
        [NSApp terminate:self];
        return;
    }
}

- (void) copyDefaultThemeMaybe {
    NSURL* currentThemeInAppSupport = [self currentThemeFile];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[currentThemeInAppSupport path]]) {
        NSURL* defaultThemeInBundle = [[NSBundle mainBundle] URLForResource:@"default_leviathan_theme" withExtension:@"clj"];
        
        [self copyFileOrElse:defaultThemeInBundle to:currentThemeInAppSupport];
        [self copyFileOrElse:defaultThemeInBundle to:[[currentThemeInAppSupport URLByDeletingLastPathComponent] URLByAppendingPathComponent:@"DefaultTheme.clj"]];
    }
}

- (void) loadCurrentTheme {
    NSData* data = [NSData dataWithContentsOfURL:[self currentThemeFile]];
    NSString* str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    LVColl* coll = LVParse([str UTF8String]);
    NSDictionary* themeData = LVDictionaryFromColl((void*)coll->children[0]);
    NSLog(@"%@", themeData);
    LVCollDestroy(coll);
    
    self.currentTheme = [LVTheme themeFromData:themeData];
}

@end
