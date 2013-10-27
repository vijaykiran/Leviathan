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

// NSFontAttributeName: [LVPreferences userFont]

- (NSString*) string {
    return [self.internalStorage string];
}

- (NSDictionary *)attributesAtIndex:(NSUInteger)index effectiveRange:(NSRangePointer)aRange {
    return [[LVHighlighter sharedHighlighter] attributesForTree:self.topLevelElement
                                                     atPosition:index
                                                 effectiveRange:aRange];
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
