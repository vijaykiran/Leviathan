//
//  LVTextView.m
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVTextView.h"

#import "atom.h"
#import "element.h"

#import "LVThemeManager.h"
#import "LVPreferences.h"






@interface LVShortcut : NSObject
@property SEL action;
@property NSString* title;
@property NSString* keyEquiv;
@property NSArray* mods;
@end

@implementation LVShortcut
@end






@interface LVTextView ()
@property NSMutableArray* shortcuts;
@end


@implementation LVTextView

- (BOOL) becomeFirstResponder {
    BOOL did = [super becomeFirstResponder];
    if (did) {
        [self.customDelegate textViewWasFocused:self];
    }
    return did;
}

- (void) awakeFromNib {
    [self setupNiceties];
    [self setupShortcuts];
}

- (void) setupNiceties {
    self.enclosingScrollView.verticalScroller.knobStyle = self.enclosingScrollView.horizontalScroller.knobStyle = NSScrollerKnobStyleLight;
    
    self.automaticTextReplacementEnabled = NO;
    self.automaticSpellingCorrectionEnabled = NO;
    self.automaticQuoteSubstitutionEnabled = NO;
    
    self.backgroundColor = [LVThemeManager sharedThemeManager].currentTheme.backgroundColor;
    self.insertionPointColor = [LVThemeManager sharedThemeManager].currentTheme.cursorColor;
    self.selectedTextAttributes = [LVThemeManager sharedThemeManager].currentTheme.selection;
    
    [self sd_disableLineWrapping];
    
//    [super setTextContainerInset:NSMakeSize(0.0f, 4.0f)];
}

- (void) setupShortcuts {
    self.shortcuts = [NSMutableArray array];
    
    [self addShortcut:@selector(raiseSexp:) title:@"Raise" keyEquiv:@"r" mods:@[@"ALT"]];
    [self addShortcut:@selector(killNextSexp:) title:@"Kill Next" keyEquiv:@"k" mods:@[@"CTRL", @"ALT"]];
    [self addShortcut:@selector(spliceSexp:) title:@"Splice" keyEquiv:@"s" mods:@[@"ALT"]];
    
    [self addShortcut:@selector(backwardSexp:) title:@"Backward" keyEquiv:@"b" mods:@[@"CTRL", @"ALT"]];
    [self addShortcut:@selector(forwardSexp:) title:@"Forward" keyEquiv:@"f" mods:@[@"CTRL", @"ALT"]];
    [self addShortcut:@selector(inForwardSexp:) title:@"In Forward" keyEquiv:@"d" mods:@[@"CTRL", @"ALT"]];
    [self addShortcut:@selector(inBackwardSexp:) title:@"In Backward" keyEquiv:@"p" mods:@[@"CTRL", @"ALT"]];
    [self addShortcut:@selector(outBackwardSexp:) title:@"Out Backward" keyEquiv:@"u" mods:@[@"CTRL", @"ALT"]];
    [self addShortcut:@selector(outForwardSexp:) title:@"Out Forward" keyEquiv:@"n" mods:@[@"CTRL", @"ALT"]];
    
    [self addShortcut:@selector(extendSelectionToNext:) title:@"Extend Seletion to Next" keyEquiv:@" " mods:@[@"CTRL", @"ALT"]];
    
    [self addShortcut:@selector(wrapNextInParens:) title:@"Wrap Next in Parens" keyEquiv:@"9" mods:@[@"CTRL"]];
    [self addShortcut:@selector(wrapNextInBrackets:) title:@"Wrap Next in Brackets" keyEquiv:@"[" mods:@[@"CTRL"]];
    [self addShortcut:@selector(wrapNextInBraces:) title:@"Wrap Next in Braces" keyEquiv:@"{" mods:@[@"CTRL"]];
    
    [self addShortcut:@selector(jumpToNextBlankLineGroup:) title:@"Jump to Next Blank Line" keyEquiv:@"}" mods:@[@"ALT"]];
    [self addShortcut:@selector(jumpToPreviousBlankLineGroup:) title:@"Jump to Previous Blank Line" keyEquiv:@"{" mods:@[@"ALT"]];
}


- (void) sd_disableLineWrapping {
    [[self enclosingScrollView] setHasHorizontalScroller:YES];
    [self setHorizontallyResizable:YES];
    NSSize layoutSize = [self maxSize];
    layoutSize.width = layoutSize.height;
    [self setMaxSize:layoutSize];
    [[self textContainer] setWidthTracksTextView:NO];
    [[self textContainer] setContainerSize:layoutSize];
}


