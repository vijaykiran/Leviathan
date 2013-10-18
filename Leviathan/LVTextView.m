//
//  LVTextView.m
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVTextView.h"

#import "LVThemeManager.h"
#import "LVHighlighter.h"
#import "LVPreferences.h"

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

- (void) defaultsFontChanged:(NSNotification*)note {
    NSRange fullRange = NSMakeRange(0, [self.textStorage length]);
    [self.textStorage addAttribute:NSFontAttributeName
                             value:[LVPreferences userFont]
                             range:fullRange];
}

- (void) awakeFromNib {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultsFontChanged:) name:LVDefaultsFontChangedNotification object:nil];
    
    self.enclosingScrollView.verticalScroller.knobStyle = NSScrollerKnobStyleLight;
    self.enclosingScrollView.horizontalScroller.knobStyle = NSScrollerKnobStyleLight;
    
    self.font = [LVPreferences userFont];
    self.backgroundColor = LVColorFromHex([[[LVThemeManager sharedThemeManager] currentTheme] objectForKey:LVStyleBackgroundColor]);
    self.insertionPointColor = LVColorFromHex([[[LVThemeManager sharedThemeManager] currentTheme] objectForKey:LVStyleCursorColor]);
    
    {
        NSDictionary* style = [[[LVThemeManager sharedThemeManager] currentTheme] objectForKey:LVStyleForSelection];
        NSMutableDictionary* selectionAttrs = [NSMutableDictionary dictionary];
        
        if ([style objectForKey:@"ForegroundColor"])
            selectionAttrs[NSForegroundColorAttributeName] = LVColorFromHex([style objectForKey:@"ForegroundColor"]);
        
        if ([style objectForKey:@"BackgroundColor"])
            selectionAttrs[NSBackgroundColorAttributeName] = LVColorFromHex([style objectForKey:@"BackgroundColor"]);
        
        self.selectedTextAttributes = selectionAttrs;
    }
    
    
    
    
    
    [self sd_disableLineWrapping];
    [super setTextContainerInset:NSMakeSize(0.0f, 4.0f)];
    
//    static BOOL menusSetup;
//    if (!menusSetup) {
//        menusSetup = YES;
//        
//        [self addParedit:@selector(raiseSexp:) title:@"Raise" keyEquiv:@"r" mods:NSControlKeyMask];
//        [self addParedit:@selector(spliceSexp:) title:@"Splice" keyEquiv:@"s" mods:NSControlKeyMask];
//        [self addParedit:@selector(forwardSexp:) title:@"Forward" keyEquiv:@"f" mods:NSControlKeyMask | NSAlternateKeyMask];
//        [self addParedit:@selector(backwardSexp:) title:@"Backward" keyEquiv:@"b" mods:NSControlKeyMask | NSAlternateKeyMask];
//        [self addParedit:@selector(outBackwardSexp:) title:@"Out Backward" keyEquiv:@"u" mods:NSControlKeyMask | NSAlternateKeyMask];
//        [self addParedit:@selector(outForwardSexp:) title:@"Out Forward" keyEquiv:@"n" mods:NSControlKeyMask | NSAlternateKeyMask];
//        [self addParedit:@selector(inForwardSexp:) title:@"In Forward" keyEquiv:@"d" mods:NSControlKeyMask | NSAlternateKeyMask];
//        [self addParedit:@selector(inBackwardSexp:) title:@"In Backward" keyEquiv:@"p" mods:NSControlKeyMask | NSAlternateKeyMask];
//        [self addParedit:@selector(killNextSexp:) title:@"Kill Next" keyEquiv:@"k" mods:NSControlKeyMask | NSAlternateKeyMask];
//        [self addParedit:@selector(wrapNextInParens:) title:@"Wrap Next in Parens" keyEquiv:@"9" mods:NSControlKeyMask];
//        [self addParedit:@selector(wrapNextInBrackets:) title:@"Wrap Next in Brackets" keyEquiv:@"[" mods:NSControlKeyMask];
//        [self addParedit:@selector(wrapNextInBraces:) title:@"Wrap Next in Braces" keyEquiv:@"{" mods:NSControlKeyMask];
//        [self addParedit:@selector(extendSelectionToNext:) title:@"Extend Seletion to Next" keyEquiv:@" " mods:NSControlKeyMask | NSAlternateKeyMask];
//    }
}



