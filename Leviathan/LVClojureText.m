//
//  LVClojureText.m
//  Leviathan
//
//  Created by Steven Degutis on 10/27/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVClojureText.h"

#import "LVThemeManager.h"

#import "parser.h"
#import "highlights.h"

@interface LVClojureText ()

@property NSMutableString* internalStorage;
@property LVHighlights* highlights;

@end

@implementation LVClojureText

- (id) initWithString:(NSString *)str {
    if (self = [super init]) {
        self.undoManager = [[NSUndoManager alloc] init];
        self.internalStorage = [[NSMutableString alloc] initWithString: str];
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
    self.doc = LVDocCreate([self string]);
    
    self.highlights = LVHighlightsForDoc(self.doc);
}

- (NSString*) string {
    return self.internalStorage;
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)aRange {
    assert(self.highlights != NULL);
    
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
    [self parse];
    [self edited:NSTextStorageEditedCharacters range:aRange changeInLength:[self length] - origLen];
    
//    bstring s = bfromcstr([self.internalStorage UTF8String]);
//    NSLog(@"[%@], %ld, %u", self.internalStorage, [self.internalStorage length], [self.internalStorage characterAtIndex:0]);
//    NSLog(@"[%s], %d, %u, %u", s->data, s->slen, s->data[0], s->data[1]);
}

- (void)setAttributes:(NSDictionary *)attributes range:(NSRange)aRange {
    // lol, no.
}

- (void) rehighlight {
    free(self.highlights);
    self.highlights = NULL;
    
    [[LVThemeManager sharedThemeManager] loadThemes];
    self.highlights = LVHighlightsForDoc(self.doc);
    
    [self edited:NSTextStorageEditedAttributes range:NSMakeRange(0, [self.internalStorage length]) changeInLength:0];
}

@end