- (void) addShortcut:(SEL)action title:(NSString*)title keyEquiv:(NSString*)keyEquiv mods:(NSArray*)mods {
    LVShortcut* shortcut = [[LVShortcut alloc] init];
    shortcut.title = title;
    shortcut.keyEquiv = keyEquiv;
    shortcut.action = action;
    shortcut.mods = mods;
    [self.shortcuts addObject:shortcut];
    
//    NSMenu* menu = [[[NSApp menu] itemWithTitle:@"Paredit"] submenu];
//    NSMenuItem* item = [menu insertItemWithTitle:shortcut.title action:shortcut.action keyEquivalent:shortcut.keyEquiv atIndex:0];
//    NSUInteger realMods = 0;
//    if ([mods containsObject:@"CTRL"]) realMods |= NSControlKeyMask;
//    if ([mods containsObject:@"ALT"]) realMods |= NSAlternateKeyMask;
//    [item setKeyEquivalentModifierMask:realMods];
}

- (void) keyDown:(NSEvent *)theEvent {
    if (!self.clojureTextStorage.doc) {
        [super keyDown:theEvent];
        return;
    }
    
    for (LVShortcut* shortcut in self.shortcuts) {
        if (![[theEvent charactersIgnoringModifiers] isEqualToString: shortcut.keyEquiv])
            continue;
        
        NSMutableArray* needs = [NSMutableArray array];
        
        if ([theEvent modifierFlags] & NSControlKeyMask) [needs addObject:@"CTRL"];
        if ([theEvent modifierFlags] & NSAlternateKeyMask) [needs addObject:@"ALT"];
        
        if (![needs isEqualToArray: shortcut.mods])
            continue;
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self performSelector:shortcut.action
                   withObject:theEvent];
#pragma clang diagnostic pop
        
        return;
    }
    
    [super keyDown:theEvent];
}

- (void) mouseDown:(NSEvent *)theEvent {
    if (!self.clojureTextStorage.doc) {
        [super mouseDown:theEvent];
        return;
    }
    
    if ([theEvent clickCount] == 2) {
        NSPoint p = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        NSUInteger i1 = [self.layoutManager glyphIndexForPoint:p inTextContainer:self.textContainer];
        NSUInteger idx = [self.layoutManager characterIndexForGlyphAtIndex:i1];
        
        LVAtom* atom = LVFindAtomFollowingIndex(self.clojureTextStorage.doc, idx);
        
        if (atom->atomType & LVAtomType_CollDelim) {
            NSUInteger start;
            NSUInteger end;
            if (atom->atomType & LVAtomType_CollCloser) {
                end = atom->token->pos;
                LVAtom* startAtom = (LVAtom*)atom->parent->children[0];
                start = startAtom->token->pos;
            }
            else {
                start = atom->token->pos;
                LVAtom* endAtom = (LVAtom*)atom->parent->children[atom->parent->childrenLen - 1];
                end = endAtom->token->pos;
            }
            NSRange r = NSMakeRange(start, end - start + 1);
            self.selectedRange = r;
        }
        else {
            [super mouseDown: theEvent];
        }
    }
    else {
        [super mouseDown: theEvent];
    }
}

- (IBAction) cancelOperation:(id)sender {
    self.selectedRange = NSMakeRange(self.selectedRange.location, 0);
}

//- (void) replaceCharactersInRange:(NSRange)range withString:(NSString *)aString {
//    NSLog(@"bla");
//}



/************************************************ Helper Functions ************************************************/

// not sure how generally useful these are yet

LVColl* LVFindNextCollOnOrAfterPosition(LVDoc* doc, NSUInteger pos) {
    size_t childIndex;
    LVColl* parent = LVFindElementAtPosition(doc, pos, &childIndex);
    
    for (size_t i = childIndex; i < parent->childrenLen; i++) {
        LVColl* maybeColl = (LVColl*)parent->children[i];
        
        if (!maybeColl->isAtom)
            return maybeColl;
    }
    
    return NULL;
}

LVColl* LVFindNextCollBeforePosition(LVDoc* doc, NSUInteger pos) {
    size_t childIndex;
    LVColl* parent = LVFindElementAtPosition(doc, pos, &childIndex);
    
    for (size_t i = childIndex - 1; i >= 1; i--) {
        LVColl* maybeColl = (LVColl*)parent->children[i];
        
        if (!maybeColl->isAtom)
            return maybeColl;
    }
    
    return NULL;
}

LVElement* LVFindNextSemanticElementStartingAtPosition(LVDoc* doc, NSUInteger pos) {
    size_t childIndex;
    LVColl* parent = LVFindElementAtPosition(doc, pos, &childIndex);
    
    for (size_t i = childIndex; i < parent->childrenLen; i++) {
        LVElement* element = parent->children[i];
        
        if (LVElementIsSemantic(element))
            return element;
    }
    
    return NULL;
}