- (void) insertNewline:(id)sender {
    [super insertNewline:sender];
    [self indentCurrentBody];
}

NSRange LVRangeWithPoints(NSUInteger loc1, NSUInteger loc2) {
    return NSMakeRange(loc1, loc2 - loc1);
}

NSRange LVRangeChoppingOffFront(NSRange r, NSUInteger len) {
    return NSMakeRange(r.location + len, r.length - len);
}

NSRange LVExtendRangeToBeginningPos(NSRange r, NSUInteger pos) {
    return NSMakeRange(pos, r.length + (r.location - pos));
}

- (void) indentCurrentBody {
    NSRange selection = self.selectedRange;
    NSUInteger childIndex;
    LVColl* currentColl = [self.file.topLevelElement deepestCollAtPos:selection.location childsIndex:&childIndex];
    LVColl* highestParentColl = [currentColl highestParentColl];
    
    NSString* wholeString = [[self textStorage] string];
    
    NSRange relevantRange = highestParentColl.fullyEnclosedRange;
    
    NSUInteger firstNewlinePosition = [wholeString rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]
                                                                   options:NSBackwardsSearch
                                                                     range:NSMakeRange(0, relevantRange.location)].location;
    
    if (firstNewlinePosition == NSNotFound)
        firstNewlinePosition = 0;
    else
        firstNewlinePosition++;
    
    relevantRange = LVExtendRangeToBeginningPos(relevantRange, firstNewlinePosition);
    
    NSString* relevantString = [wholeString substringWithRange:relevantRange];
    NSLog(@"[%@]", relevantString);
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    return;
    {
    NSRange relevantRange = highestParentColl.fullyEnclosedRange;
    
    NSUInteger firstNewlinePosition = [wholeString rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]
                                                                   options:NSBackwardsSearch
                                                                     range:NSMakeRange(0, relevantRange.location)].location;
    
    NSLog(@"%ld", firstNewlinePosition);
    
    if (firstNewlinePosition == NSNotFound)
        firstNewlinePosition = 0;
    
    NSLog(@"%@", NSStringFromRange(relevantRange));
    relevantRange = LVExtendRangeToBeginningPos(relevantRange, firstNewlinePosition);
    
    NSLog(@"%@", NSStringFromRange(relevantRange));
    
    NSString* relevantString = [wholeString substringWithRange:relevantRange];
    
    NSRange currentSeekRange = relevantRange;
//    LVColl* lastKnownParent = highestParentColl.parent; // TODO: don't think i need this anymore now that im examining from the beginning of the line instead
    
    while (currentSeekRange.length > 0) {
        NSUInteger nextNewlinePosition = [relevantString rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet]
                                                                         options:0
                                                                           range:currentSeekRange].location;
        
        if (nextNewlinePosition == NSNotFound)
            nextNewlinePosition = NSMaxRange(currentSeekRange);
        else
            nextNewlinePosition++;
        
        NSRange currentLineRange = LVRangeWithPoints(currentSeekRange.location, nextNewlinePosition);
        
        NSUInteger firstNonSpaceCharPos = [relevantString rangeOfCharacterFromSet:[[NSCharacterSet whitespaceCharacterSet] invertedSet]
                                                                          options:0
                                                                            range:currentLineRange].location;
        
//        NSLog(@"%ld", firstNonSpaceCharPos);
        
        NSUInteger currentLineBeginningAbsolutePos = currentLineRange.location + relevantRange.location;
        
        NSUInteger childIndexOfFirstElementOnLine; // this will be helpful
        LVColl* collParentForBeginningOfLine = [self.file.topLevelElement deepestCollAtPos:currentLineBeginningAbsolutePos childsIndex:&childIndexOfFirstElementOnLine];
        
