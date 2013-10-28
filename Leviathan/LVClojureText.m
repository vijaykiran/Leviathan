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

@end

@implementation LVClojureText

- (id) initWithString:(NSString *)str {
    if (self = [super init]) {
        self.internalStorage = [[NSMutableAttributedString alloc] initWithString: str];
        [self parse];
    }
    return self;
}

- (void) parse {
    if (self.topLevelElement)
        LVCollDestroy(self.topLevelElement);
    
    self.topLevelElement = LVParse([[self string] UTF8String]);
}

- (NSString*) string {
    return [self.internalStorage string];
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)aRange {
    return [[LVHighlighter sharedHighlighter] attributesForTree:self.topLevelElement
                                                     atPosition:index
                                                 effectiveRange:aRange];
    
    /* TODO: new plan
     *
     * 1. Store flat list of tokens (next to the tree). We already build it, just keep it around.
     * 2. Token points to its one-and-only Atom.
     * 3. Coll's opening and closing token should be children of the coll!
     * 4. Cache token's absolute position.
     * 5. Rebuild the "Doc" at every change: they're throw-aways.
     *
     */
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