LVAtom* LVCollOpenerAtom(LVColl* coll) {
    return (LVAtom*)coll->children[0];
}

LVAtom* LVCollCloserAtom(LVColl* coll) {
    return (LVAtom*)coll->children[coll->childrenLen - 1];
}

NSRange LVElementRange(LVElement* element) {
    return NSMakeRange(LVGetAbsolutePosition(element), LVElementLength(element));
}






/************************************************ Indentation ************************************************/

// TODO: instead of overriding every method ever, maybe we can indent inside -[LVClojureText replaceCharactersInRange:withString:]?
//       but that would enter an infinite loop. hmm, i dunno.

//- (void) insertNewline:(id)sender {
//    [super insertNewline:sender];
//    [self indentCurrentBody];
//}
//
//- (void) deleteWordBackward:(id)sender {
//    [super deleteWordBackward:sender];
//    [self indentCurrentBody];
//}
//
//- (void) deleteBackward:(id)sender {
//    [super deleteBackward:sender];
//    [self indentCurrentBody];
//}












/************************************************ PAREDIT (editing) ************************************************/


- (void) raiseSexp:(NSEvent*)event {
    NSRange selection = self.selectedRange;
    
    LVElement* elementToRaise = LVFindNextSemanticChildStartingAt(self.clojureTextStorage.doc, selection.location);
    if (elementToRaise) {
        LVElement* child = elementToRaise;
        LVColl* parent = child->parent;
        
        if (parent->collType & LVCollType_TopLevel)
            return;
        
        size_t _absPos = LVGetAbsolutePosition(child);
        NSInteger relativeOffset = selection.location - _absPos;
        if (relativeOffset < 0) relativeOffset = 0;
        
        NSRange oldParentRange = NSMakeRange(LVGetAbsolutePosition((void*)parent), LVElementLength((void*)parent));
        NSString* newstr = (__bridge_transfer NSString*)LVStringForElement(child);
        
        NSRange newSelectionRange = self.selectedRange;
        
        [self shouldChangeTextInRange:oldParentRange replacementString:newstr];
        [self.textStorage replaceCharactersInRange:oldParentRange withString:newstr];
        [self didChangeText];
        
        newSelectionRange.location = oldParentRange.location + relativeOffset;
        self.selectedRange = newSelectionRange;
        
        [self scrollRangeToVisible:self.selectedRange];
    }
}

- (void) killNextSexp:(NSEvent*)event {
    LVElement* next = LVFindNextSemanticElementStartingAtPosition(self.clojureTextStorage.doc, self.selectedRange.location);
    if (next) {
        NSUInteger afterPos = LVGetAbsolutePosition(next) + LVElementLength(next);
        NSRange rangeToDelete = NSMakeRange(self.selectedRange.location, afterPos - self.selectedRange.location);
        
        [self shouldChangeTextInRange:rangeToDelete replacementString:@""];
        [self replaceCharactersInRange:rangeToDelete withString:@""];
        [self didChangeText];
        
        [self scrollRangeToVisible:self.selectedRange];
    }
}

- (void) deleteToEndOfParagraph:(id)sender {
    if (!self.clojureTextStorage.doc) {
        [super deleteToEndOfParagraph:sender];
        return;
    }
    
    LVElement* firstAtomToNotDelete = NULL;
    
    size_t childIndex;
    LVColl* parent = LVFindElementAtPosition(self.clojureTextStorage.doc, self.selectedRange.location, &childIndex);
    
    for (size_t i = childIndex; i < parent->childrenLen; i++) {
        LVElement* element = parent->children[i];
        
        // find either a coll-closer (and return it) or a newline (and return the next element)
        
        if (element->isAtom) {
            LVAtom* atom = (LVAtom*)element;
            
            if ((atom->atomType & LVAtomType_CollCloser) || (atom->atomType & LVAtomType_Newlines)) {
                firstAtomToNotDelete = element;
                break;
            }
        }
    }
    
    if (firstAtomToNotDelete) {
        NSUInteger lastPos = LVGetAbsolutePosition(firstAtomToNotDelete);
        if (lastPos <= self.selectedRange.location)
            lastPos = self.selectedRange.location + 1;
        
        NSRange rangeToDelete = NSMakeRange(self.selectedRange.location, lastPos - self.selectedRange.location);
        
        [self shouldChangeTextInRange:rangeToDelete replacementString:@""];
        [self replaceCharactersInRange:rangeToDelete withString:@""];
        [self didChangeText];
        
        [self scrollRangeToVisible:self.selectedRange];
    }
}