//        NSLog(@"%d", collParentForBeginningOfLine.collType);
        
        NSUInteger expectedStartSpaces;
        
        if (collParentForBeginningOfLine.collType == LVCollTypeTopLevel) {
            expectedStartSpaces = 0;
        }
        else {
            NSUInteger indent;
            if (collParentForBeginningOfLine.collType == LVCollTypeList) {
                indent = 2;
            }
            else {
                indent = 1;
            }
            
            NSUInteger openingTokenRelativePos = (collParentForBeginningOfLine.openingToken.range.location - relevantRange.location);
            
            NSLog(@"a = %ld", collParentForBeginningOfLine.openingToken.range.location);
            NSLog(@"b = %ld", relevantRange.location);
            NSLog(@"open = %ld", openingTokenRelativePos);
        }
        
//        NSLog(@"[%@]", [wholeString substringWithRange:collParentForEndOfLine.fullyEnclosedRange]);
        
        
        // - figure out the proper number of spaces between currentLineRange's start and it's first non-whitespace char
        // - if the range length is different than this, alter the string! (but probably do it in a temp string so our numbers dont skew)
        
//        NSLog(@"%@ --- %@", NSStringFromRange(currentSeekRange), NSStringFromRange(currentLineRange));
        
        currentSeekRange = LVRangeChoppingOffFront(currentSeekRange, currentLineRange.length);
    }
    
    NSLog(@"done with loop");
    }
//    NSLog(@"%@", NSStringFromRange(newlineRange));
}

//(foo
//)



