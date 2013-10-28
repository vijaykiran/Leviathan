//
//  configs.m
//  Leviathan
//
//  Created by Steven Degutis on 10/24/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "configs.h"

#import "BMOEDNSerialization.h"
#import "BMOEDNKeyword.h"

static id fix(id thing) {
    if ([thing isKindOfClass:[NSArray self]]) {
        NSMutableArray* array = [NSMutableArray array];
        for (id child in thing) {
            [array addObject: fix(child)];
        }
        return array;
    }
    if ([thing isKindOfClass:[NSDictionary self]]) {
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        for (id key in thing) {
            id val = [thing objectForKey: key];
            [dict setObject:fix(val) forKey:fix(key)];
        }
        return dict;
    }
    else if ([thing isKindOfClass:[BMOEDNKeyword self]]) {
        return [thing name];
    }
    else {
        return thing;
    }
}

id LVParseConfigFromString(NSString* str) {
    NSData* data = [str dataUsingEncoding:NSUTF8StringEncoding];
    id config = [BMOEDNSerialization ednObjectWithData:data options:0 error:NULL];
    config = fix(config);
    return config;
}