- (IBAction) spliceSexp:(id)sender {
    size_t childIndex;
    LVColl* parent = LVFindElementAtPosition(self.clojureTextStorage.doc, self.selectedRange.location, &childIndex);
    
    NSRange openerRange = LVElementRange((LVElement*)LVCollOpenerAtom(parent));
    NSRange closerRange = LVElementRange((LVElement*)LVCollCloserAtom(parent));
    
    [self shouldChangeTextInRanges:@[[NSValue valueWithRange:openerRange],
                                     [NSValue valueWithRange:closerRange]]
                replacementStrings:@[@"", @""]];
    
    [self.clojureTextStorage withDisabledParsing:^{
        [self.textStorage replaceCharactersInRange:closerRange withString:@""];
        [self.textStorage replaceCharactersInRange:openerRange withString:@""];
    }];
    
    [self didChangeText];
    
    [self scrollRangeToVisible:self.selectedRange];
}

- (void) wrapNextInThing:(NSString*)open and:(NSString*)close {
    LVElement* next = LVFindNextSemanticElementStartingAtPosition(self.clojureTextStorage.doc, self.selectedRange.location);
    if (next) {
        NSUInteger afterPos = LVGetAbsolutePosition(next) + LVElementLength(next);
        NSRange rangeToSurround = NSMakeRange(self.selectedRange.location, afterPos - self.selectedRange.location);
        
        NSRange openRange = NSMakeRange(rangeToSurround.location, 0);
        NSRange closeRange = NSMakeRange(NSMaxRange(rangeToSurround), 0);
        
        [self shouldChangeTextInRanges:@[[NSValue valueWithRange:openRange],
                                         [NSValue valueWithRange:closeRange]]
                    replacementStrings:@[open, close]];
        
        [self.clojureTextStorage withDisabledParsing:^{
            [self.textStorage replaceCharactersInRange:closeRange withString:close];
            [self.textStorage replaceCharactersInRange:openRange withString:open];
        }];
        
        [self didChangeText];
    }
}

- (void) wrapNextInBrackets:(NSEvent*)event {
    [self wrapNextInThing:@"[" and:@"]"];
}

- (void) wrapNextInBraces:(NSEvent*)event {
    [self wrapNextInThing:@"{" and:@"}"];
}

- (void) wrapNextInParens:(NSEvent*)event {
    [self wrapNextInThing:@"(" and:@")"];
}

- (void) insertText:(id)insertString {
    if (!self.clojureTextStorage.doc) {
        [super insertText:insertString];
        return;
    }
    
    LVAtom* atom = LVFindAtomPrecedingIndex(self.clojureTextStorage.doc, self.selectedRange.location);
    
    BOOL adjusted = NO;
    
    if (!atom ||
        (!(atom->atomType & LVAtomType_Comment) &&
        !(atom->atomType & LVAtomType_String) &&
        !(atom->atomType & LVAtomType_Regex)))
    {
        if ([insertString isEqualToString: @")"] || [insertString isEqualToString: @"]"] || [insertString isEqualToString: @"}"]) {
            // TODO: move to the next coll-closer, and if there's only Spaces and Newlines and Commas between it and cursor, delete them all.
            return;
        }
        
        if ([insertString isEqualToString: @"("])
            insertString = @"()", adjusted = YES;
        else if ([insertString isEqualToString: @"["])
            insertString = @"[]", adjusted = YES;
        else if ([insertString isEqualToString: @"{"])
            insertString = @"{}", adjusted = YES;
        else if ([insertString isEqualToString: @"\""])
            insertString = @"\"\"", adjusted = YES;
    }
    
    [super insertText:insertString];
    
    if (adjusted)
        [self moveBackward:nil];
}





/************************************************ PAREDIT (navigating) ************************************************/




- (void) outBackwardSexp:(NSEvent*)event {
    NSRange selection = self.selectedRange;
    
    size_t childIndex;
    LVColl* parent = LVFindElementAtPosition(self.clojureTextStorage.doc, selection.location, &childIndex);
    
    self.selectedRange = NSMakeRange(LVGetAbsolutePosition((LVElement*)parent), 0);
    [self scrollRangeToVisible:self.selectedRange];
}

- (void) outForwardSexp:(NSEvent*)event {
    NSRange selection = self.selectedRange;
    
    size_t childIndex;
    LVColl* parent = LVFindElementAtPosition(self.clojureTextStorage.doc, selection.location, &childIndex);
    
    self.selectedRange = NSMakeRange(LVGetAbsolutePosition((LVElement*)parent) + LVElementLength((LVElement*)parent), 0);
    [self scrollRangeToVisible:self.selectedRange];
}