//- (IBAction) raiseSexp:(id)sender {
//    NSRange selection = self.selectedRange;
//    NSUInteger childIndex;
//    LVColl* coll = [self.file.topLevelElement deepestCollAtPos:selection.location childsIndex:&childIndex];
//    
//    if (childIndex < [coll.childElements count]) {
//        id<LVElement> child = [coll.childElements objectAtIndex:childIndex];
//        
//        NSString* newStr = [[[self textStorage] string] substringWithRange:[child fullyEnclosedRange]];
//        
//        NSRange range = NSUnionRange(coll.openingToken.range, coll.closingToken.range);
//        
//        [self setSelectedRange:range];
//        [self delete:self];
//        
//        NSRange r = [self selectedRange];
//        [self insertText:newStr];
//        [self setSelectedRange:r];
//    }
//}
//
//- (void) keyDown:(NSEvent *)theEvent {
//    //    NSLog(@"%ld", [theEvent modifierFlags]);
//    //    if ([[theEvent charactersIgnoringModifiers] isEqualToString:@"r"] && ([theEvent modifierFlags] & NSAlternateKeyMask)) {
//    //        NSLog(@"ok alt-r");
//    //    }
//    //    else {
//    [super keyDown:theEvent];
//    //    }
//}
//
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
//
//- (void) addParedit:(SEL)sel title:(NSString*)title keyEquiv:(NSString*)key mods:(NSUInteger)mods {
//    NSMenu* menu = [[[NSApp menu] itemWithTitle:@"Paredit"] submenu];
//    NSMenuItem* item = [menu addItemWithTitle:title action:sel keyEquivalent:key];
//    [item setKeyEquivalentModifierMask:mods];
//}
//
//- (void) wrapNextInThing:(NSString*)thing {
//    NSRange selection = self.selectedRange;
//    NSUInteger childIndex;
//    LVColl* coll = [self.file.topLevelElement deepestCollAtPos:selection.location childsIndex:&childIndex];
//    
//    if (childIndex < [coll.childElements count]) {
//        id<LVElement> element = [coll.childElements objectAtIndex:childIndex];
//        
//        NSRange rangeToTempDelete = [element fullyEnclosedRange];
//        NSString* theStr = [[[self textStorage] string] substringWithRange:rangeToTempDelete];
//        
//        self.selectedRange = rangeToTempDelete;
//        [self delete:self];
//        [self insertText:[NSString stringWithFormat:thing, theStr]];
//        
//        NSRange rangeToSelect = NSMakeRange(rangeToTempDelete.location + 1, 0);
//        
//        self.selectedRange = rangeToSelect;
//        [self scrollRangeToVisible:self.selectedRange];
//    }
//}
//
//- (IBAction) spliceSexp:(id)sender {
//    NSRange selection = self.selectedRange;
//    NSUInteger childIndex;
//    LVColl* coll = [self.file.topLevelElement deepestCollAtPos:selection.location childsIndex:&childIndex];
//    
//    NSRange outerRange = coll.fullyEnclosedRange;
//    NSUInteger start = NSMaxRange(coll.openingToken.range);
//    NSRange innerRange = NSMakeRange(start, coll.closingToken.range.location - start);
//    
//    NSString* newStr = [[[self textStorage] string] substringWithRange:innerRange];
//    
//    self.selectedRange = outerRange;
//    [self delete:sender];
//    [self insertText:newStr];
//    
//    self.selectedRange = NSMakeRange(outerRange.location, 0);
//    [self scrollRangeToVisible:self.selectedRange];
//}
//
//- (IBAction) extendSelectionToNext:(id)sender {
//    NSRange selection = self.selectedRange;
//    NSUInteger childIndex;
//    LVColl* coll = [self.file.topLevelElement deepestCollAtPos:NSMaxRange(selection) childsIndex:&childIndex];
//    
//    if (childIndex < [coll.childElements count]) {
//        id<LVElement> child = [coll.childElements objectAtIndex:childIndex];
//        NSRange newRange = NSUnionRange(selection, [child fullyEnclosedRange]);
//        
//        self.selectedRange = newRange;
//        [self scrollRangeToVisible:self.selectedRange];
//    }
//}
//
//- (IBAction) cancelOperation:(id)sender {
//    self.selectedRange = NSMakeRange(self.selectedRange.location, 0);
//}
//
//- (IBAction) wrapNextInBrackets:(id)sender {
//    [self wrapNextInThing:@"[%@]"];
//}
//
//- (IBAction) wrapNextInBraces:(id)sender {
//    [self wrapNextInThing:@"{%@}"];
//}
//
//- (IBAction) wrapNextInParens:(id)sender {
//    [self wrapNextInThing:@"(%@)"];
//}
//
//- (IBAction) forwardSexp:(id)sender {
//    NSRange selection = self.selectedRange;
//    NSUInteger childIndex;
//    LVColl* coll = [self.file.topLevelElement deepestCollAtPos:selection.location childsIndex:&childIndex];
//    
//    if (childIndex < [coll.childElements count]) {
//        id<LVElement> element = [coll.childElements objectAtIndex:childIndex];
//        self.selectedRange = NSMakeRange(NSMaxRange([element fullyEnclosedRange]), 0);
//        [self scrollRangeToVisible:self.selectedRange];
//    }
//    else {
//        [self outForwardSexp:sender];
//    }
//}
//
//- (IBAction) backwardSexp:(id)sender {
//    NSRange selection = self.selectedRange;
//    NSUInteger childIndex;
//    LVColl* coll = [self.file.topLevelElement deepestCollAtPos:selection.location childsIndex:&childIndex];
//    
//    if (childIndex > 0) {
//        id<LVElement> element = [coll.childElements objectAtIndex:childIndex - 1];
//        self.selectedRange = NSMakeRange([element fullyEnclosedRange].location, 0);
//        [self scrollRangeToVisible:self.selectedRange];
//    }
//    else {
//        [self outBackwardSexp:sender];
//    }
//}
//
//- (IBAction) outBackwardSexp:(id)sender {
//    NSRange selection = self.selectedRange;
//    NSUInteger childIndex;
//    LVColl* coll = [self.file.topLevelElement deepestCollAtPos:selection.location childsIndex:&childIndex];
//    
//    self.selectedRange = NSMakeRange([coll fullyEnclosedRange].location, 0);
//    [self scrollRangeToVisible:self.selectedRange];
//}
//
//- (IBAction) outForwardSexp:(id)sender {
//    NSRange selection = self.selectedRange;
//    NSUInteger childIndex;
//    LVColl* coll = [self.file.topLevelElement deepestCollAtPos:selection.location childsIndex:&childIndex];
//    
//    self.selectedRange = NSMakeRange(NSMaxRange([coll fullyEnclosedRange]), 0);
//    [self scrollRangeToVisible:self.selectedRange];
//}
//
//- (IBAction) inForwardSexp:(id)sender {
//    NSRange selection = self.selectedRange;
//    NSUInteger childIndex;
//    LVColl* coll = [self.file.topLevelElement deepestCollAtPos:selection.location childsIndex:&childIndex];
//    
//    if (childIndex < [coll.childElements count]) {
//        LVColl* childColl;
//        for (NSUInteger i = childIndex; i < [[coll childElements] count]; i++) {
//            id<LVElement> child = [[coll childElements] objectAtIndex:i];
//            if ([child isColl]) {
//                childColl = child;
//                break;
//            }
//        }
//        
//        if (childColl) {
//            self.selectedRange = NSMakeRange(NSMaxRange([childColl openingToken].range), 0);
//            [self scrollRangeToVisible:self.selectedRange];
//        }
//    }
//}
//
//- (IBAction) inBackwardSexp:(id)sender {
//    NSRange selection = self.selectedRange;
//    NSUInteger childIndex;
//    LVColl* coll = [self.file.topLevelElement deepestCollAtPos:selection.location childsIndex:&childIndex];
//    
//    if (childIndex > 0) {
//        LVColl* childColl;
//        for (NSInteger i = childIndex - 1; i >= 0; i--) {
//            id<LVElement> child = [[coll childElements] objectAtIndex:i];
//            if ([child isColl]) {
//                childColl = child;
//                break;
//            }
//        }
//        
//        if (childColl) {
//            self.selectedRange = NSMakeRange([childColl closingToken].range.location, 0);
//            [self scrollRangeToVisible:self.selectedRange];
//        }
//    }
//}
//
//- (IBAction) killNextSexp:(id)sender {
//    NSRange selection = self.selectedRange;
//    NSUInteger childIndex;
//    LVColl* coll = [self.file.topLevelElement deepestCollAtPos:selection.location childsIndex:&childIndex];
//    
//    if (childIndex < [coll.childElements count]) {
//        id<LVElement> element = [coll.childElements objectAtIndex:childIndex];
//        
//        NSRange rangeToDelete = [element fullyEnclosedRange];
//        self.selectedRange = rangeToDelete;
//        [self delete:sender];
//        self.selectedRange = NSMakeRange(rangeToDelete.location, 0);
//        [self scrollRangeToVisible:self.selectedRange];
//    }
//}
//
//- (void) deleteToEndOfParagraph:(id)sender {
//    NSRange selection = self.selectedRange;
//    NSUInteger childIndex;
//    LVColl* coll = [self.file.topLevelElement deepestCollAtPos:selection.location childsIndex:&childIndex];
//    
//    if (childIndex < [coll.childElements count]) {
//        //        NSArray* deleteChildren = [coll.childElements subarrayWithRange:NSMakeRange(childIndex, [coll.childElements count] - childIndex)];
//        //        id<SDElement> firstDeletableChild = [deleteChildren objectAtIndex:0];
//        //        NSRange range = NSUnionRange([firstDeletableChild fullyEnclosedRange], NSMakeRange([coll closingToken].range.location, 0));
//        
//        NSRange range = NSUnionRange(selection, NSMakeRange([coll closingToken].range.location, 0));
//        
//        if ([self shouldChangeTextInRange:range replacementString:@""]) {
//            [[self textStorage] replaceCharactersInRange:range withString:@""];
//            [self didChangeText];
//        }
//    }
//}

- (void) sd_disableLineWrapping {
    [[self enclosingScrollView] setHasHorizontalScroller:YES];
    [self setHorizontallyResizable:YES];
    NSSize layoutSize = [self maxSize];
    layoutSize.width = layoutSize.height;
    [self setMaxSize:layoutSize];
    [[self textContainer] setWidthTracksTextView:NO];
    [[self textContainer] setContainerSize:layoutSize];
}

@end
