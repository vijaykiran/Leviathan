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

#import <objc/runtime.h>

@implementation LVTextView

- (BOOL) becomeFirstResponder {
    BOOL did = [super becomeFirstResponder];
    if (did) {
        [self.customDelegate textViewWasFocused:self];
    }
    return did;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) awakeFromNib {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultsFontChanged:) name:LVDefaultsFontChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultsThemeChanged:) name:LVCurrentThemeChangedNotification object:nil];
    
    [self setupNiceties];
//    [self setupAutoIndentation];
}

//// sel must return (void) and take one (id) arg
//- (void) swizzleMethodWithIndentation:(SEL)sel {
//    Method m = class_getInstanceMethod([self class], sel);
//    IMP oldImp = method_getImplementation(m);
//    method_setImplementation(m, imp_implementationWithBlock([^(id self, id arg) {
////        [[self undoManager] beginUndoGrouping];
//        oldImp(self, sel, arg);
//        [self indentText];
////        [[self undoManager] endUndoGrouping];
//    } copy]));
//}
//
//- (void) setupAutoIndentation {
//    [self swizzleMethodWithIndentation:@selector(insertNewline:)];
//    [self swizzleMethodWithIndentation:@selector(insertText:)];
//}

- (void) defaultsFontChanged:(NSNotification*)note {
    [self.clojureTextStorage rehighlight];
    [self setupNiceties];
}

- (void) defaultsThemeChanged:(NSNotification*)note {
    [self.clojureTextStorage rehighlight];
    [self setupNiceties];
}

- (void) setupNiceties {
    self.enclosingScrollView.verticalScroller.knobStyle = self.enclosingScrollView.horizontalScroller.knobStyle = NSScrollerKnobStyleLight;
    
    self.automaticTextReplacementEnabled = NO;
    self.automaticSpellingCorrectionEnabled = NO;
    self.automaticQuoteSubstitutionEnabled = NO;
    self.automaticDashSubstitutionEnabled = NO;
    self.automaticLinkDetectionEnabled = NO;
    self.automaticDataDetectionEnabled = NO;
    
    self.backgroundColor = [LVThemeManager sharedThemeManager].currentTheme.backgroundColor;
    self.insertionPointColor = [LVThemeManager sharedThemeManager].currentTheme.cursorColor;
    self.selectedTextAttributes = [LVThemeManager sharedThemeManager].currentTheme.selection;
    
    [self sd_disableLineWrapping];
    
//    [super setTextContainerInset:NSMakeSize(0.0f, 4.0f)];
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
        
        [NSApp sendAction:shortcut.action to:nil from:nil];
        [[NSApp menu] performActionForItemAtIndex:3];
        
        return;
    }
    
    [super keyDown:theEvent];
}

- (IBAction) cancelOperation:(id)sender {
    self.selectedRange = NSMakeRange(self.selectedRange.location, 0);
}








/************************************************ Helper Functions ************************************************/

// not sure how generally useful these are yet

LVColl* LVFindNextCollOnOrAfterPosition(LVDoc* doc, NSUInteger pos) {
    NSUInteger childIndex;
    LVColl* parent = LVFindElementAtPosition(doc, pos, &childIndex);
    
    for (NSUInteger i = childIndex; i < parent->childrenLen; i++) {
        LVColl* maybeColl = (LVColl*)parent->children[i];
        
        if (!maybeColl->isAtom)
            return maybeColl;
    }
    
    return NULL;
}

LVColl* LVFindNextCollBeforePosition(LVDoc* doc, NSUInteger pos) {
    NSUInteger childIndex;
    LVColl* parent = LVFindElementAtPosition(doc, pos, &childIndex);
    
    for (NSUInteger i = childIndex - 1; i >= 1; i--) {
        LVColl* maybeColl = (LVColl*)parent->children[i];
        
        if (!maybeColl->isAtom)
            return maybeColl;
    }
    
    return NULL;
}