- (void) forwardSexp:(NSEvent*)event {
    LVElement* elementToMoveToEndOf = LVFindNextSemanticChildStartingAt(self.clojureTextStorage.doc, self.selectedRange.location);
    if (elementToMoveToEndOf) {
        size_t posAfterElement = LVGetAbsolutePosition(elementToMoveToEndOf) + LVElementLength(elementToMoveToEndOf);
        self.selectedRange = NSMakeRange(posAfterElement, 0);
        [self scrollRangeToVisible:self.selectedRange];
    }
    else {
        [self outForwardSexp:event];
    }
}

- (void) backwardSexp:(NSEvent*)event {
    LVAtom* atom = LVFindAtomPrecedingIndex(self.clojureTextStorage.doc, self.selectedRange.location);
    
    // if it's a top-level-coll delim, do nothing
    if (!atom)
        return;
    
    LVElement* foundElement = NULL;
    
    // if it's a closing delim, move to beginning of that coll
    if (atom->atomType & LVAtomType_CollCloser)
        foundElement = (LVElement*)atom->parent;
    
    // otherwise, find the previous semantic atom IN ITS PARENT COLL, starting with this
    if (!foundElement)
        foundElement = LVFindPreviousSemanticElement((LVElement*)atom);
    
    if (foundElement) {
        // if you find one, move to the beginning of it
        size_t pos = LVGetAbsolutePosition(foundElement);
        self.selectedRange = NSMakeRange(pos, 0);
        [self scrollRangeToVisible:self.selectedRange];
    }
    else {
        // otherwise, move to the beginning of it. otherwise do "out backward sexp"
        [self outBackwardSexp:event];
    }
}

- (void) inForwardSexp:(NSEvent*)event {
    // find the next coll whose pos >= cursor
    LVColl* nextColl = LVFindNextCollOnOrAfterPosition(self.clojureTextStorage.doc, self.selectedRange.location);
    
    // if there is one, move to after its first child
    if (nextColl) {
        LVAtom* firstChild = (LVAtom*)nextColl->children[0];
        NSUInteger pos = firstChild->token->pos + LVElementLength((LVElement*)firstChild);
        self.selectedRange = NSMakeRange(pos, 0);
        [self scrollRangeToVisible:self.selectedRange];
    }
}

- (void) inBackwardSexp:(NSEvent*)event {
    // find the next coll whose pos >= cursor
    LVColl* nextColl = LVFindNextCollBeforePosition(self.clojureTextStorage.doc, self.selectedRange.location);
    
    // if there is one, move to after its first child
    if (nextColl) {
        LVAtom* firstChild = (LVAtom*)nextColl->children[nextColl->childrenLen - 1];
        NSUInteger pos = firstChild->token->pos;
        self.selectedRange = NSMakeRange(pos, 0);
        [self scrollRangeToVisible:self.selectedRange];
    }
}

LVToken* LVGetAtomIndexFollowingPosition(LVDoc* doc, size_t pos) {
    for (LVToken* tok = doc->firstToken->nextToken; tok; tok = tok->nextToken) {
        if (pos >= tok->pos && pos < tok->pos + CFStringGetLength(tok->string))
            return tok;
    }
    return NULL; // TODO: uhh, what does this mean again?
}

- (void) jumpToNextBlankLineGroup:(NSEvent*)event {
    LVToken* foundToken = LVGetAtomIndexFollowingPosition(self.clojureTextStorage.doc, self.selectedRange.location);
    if (!foundToken)
        return;
    
    for (LVToken* token = foundToken->nextToken; token; token = token->nextToken) {
        if (token->tokenType & LVTokenType_Newlines) {
            if (CFStringGetLength(token->string) > 1) {
                NSUInteger pos = token->pos + 1;
                self.selectedRange = NSMakeRange(pos, 0);
                [self scrollRangeToVisible:self.selectedRange];
                return;
            }
        }
    }
}

- (void) jumpToPreviousBlankLineGroup:(NSEvent*)event {
    LVToken* foundToken = LVGetAtomIndexFollowingPosition(self.clojureTextStorage.doc, self.selectedRange.location);
    if (!foundToken)
        return;
    
    for (LVToken* token = foundToken->prevToken; token; token = token->prevToken) {
        if (token->tokenType & LVTokenType_Newlines) {
            if (CFStringGetLength(token->string) > 1) {
                NSUInteger pos = token->pos + 1;
                self.selectedRange = NSMakeRange(pos, 0);
                [self scrollRangeToVisible:self.selectedRange];
                return;
            }
        }
    }
}







/************************************************ PAREDIT (selecting) ************************************************/

