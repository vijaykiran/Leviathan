//
//  LVClojureText.m
//  Leviathan
//
//  Created by Steven Degutis on 10/27/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVClojureText.h"

@interface LVClojureText ()

@property NSMutableAttributedString* internalStorage;

@end

@implementation LVClojureText

- (id) initWithString:(NSString *)str {
    if (self = [super init]) {
        self.internalStorage = [[NSMutableAttributedString alloc] initWithString: str];
    }
    return self;
}

- (NSString*) string {
    return [self.internalStorage string];
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)aRange {
    if (aRange) {
        aRange->location = 0;
        aRange->length = self.string.length;
    }
    return @{NSForegroundColorAttributeName: [NSColor redColor], NSFontAttributeName: [NSFont fontWithName:@"Arial" size:15]};
}

- (void)replaceCharactersInRange:(NSRange)aRange withString:(NSString *)aString {
    NSUInteger origLen = [self length];
    [self.internalStorage replaceCharactersInRange:(NSRange)aRange withString:(NSString *)aString];
    [self edited:NSTextStorageEditedCharacters range:aRange changeInLength:[self length] - origLen];
}

- (void)setAttributes:(NSDictionary *)attributes range:(NSRange)aRange {
    [self.internalStorage setAttributes:(NSDictionary *)attributes range:(NSRange)aRange];
    [self edited:NSTextStorageEditedAttributes range:aRange changeInLength:0];
}

@end
