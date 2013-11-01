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

//#include <sys/time.h>
//#include <sys/resource.h>
//
//double get_time() {
//    struct timeval t;
//    struct timezone tzp;
//    gettimeofday(&t, &tzp);
//    return t.tv_sec + t.tv_usec*1e-6;
//}

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

- (BOOL) validateStringCanParse:(NSString*)string {
    LVDoc* tempDoc = LVDocCreate(string);
    LVDocDestroy(tempDoc);
    return tempDoc != nil;
}

- (void) parse {
    free(self.highlights);
    self.highlights = NULL;
    
//    double T1 = get_time();
    
    LVDocDestroy(self.doc);
    self.doc = LVDocCreate([self string]);
    
//    double T2 = get_time();
//    printf("%f\n", T2-T1);
    
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
    NSMutableString* tryString = [self.internalStorage mutableCopy];
    [tryString replaceCharactersInRange:aRange withString:aString];
    if ([self validateStringCanParse:tryString]) {
        NSUInteger origLen = [self length];
        [self.internalStorage replaceCharactersInRange:aRange withString:aString];
        NSUInteger newLen = [self length];
        [self parse];
        [self edited:NSTextStorageEditedCharacters range:aRange changeInLength:(newLen - origLen)];
    }
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