- (void) extendSelectionToNext:(NSEvent*)event {
    LVElement* next = LVFindNextSemanticElementStartingAtPosition(self.clojureTextStorage.doc, NSMaxRange(self.selectedRange));
    if (next) {
        NSUInteger afterPos = LVGetAbsolutePosition(next) + LVElementLength(next);
        NSRange rangeToSelect = NSMakeRange(self.selectedRange.location, afterPos - self.selectedRange.location);
        
        self.selectedRange = rangeToSelect;
        [self scrollRangeToVisible:self.selectedRange];
    }
}










/************************************************ PAREDIT (indentation) ************************************************/

size_t LVGetIndentationForInsideOfColl(LVColl* coll) {
    size_t count = 0;
    
    LVAtom* openingAtom = (LVAtom*)coll->children[0];
    for (LVToken* token = openingAtom->token; !((token->tokenType & LVTokenType_Newlines) || (token->prevToken == NULL)); token = token->prevToken) {
        count += CFStringGetLength(token->string);
    }
    
    return count;
}

- (void) indentText {
    NSMutableArray* replacementRanges = [NSMutableArray array];
    NSMutableArray* replacementStrings = [NSMutableArray array];
    
    LVDoc* doc = self.clojureTextStorage.doc;
    for (LVToken* tok = doc->firstToken->nextToken; tok->nextToken; tok = tok->nextToken) {
        if (tok->tokenType & LVTokenType_Newlines) {
            
//            // empty-out any whitespace tokens IMMEDIATELY BEFORE IT
//            LVToken* prevTok = tok->prevToken;
//            if (prevTok->tokenType & LVTokenType_Spaces) {
//                [replacementRanges addObject:[NSValue valueWithRange:NSMakeRange(prevTok->pos, CFStringGetLength(prevTok->string))]];
//                [replacementStrings addObject:@""];
//            }
            
            LVToken* nextTok = tok->nextToken;
            
            size_t existingSpaces = 0;
            if (nextTok->tokenType & LVTokenType_Spaces)
                existingSpaces = CFStringGetLength(nextTok->string);
            
            LVAtom* newlineAtom = tok->atom;
            LVColl* newlineParent = newlineAtom->parent;
            size_t indentationForInsideOfColl = LVGetIndentationForInsideOfColl(newlineParent);
            
            size_t expectedSpaces;
            
            // TODO: this works fine if its a map or set or vec, but if its a list, we need to get fancier.
            expectedSpaces = indentationForInsideOfColl;
            
            if (existingSpaces < expectedSpaces) {
                // you have fewer spaces than you need, so we should insert some
                size_t difference = expectedSpaces - existingSpaces;
                
                NSString* spaces = [@"" stringByPaddingToLength:difference withString:@" " startingAtIndex:0];
                
                [replacementRanges addObject:[NSValue valueWithRange:NSMakeRange(nextTok->pos, 0)]];
                [replacementStrings addObject:spaces];
            }
            else if (existingSpaces > expectedSpaces) {
                // you have too many spaces, so we should delete some
                size_t difference = existingSpaces - expectedSpaces;
                
                [replacementRanges addObject:[NSValue valueWithRange:NSMakeRange(nextTok->pos, difference)]];
                [replacementStrings addObject:@""];
            }
        }
    }
    
    if ([replacementRanges count] > 0) {
        [self shouldChangeTextInRanges:replacementRanges replacementStrings:replacementStrings];
        
        [self.clojureTextStorage withDisabledParsing:^{
            NSInteger offset = 0;
            
            for (NSUInteger i = 0; i < [replacementStrings count]; i++) {
                NSRange r = [[replacementRanges objectAtIndex:i] rangeValue];
                NSString* str = [replacementStrings objectAtIndex:i];
                
                r.location += offset;
                [self.textStorage replaceCharactersInRange:r withString:str];
                offset += [str length] - r.length;
            }
        }];
        [self didChangeText];
    }
}










































//- (void) insertText:(id)insertString {
//    [super insertText:insertString];
//    return;
//    
//    size_t childsIndex;
//    LVColl* coll = LVFindDeepestColl(self.file.topLevelElement, 0, self.selectedRange.location, &childsIndex);
//    
//    
////    printf("coll=%p, idx=%lu, rel=%lu\n", coll, childsIndex, relativePos);
//    size_t collPos = LVGetAbsolutePosition((void*)coll);
////    printf("%ld\n", collPos);
//    
////    LVElement* tmp = coll->children[childsIndex];
////    coll->children[childsIndex] = coll->children[childsIndex+2];
////    coll->children[childsIndex+2] = tmp;
//    
//    NSRange range = NSMakeRange(collPos, LVElementLength((void*)coll));
//    
//    LVAtom* atom = (void*)coll->children[childsIndex];
//    atom->token->string->data[0]++;
////    binsertch(atom->token->string, 0, 1, 'a');
//    
//    NSRange oldSelection = self.selectedRange;
//    
//    bstring str = LVStringForColl(coll);
//    NSString* newStr = [NSString stringWithUTF8String:(char*)str->data];
//    
//    [self sd_r:range str:newStr];
//    
//    bdestroy(str);
//    
//    LVHighlight((void*)coll, [self textStorage], collPos);
//    
//    self.selectedRange = oldSelection;
//    
////    @autoreleasepool {
////        [super insertText:insertString];
////        [self indentCurrentBody];
////    }
//}