LVElement* LVFindNextSemanticElementStartingAtPosition(LVDoc* doc, NSUInteger pos) {
    NSUInteger childIndex;
    LVColl* parent = LVFindElementAtPosition(doc, pos, &childIndex);
    
    for (NSUInteger i = childIndex; i < parent->childrenLen; i++) {
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

BOOL LVIsMultiNewlineToken(LVToken* token) {
    return ((token->tokenType & LVTokenType_Newlines) && CFStringGetLength(token->string) > 1);
}












/************************************************ PAREDIT (editing) ************************************************/


- (IBAction) raiseExpression:(id)sender {
    NSRange selection = self.selectedRange;
    
    LVElement* elementToRaise = LVFindNextSemanticChildStartingAt(self.clojureTextStorage.doc, selection.location);
    if (elementToRaise) {
        LVElement* child = elementToRaise;
        LVColl* parent = child->parent;
        
        if (parent->collType & LVCollType_TopLevel)
            return;
        
        NSUInteger _absPos = LVGetAbsolutePosition(child);
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

- (IBAction) deleteNextExpression:(id)sender {
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

- (IBAction) deleteToEndOfExpression:(id)sender {
    [self deleteToBeginningOfParagraph:sender];
}

- (IBAction) deleteToEndOfParagraph:(id)sender {
    if (!self.clojureTextStorage.doc) {
        [super deleteToEndOfParagraph:sender];
        return;
    }
    
    LVElement* firstAtomToNotDelete = NULL;
    
    NSUInteger childIndex;
    LVColl* parent = LVFindElementAtPosition(self.clojureTextStorage.doc, self.selectedRange.location, &childIndex);
    
    for (NSUInteger i = childIndex; i < parent->childrenLen; i++) {
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

- (IBAction) spliceExpression:(id)sender {
    NSUInteger childIndex;
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

- (IBAction) wrapNextExpressionInBrackets:(id)sender {
    [self wrapNextInThing:@"[" and:@"]"];
}

- (IBAction) wrapNextExpressionInBraces:(id)sender {
    [self wrapNextInThing:@"{" and:@"}"];
}

- (IBAction) wrapNextExpressionInParentheses:(id)sender {
    [self wrapNextInThing:@"(" and:@")"];
}

- (void) insertText:(id)insertString {
    if ([insertString rangeOfString:@"\t"].location != NSNotFound)
        insertString = [insertString stringByReplacingOccurrencesOfString:@"\t" withString:@"  "];
    
    if (!self.clojureTextStorage.doc) {
        [super insertText:insertString];
        return;
    }
    
    LVAtom* atom = LVFindAtomPrecedingIndex(self.clojureTextStorage.doc, self.selectedRange.location);
    
    BOOL adjusted = NO;
    NSUInteger adjustedBy = 0;
    
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
            insertString = @"()", adjusted = YES, adjustedBy++;
        else if ([insertString isEqualToString: @"["])
            insertString = @"[]", adjusted = YES, adjustedBy++;
        else if ([insertString isEqualToString: @"{"])
            insertString = @"{}", adjusted = YES, adjustedBy++;
        else if ([insertString isEqualToString: @"\""])
            insertString = @"\"\"", adjusted = YES, adjustedBy++;
        
        if (adjusted) {
            NSUInteger pos = self.selectedRange.location;
            
            // if not at very beginning and character right before cursor is NOT " " or "\n", then add " " to beginning
            if (pos > 0) {
                unichar c = [self.textStorage.string characterAtIndex:pos - 1];
                if (c != ' ' && c != '\n' && c != '(' && c != '{' && c != '[')
                    insertString = [@" " stringByAppendingString:insertString];
                
                // if not at very end and next character is NOT space or newline, add space after
                if (pos < [self.textStorage.string length] - 1) {
                    unichar c = [self.textStorage.string characterAtIndex:pos];
                    if (c != ' ' && c != '\n')
                        insertString = [insertString stringByAppendingString:@" "], adjustedBy++;
                }
            }
        }
    }
    
    [super insertText:insertString];
    
    for (int i = 0; i < adjustedBy; i++)
        [self moveBackward:nil];
}

- (IBAction) commentLinesFirstExpression:(id)sender {
    
}

//- (void) doCommandBySelector:(SEL)aSelector {
//    NSLog(@"%@", NSStringFromSelector(aSelector));
//    [super doCommandBySelector:aSelector];
//}




/************************************************ PAREDIT (navigating) ************************************************/


// TODO: Cmd+Shift+V should show a list of previous pastes and let you choose which one to paste. or maybe Cmd+Shift+C should do the same but choose which one to Copy again. Or maybe both!?

- (IBAction) moveToFirstNonBlankCharacterOnLine:(id)sender {
    NSRange selection = self.selectedRange;
    
    LVAtom* atom = LVFindAtomPrecedingIndex(self.clojureTextStorage.doc, selection.location);
    LVToken* token = atom->token;
    
    // find the beginning-of-line token
    while (!((token->tokenType & LVTokenType_FileBegin) || (token->tokenType & LVTokenType_Newlines)))
        token = token->prevToken;
    
    // but if its a newline, cold-stop!
    if (token->tokenType & LVTokenType_Newlines && CFStringGetLength(token->string) > 1 && selection.location < token->pos + CFStringGetLength(token->string))
        return;
    
    // move to the next token while its spaces
    do token = token->nextToken;
    while (token->tokenType & LVTokenType_Spaces);
    
    // its not spaces! move to pos
    self.selectedRange = NSMakeRange(token->pos, 0);
    [self scrollRangeToVisible:self.selectedRange];
}


- (IBAction) moveOutExpressionBackward:(id)sender {
    NSRange selection = self.selectedRange;
    
    NSUInteger childIndex;
    LVColl* parent = LVFindElementAtPosition(self.clojureTextStorage.doc, selection.location, &childIndex);
    
    self.selectedRange = NSMakeRange(LVGetAbsolutePosition((LVElement*)parent), 0);
    [self scrollRangeToVisible:self.selectedRange];
}

- (IBAction) moveOutExpressionForward:(id)sender {
    NSRange selection = self.selectedRange;
    
    NSUInteger childIndex;
    LVColl* parent = LVFindElementAtPosition(self.clojureTextStorage.doc, selection.location, &childIndex);
    
    self.selectedRange = NSMakeRange(LVGetAbsolutePosition((LVElement*)parent) + LVElementLength((LVElement*)parent), 0);
    [self scrollRangeToVisible:self.selectedRange];
}

- (IBAction) moveForwardExpression:(id)sender {
    LVElement* elementToMoveToEndOf = LVFindNextSemanticChildStartingAt(self.clojureTextStorage.doc, self.selectedRange.location);
    if (elementToMoveToEndOf) {
        NSUInteger posAfterElement = LVGetAbsolutePosition(elementToMoveToEndOf) + LVElementLength(elementToMoveToEndOf);
        self.selectedRange = NSMakeRange(posAfterElement, 0);
        [self scrollRangeToVisible:self.selectedRange];
    }
    else {
        [self moveOutExpressionForward:sender];
    }
}

- (IBAction) moveBackwardExpression:(id)sender {
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
        NSUInteger pos = LVGetAbsolutePosition(foundElement);
        self.selectedRange = NSMakeRange(pos, 0);
        [self scrollRangeToVisible:self.selectedRange];
    }
    else {
        // otherwise, move to the beginning of it. otherwise do "out backward sexp"
        [self moveOutExpressionBackward:sender];
    }
}

- (IBAction) moveIntoNextExpression:(id)sender {
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

- (IBAction) moveIntoPreviousExpression:(id)sender {
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

- (IBAction) moveToNextBlankLines:(id)sender {
    LVToken* token = LVFindAtomPrecedingIndex(self.clojureTextStorage.doc, self.selectedRange.location)->token;
    do token = token->nextToken; while (token && !(token->tokenType & LVTokenType_FileEnd) && !LVIsMultiNewlineToken(token));
    
    self.selectedRange = NSMakeRange(token->pos + MIN(1, CFStringGetLength(token->string)), 0);
    [self scrollRangeToVisible:self.selectedRange];
}

- (IBAction) moveToPreviousBlankLines:(id)sender {
    LVToken* token = LVFindAtomFollowingIndex(self.clojureTextStorage.doc, self.selectedRange.location)->token;
    do token = token->prevToken; while (token && !(token->tokenType & LVTokenType_FileBegin) && !LVIsMultiNewlineToken(token));
    
    self.selectedRange = NSMakeRange(token->pos + MIN(1, CFStringGetLength(token->string)), 0);
    [self scrollRangeToVisible:self.selectedRange];
}







/************************************************ PAREDIT (selecting) ************************************************/

- (IBAction) extendSelectionToNextExpression:(id)sender {
    LVElement* next = LVFindNextSemanticElementStartingAtPosition(self.clojureTextStorage.doc, NSMaxRange(self.selectedRange));
    if (next) {
        NSUInteger afterPos = LVGetAbsolutePosition(next) + LVElementLength(next);
        NSRange rangeToSelect = NSMakeRange(self.selectedRange.location, afterPos - self.selectedRange.location);
        
        self.selectedRange = rangeToSelect;
        [self scrollRangeToVisible:self.selectedRange];
    }
}










/************************************************ PAREDIT (indentation) ************************************************/

NSUInteger LVGetIndentationForInsideOfColl(LVColl* coll) {
    NSUInteger count = 0;
    
    LVAtom* openingAtom = (LVAtom*)coll->children[0];
    for (LVToken* token = openingAtom->token; !((token->tokenType & LVTokenType_Newlines) || (token->prevToken == NULL)); token = token->prevToken) {
        count += CFStringGetLength(token->string);
    }
    
    return count;
}

- (IBAction) indentCurrentSection:(id)sender {
    LVDoc* doc = self.clojureTextStorage.doc;
    if (!doc)
        return;
    
    NSMutableArray* replacementRanges = [NSMutableArray array];
    NSMutableArray* replacementStrings = [NSMutableArray array];
    
    LVElement* element = (LVElement*)LVFindAtomFollowingIndex(doc, self.selectedRange.location);
    while (element->parent)
        element = (LVElement*)element->parent;
    
    LVColl* highestColl = (LVColl*)element;
    LVToken* startToken = ((LVAtom*)highestColl->children[0])->token;
    LVToken* endToken = ((LVAtom*)highestColl->children[highestColl->childrenLen - 1])->token;
    
    for (LVToken* tok = startToken; tok != endToken; tok = tok->nextToken) {
        if (tok->tokenType & LVTokenType_Newlines) {
            LVToken* nextTok = tok->nextToken;
            
            NSUInteger existingSpaces = 0;
            if (nextTok->tokenType & LVTokenType_Spaces)
                existingSpaces = CFStringGetLength(nextTok->string);
            
            LVAtom* newlineAtom = tok->atom;
            LVColl* newlineParent = newlineAtom->parent;
            NSUInteger indentationForInsideOfColl = LVGetIndentationForInsideOfColl(newlineParent);
            
            NSUInteger expectedSpaces = indentationForInsideOfColl; // default to aligning with the coll's open-token
            
            if (newlineParent->collType & LVCollType_List) {
                if (newlineParent->collType & LVCollType_Definition) {
                    // its function-like:
                    expectedSpaces += 1;
                }
                else {
                    int semanticChildrenFound = 0;
                    LVElement* firstChildOnSameLine = NULL;
                    LVElement* secondChildOnSameLine = NULL;
                    NSUInteger len = 0; // we'll just add all the children things up to this point, JUST IN CASE
                    
                    for (NSUInteger i = 1; i < newlineParent->childrenLen; i++) {
                        LVElement* child = newlineParent->children[i];
                        
                        if (LVElementIsSemantic(child)) {
                            semanticChildrenFound++;
                            if (semanticChildrenFound == 1) {
                                firstChildOnSameLine = child;
                            }
                            else if (semanticChildrenFound == 2) {
                                secondChildOnSameLine = child;
                                break;
                            }
                        }
                        else if (child->isAtom && ((LVAtom*)child)->atomType & LVAtomType_Newlines) {
                            break;
                        }
                        len += LVElementLength(child);
                    }
                    
                    // TODO: this is totally incorrect. both Deflikes and IndentLikeFns should indent 2 spaces on every-but-first line NO MATTER WHAT.
                    //       the only time it should care if there's a second-semantic-child on the first line is when it's not one of these types (i.e. just a normal list).
                    
                    // does it have two semantic elements on the first line of this coll?
                    if (secondChildOnSameLine) {
                        static CFMutableArrayRef functionLikes; if (!functionLikes) {
                            functionLikes = CFArrayCreateMutable(NULL, 0, &kCFTypeArrayCallBacks);
                            CFArrayAppendValue(functionLikes, CFSTR("ns"));
                            CFArrayAppendValue(functionLikes, CFSTR("let"));
                            CFArrayAppendValue(functionLikes, CFSTR("for"));
                            CFArrayAppendValue(functionLikes, CFSTR("assoc"));
                            CFArrayAppendValue(functionLikes, CFSTR("if"));
                            CFArrayAppendValue(functionLikes, CFSTR("if-let"));
                            CFArrayAppendValue(functionLikes, CFSTR("cond"));
                            CFArrayAppendValue(functionLikes, CFSTR("case"));
                            CFArrayAppendValue(functionLikes, CFSTR("list"));
                        }
                        
                        // is the first child def-like indentation-wise?
                        if (firstChildOnSameLine->isAtom &&
                            (((LVAtom*)firstChildOnSameLine)->atomType & LVAtomType_Symbol) &&
                            CFArrayContainsValue(functionLikes, CFRangeMake(0, CFArrayGetCount(functionLikes)), ((LVAtom*)firstChildOnSameLine)->token->string))
                        {
                            // if so, make it indent like a function
                            expectedSpaces += 1;
                        }
                        else {
                            // if not, indent to align with the second one
                            expectedSpaces += len;
                        }
                    }
                }
            }
            
            if (existingSpaces < expectedSpaces) {
                // you have fewer spaces than you need, so we should insert some
                NSUInteger difference = expectedSpaces - existingSpaces;
                
                NSString* spaces = [@"" stringByPaddingToLength:difference withString:@" " startingAtIndex:0];
                
                [replacementRanges addObject:[NSValue valueWithRange:NSMakeRange(nextTok->pos, 0)]];
                [replacementStrings addObject:spaces];
            }
            else if (existingSpaces > expectedSpaces) {
                // you have too many spaces, so we should delete some
                NSUInteger difference = existingSpaces - expectedSpaces;
                
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
        [self indentCurrentSection:sender];
    }
}

- (void) indentText {
    // for (LVToken* tok = doc->firstToken->nextToken; tok->nextToken; tok = tok->nextToken)
}

- (void) stripWhitespace {
    NSMutableArray* replacementRanges = [NSMutableArray array];
    NSMutableArray* replacementStrings = [NSMutableArray array];
    
    LVDoc* doc = self.clojureTextStorage.doc;
    for (LVToken* tok = doc->firstToken->nextToken; tok->nextToken; tok = tok->nextToken) {
        if (tok->tokenType & LVTokenType_Newlines) {
            // empty-out any whitespace tokens IMMEDIATELY BEFORE IT
            LVToken* prevTok = tok->prevToken;
            if (prevTok->tokenType & LVTokenType_Spaces) {
                [replacementRanges addObject:[NSValue valueWithRange:NSMakeRange(prevTok->pos, CFStringGetLength(prevTok->string))]];
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
                [self replaceCharactersInRange:r withString:str];
                offset += [str length] - r.length;
            }
        }];
        [self didChangeText];
    }
}
















/************************************************ Semantic Selection ************************************************/

- (NSRange)selectionRangeForProposedRange:(NSRange)proposedSelRange granularity:(NSSelectionGranularity)granularity {
    if (granularity == NSSelectByWord && proposedSelRange.length == 0) {
        NSUInteger idx = proposedSelRange.location;
        
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
            return NSMakeRange(start, end - start + 1);
        }
    }
    
    return [super selectionRangeForProposedRange:proposedSelRange granularity:granularity];
}

@end
