//
//  LVClojureText.m
//  Leviathan
//
//  Created by Steven Degutis on 10/27/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVClojureTextStorage.h"

#import "LVThemeManager.h"

#import "parser.h"
#import "highlights.h"

@interface LVClojureTextStorage ()

@property NSMutableString* internalStorage;
@property LVHighlights* highlights;

@property BOOL parsingEnabled;

@end

#include <sys/time.h>
#include <sys/resource.h>

#define PRINT_PARSE_TIMES ( NO )
double get_time() { struct timeval t; struct timezone tzp; gettimeofday(&t, &tzp); return t.tv_sec + t.tv_usec*1e-6; }

@implementation LVClojureTextStorage

- (id) initWithString:(NSString *)str {
    if (self = [super init]) {
        self.undoManager = [[NSUndoManager alloc] init];
        self.internalStorage = [[NSMutableString alloc] initWithString: str];
        self.parsingEnabled = YES;
        [self parse];
    }
    return self;
}

- (void) dealloc {
    free(self.highlights);
    LVDocDestroy(self.doc);
}

- (void) parse {
    free(self.highlights), self.highlights = NULL;
    
    LVDocDestroy(self.doc);
    double T1 = get_time();
    self.doc = LVDocCreate(self.internalStorage);
    double T2 = get_time();
    if (PRINT_PARSE_TIMES) printf("%f\n", T2-T1);
    
    if (self.doc)
        self.highlights = LVHighlightsForDoc(self.doc);
    else
        printf("dang: can't parse.\n");
}

- (NSString*) string {
    return self.internalStorage;
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)aRange {
    if (self.highlights == NULL) {
        if (aRange) {
            aRange->location = 0;
            aRange->length = [self length];
        }
        return [LVThemeManager sharedThemeManager].currentTheme.symbol;
    }
    
    LVHighlights* h = &self.highlights[index];
    
    assert(h->atom != NULL);
    if (!h->attrs) {
        h->attrs = LVAttributesForAtom(h->atom);
    }
    
    if (aRange) {
        aRange->location = h->pos;
        aRange->length = h->len;
    }
    
    return h->attrs;
}

- (void)replaceCharactersInRange:(NSRange)aRange withString:(NSString *)aString {
//    NSLog(@"replacing chars");
    NSUInteger origLen = [self length];
    [self.internalStorage replaceCharactersInRange:aRange withString:aString];
    NSUInteger newLen = [self length];
    
    if (self.parsingEnabled) {
        LVDoc* oldDoc = self.doc;
        [self parse];
        
        if ((oldDoc == NULL && self.doc != NULL) || (oldDoc != NULL && self.doc == NULL)) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self edited:NSTextStorageEditedAttributes
                       range:NSMakeRange(0, [self.internalStorage length])
              changeInLength:0];
            });
        }
    }
    
    [self edited:NSTextStorageEditedCharacters range:aRange changeInLength:(newLen - origLen)];
}

- (void) withDisabledParsing:(void(^)())blk {
    free(self.highlights), self.highlights = NULL;
    
    self.parsingEnabled = NO;
    blk();
    self.parsingEnabled = YES;
    [self parse];
}

- (void)setAttributes:(NSDictionary *)attributes range:(NSRange)aRange {
    // lol, no.
}

- (void) rehighlight {
    free(self.highlights);
    self.highlights = LVHighlightsForDoc(self.doc);
    
    [self edited:NSTextStorageEditedAttributes range:NSMakeRange(0, [self.internalStorage length]) changeInLength:0];
}

@end