//NSUInteger LVFirstNewlineBefore(NSString* str, NSUInteger pos) {
//    NSUInteger found = [str rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]
//                                            options:NSBackwardsSearch
//                                              range:NSMakeRange(0, pos)].location;
//    if (found == NSNotFound)
//        found = 0;
//    else
//        found++;
//    
//    return found;
//}

//BOOL LVIsFunctionLike(LVColl* coll) {
//    // we already assume its a coll with 2+ childs
//    id<LVElement> firstChild = [[coll childElements] objectAtIndex:0];
//    if (![firstChild isAtom])
//        return NO;
//    
//    LVAtom* atomChild = firstChild;
//    
//    static NSArray* functionLikes;
//    if (!functionLikes)
//        functionLikes = @[@"let", @"if", @"if-let", @"cond", @"case"
////    , @"let", @"describe"
//                          ];
//    
//    return ([functionLikes containsObject: [atomChild token].val]);
//}

//NSRange LVExtendRangeToBeginningPos(NSRange r, NSUInteger pos) {
//    return NSMakeRange(pos, r.length + (r.location - pos));
//}
//
//NSRange LVRangeWithNewAbsoluteLocationButSameEndPoint(NSRange r, NSUInteger absPosWithin) {
//    // 1 [2 -3- 4 5]
//    return NSMakeRange(absPosWithin, NSMaxRange(r) - absPosWithin);
//}

