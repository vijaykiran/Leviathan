//
//  LVClojureText.m
//  Leviathan
//
//  Created by Steven Degutis on 10/27/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVClojureText.h"

#import "parser.h"
#import "LVHighlighter.h"

@interface LVClojureText ()

@property NSMutableAttributedString* internalStorage;
@property LVHighlights* highlights;

@end

@implementation LVClojureText

- (id) initWithString:(NSString *)str {
    if (self = [super init]) {
        self.internalStorage = [[NSMutableAttributedString alloc] initWithString: str];
        [self parse];
    }
    return self;
}

- (void) dealloc {
    free(self.highlights);
    LVDocDestroy(self.doc);
}

- (void) parse {
    free(self.highlights);
    self.highlights = NULL;
    
    LVDocDestroy(self.doc);
    self.doc = LVDocCreate([[self string] UTF8String]);
    
    self.highlights = LVHighlightsForDoc(self.doc);
}

- (NSString*) string {
    return [self.internalStorage string];
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)aRange {
    LVHighlights* h = &self.highlights[index];
    
    if (!h->attrs)
        h->attrs = LVAttributesForAtom(h->atom);
    
    if (aRange) {
        aRange->location = h->pos;
        aRange->length = h->len;
    }
    
    return h->attrs;
}

- (void)replaceCharactersInRange:(NSRange)aRange withString:(NSString *)aString {
    NSUInteger origLen = [self length];
    [self.internalStorage replaceCharactersInRange:(NSRange)aRange withString:(NSString *)aString];
    [self edited:NSTextStorageEditedCharacters range:aRange changeInLength:[self length] - origLen];
    
    [self parse];
}

- (void)setAttributes:(NSDictionary *)attributes range:(NSRange)aRange {
    [self.internalStorage setAttributes:(NSDictionary *)attributes range:(NSRange)aRange];
    [self edited:NSTextStorageEditedAttributes range:aRange changeInLength:0];
}

@end