//- (void) indentCurrentBody {
//    return;
//    NSLog(@"indenting");
//    
//    NSRange selection = self.selectedRange;
//    NSUInteger childIndex;
//    LVColl* currentColl = [self.file.topLevelElement deepestCollAtPos:selection.location childsIndex:&childIndex];
//    LVColl* highestParentColl = [currentColl highestParentColl];
//    
//    NSString* wholeString = [[self textStorage] string];
//    
//    NSRange wholeBlockRange = highestParentColl.fullyEnclosedRange;
//    
//    NSUInteger firstNewlinePosition = LVFirstNewlineBefore(wholeString, wholeBlockRange.location);
//    
//    wholeBlockRange = LVExtendRangeToBeginningPos(wholeBlockRange, firstNewlinePosition);
//    
////    NSLog(@"[%@]", [wholeString substringWithRange:wholeBlockRange]);
//    
//    NSUInteger currentPos = wholeBlockRange.location;
//    
//    while (NSLocationInRange(currentPos, wholeBlockRange)) {
//        NSRange remainingRange = LVRangeWithNewAbsoluteLocationButSameEndPoint(wholeBlockRange, currentPos);
//        
//        NSUInteger nextNewlinePosition = [wholeString rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]
//                                                                      options:0
//                                                                        range:remainingRange].location;
//        
//        if (nextNewlinePosition == NSNotFound)
//            nextNewlinePosition = NSMaxRange(wholeBlockRange);
//        else
//            nextNewlinePosition++;
//        
//        NSRange currentLineRange = NSMakeRange(currentPos, nextNewlinePosition - currentPos);
//        
//        
//        // get first non-space char's pos (absolute)
//        
//        NSUInteger firstNonSpaceCharPos = [wholeString rangeOfCharacterFromSet:[[NSCharacterSet whitespaceCharacterSet] invertedSet]
//                                                                       options:0
//                                                                         range:currentLineRange].location;
//        
//        if (firstNonSpaceCharPos == NSNotFound) {
//            firstNonSpaceCharPos = NSMaxRange(currentLineRange);
//        }
//        
//        // get that val relative
//        
//        NSUInteger firstNonSpaceCharPosRelative = firstNonSpaceCharPos - currentPos;
//        
//        // get coll parent for beginning of line (its type info and indentation info will be helpful soon)
//        
//        NSUInteger childIndexOfFirstElementOnLine;
//        LVColl* collParentForBeginningOfLine = [self.file.topLevelElement deepestCollAtPos:currentPos childsIndex:&childIndexOfFirstElementOnLine];
//        
//        
//        
//        // figure out proper indentation level
//        
//        
//        NSUInteger expectedStartSpaces;
//        
//        if (collParentForBeginningOfLine.collType == LVCollTypeTopLevel) {
//            expectedStartSpaces = 0;
//        }
//        else {
//            NSUInteger openingTokenRecentNewline = LVFirstNewlineBefore(wholeString, collParentForBeginningOfLine.openingToken.range.location);
//            NSUInteger prefixIndentation = collParentForBeginningOfLine.openingToken.range.location - openingTokenRecentNewline;
//            
//            if (collParentForBeginningOfLine.collType == LVCollTypeList) {
//                if ([collParentForBeginningOfLine isKindOfClass:[LVDefinition self]] || LVIsFunctionLike(collParentForBeginningOfLine)) {
//                    expectedStartSpaces = prefixIndentation + 2;
//                }
//                else if ([[collParentForBeginningOfLine childElements] count] >= 2 && childIndexOfFirstElementOnLine >= 2) {
//                    id<LVElement> secondChild = [[collParentForBeginningOfLine childElements] objectAtIndex: 1];
//                    NSUInteger childBeginning = [secondChild fullyEnclosedRange].location;
//                    NSUInteger newlineBeforeSecondChild = LVFirstNewlineBefore(wholeString, childBeginning);
//                    
//                    expectedStartSpaces = childBeginning - newlineBeforeSecondChild;
//                }
//                else {
//                    expectedStartSpaces = prefixIndentation + 2;
//                }
//            }
//            else {
//                expectedStartSpaces = prefixIndentation + 1;
//            }
//            
//        }
//        
//        NSInteger spacesToAdd = expectedStartSpaces - firstNonSpaceCharPosRelative;
//        
////        NSLog(@"%ld", spacesToAdd);
//        
//        if (spacesToAdd != 0) {
//            if (spacesToAdd > 0) {
//                NSString* spaces = [@"" stringByPaddingToLength:spacesToAdd withString:@" " startingAtIndex:0];
//                NSRange tempRange = NSMakeRange(currentPos, 0);
//                [self replaceRange:tempRange withString:spaces];
//            }
//            if (spacesToAdd < 0) {
//                // its really spaces to delete, now.
//                NSRange tempRange = NSMakeRange(currentPos, labs(spacesToAdd));
//                [self replaceRange:tempRange withString:@""];
//            }
//            
//            wholeBlockRange.length += spacesToAdd;
//            nextNewlinePosition += spacesToAdd;
//        }
//        
//        // done doing things, ready to loop again.
//        
//        currentPos = nextNewlinePosition;
//        
//    }
//    
//    
//    // TODO: thoughts on a new plan for indentation:
//    //       - edit the list of tokens itself
//    //       - after each child in a coll, search for next newline, before either next child or closing token (if you're at end of coll).
//    //       - if there is no newline, do nothing (you're on the same line!)
//    //       - but if there IS a newline:
//    //           - delete all whitespace BEFORE the newline (yay)
//    //           - calculate the proper number of whitespace after the newline and before the next non-space char
//    //               - if the next non-space char is a newline, erase all those spaces
//    //               - otherwise, add/delete whitespace to make it match
//    //           - OH WAIT: this adding/removing means rewriting the parse-tree :(
//    
//    
////    printf("\n");
//}

//LVElement* LVGetNextSemanticElement(LVColl* parent, size_t childIndex) {
//    LVElement* semanticChildren[parent->childrenLen];
//    size_t semanticChildrenCount;
//    LVGetSemanticDirectChildren(parent, childIndex, semanticChildren, &semanticChildrenCount);
//    
//    if (semanticChildrenCount > 0)
//        return semanticChildren[0];
//    else
//        return NULL;
//}

//- (void) insertText:(id)insertString {
//    NSDictionary* balancers = @{@"(": @")", @"[": @"]", @"{": @"}"};
//    NSString* origString = insertString;
//    NSString* toBalance = [balancers objectForKey:origString];
//    
//    if (toBalance) {
//        NSRange selection = self.selectedRange;
//        NSString* subString = [[[self textStorage] string] substringWithRange:selection];
//        
//        if (selection.length == 0) {
//            [super insertText:insertString];
//            [super insertText:toBalance];
//            [self moveBackward:self];
//        }
//        else {
//            NSString* newString = [NSString stringWithFormat:@"%@%@%@", origString, subString, toBalance];
//            [self insertText:newString];
//        }
//        
//        return;
//    }
//    
//    if ([[balancers allKeysForObject:origString] count] > 0) {
//        NSUInteger loc = self.selectedRange.location;
//        NSString* wholeString = [[self textStorage] string];
//        
//        if (loc < [wholeString length]) {
//            unichar c = [wholeString characterAtIndex:loc];
//            if (c == [origString characterAtIndex:0]) {
//                [self moveForward:self];
//            }
//        }
//        
//        return;
//    }
//    
//    [super insertText:insertString];
//}

@end
