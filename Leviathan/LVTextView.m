//
//  LVTextView.m
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVTextView.h"

#import "SDTheme.h"

@implementation LVTextView

- (BOOL) becomeFirstResponder {
    BOOL did = [super becomeFirstResponder];
    if (did) {
        [self.customDelegate textViewWasFocused:self];
    }
    return did;
}

- (void) awakeFromNib {
    self.enclosingScrollView.verticalScroller.knobStyle = NSScrollerKnobStyleLight;
    self.enclosingScrollView.horizontalScroller.knobStyle = NSScrollerKnobStyleLight;
    
    self.font = [NSFont fontWithName:@"Menlo" size:12]; // TODO: replace this with NSUserDefaults somehow
    self.backgroundColor = SDColorFromHex([[[SDTheme temporaryTheme] attributes] objectForKey:SDThemeBackgroundColor]);
    self.insertionPointColor = SDColorFromHex([[[SDTheme temporaryTheme] attributes] objectForKey:SDThemeCursorColor]);
    
    {
        NSDictionary* style = [[[SDTheme temporaryTheme] attributes] objectForKey:@"selection_style"];
        NSMutableDictionary* selectionAttrs = [NSMutableDictionary dictionary];
        
        if ([style objectForKey:@"ForegroundColor"])
            selectionAttrs[NSForegroundColorAttributeName] = SDColorFromHex([style objectForKey:@"ForegroundColor"]);
        
        if ([style objectForKey:@"BackgroundColor"])
            selectionAttrs[NSBackgroundColorAttributeName] = SDColorFromHex([style objectForKey:@"BackgroundColor"]);
        
        self.selectedTextAttributes = selectionAttrs;
    }
    
    
    
    
    
    [self sd_disableLineWrapping];
    [super setTextContainerInset:NSMakeSize(0.0f, 4.0f)];
    
    static BOOL menusSetup;
    if (!menusSetup) {
        menusSetup = YES;
        
        [self addParedit:@selector(raiseSexp:) title:@"Raise" keyEquiv:@"r" mods:NSControlKeyMask];
        [self addParedit:@selector(spliceSexp:) title:@"Splice" keyEquiv:@"s" mods:NSControlKeyMask];
        [self addParedit:@selector(forwardSexp:) title:@"Forward" keyEquiv:@"f" mods:NSControlKeyMask | NSAlternateKeyMask];
        [self addParedit:@selector(backwardSexp:) title:@"Backward" keyEquiv:@"b" mods:NSControlKeyMask | NSAlternateKeyMask];
        [self addParedit:@selector(outBackwardSexp:) title:@"Out Backward" keyEquiv:@"u" mods:NSControlKeyMask | NSAlternateKeyMask];
        [self addParedit:@selector(outForwardSexp:) title:@"Out Forward" keyEquiv:@"n" mods:NSControlKeyMask | NSAlternateKeyMask];
        [self addParedit:@selector(inForwardSexp:) title:@"In Forward" keyEquiv:@"d" mods:NSControlKeyMask | NSAlternateKeyMask];
        [self addParedit:@selector(inBackwardSexp:) title:@"In Backward" keyEquiv:@"p" mods:NSControlKeyMask | NSAlternateKeyMask];
        [self addParedit:@selector(killNextSexp:) title:@"Kill Next" keyEquiv:@"k" mods:NSControlKeyMask | NSAlternateKeyMask];
        [self addParedit:@selector(wrapNextInParens:) title:@"Wrap Next in Parens" keyEquiv:@"9" mods:NSControlKeyMask];
        [self addParedit:@selector(wrapNextInBrackets:) title:@"Wrap Next in Brackets" keyEquiv:@"[" mods:NSControlKeyMask];
        [self addParedit:@selector(wrapNextInBraces:) title:@"Wrap Next in Braces" keyEquiv:@"{" mods:NSControlKeyMask];
        [self addParedit:@selector(extendSelectionToNext:) title:@"Extend Seletion to Next" keyEquiv:@" " mods:NSControlKeyMask | NSAlternateKeyMask];
    }
}





- (IBAction) raiseSexp:(id)sender {
    NSRange selection = self.selectedRange;
    NSUInteger childIndex;
    LVColl* coll = [self.file.topLevelElement deepestCollAtPos:selection.location childsIndex:&childIndex];
    
    if (childIndex < [coll.childElements count]) {
        id<LVElement> child = [coll.childElements objectAtIndex:childIndex];
        
        NSString* newStr = [[[self textStorage] string] substringWithRange:[child fullyEnclosedRange]];
        
        NSRange range = NSUnionRange(coll.openingToken.range, coll.closingToken.range);
        
        [self setSelectedRange:range];
        [self delete:self];
        
        NSRange r = [self selectedRange];
        [self insertText:newStr];
        [self setSelectedRange:r];
    }
}

- (void) keyDown:(NSEvent *)theEvent {
    //    NSLog(@"%ld", [theEvent modifierFlags]);
    //    if ([[theEvent charactersIgnoringModifiers] isEqualToString:@"r"] && ([theEvent modifierFlags] & NSAlternateKeyMask)) {
    //        NSLog(@"ok alt-r");
    //    }
    //    else {
    [super keyDown:theEvent];
    //    }
}

//- (void) insertNewline:(id)sender {
//    NSLog(@"bla");
//}

- (void) insertText:(id)insertString {
    NSDictionary* balancers = @{@"(": @")", @"[": @"]", @"{": @"}"};
    NSString* origString = insertString;
    NSString* toBalance = [balancers objectForKey:origString];
    
    if (toBalance) {
        NSRange selection = self.selectedRange;
        NSString* subString = [[[self textStorage] string] substringWithRange:selection];
        
        if (selection.length == 0) {
            [super insertText:insertString];
            [super insertText:toBalance];
            [self moveBackward:self];
        }
        else {
            NSString* newString = [NSString stringWithFormat:@"%@%@%@", origString, subString, toBalance];
            [self insertText:newString];
        }
        
        return;
    }
    
    if ([[balancers allKeysForObject:origString] count] > 0) {
        NSUInteger loc = self.selectedRange.location;
        NSString* wholeString = [[self textStorage] string];
        
        if (loc < [wholeString length]) {
            unichar c = [wholeString characterAtIndex:loc];
            if (c == [origString characterAtIndex:0]) {
                [self moveForward:self];
            }
        }
        
        return;
    }
    
    [super insertText:insertString];
}

- (void) addParedit:(SEL)sel title:(NSString*)title keyEquiv:(NSString*)key mods:(NSUInteger)mods {
    NSMenu* menu = [[[NSApp menu] itemWithTitle:@"Paredit"] submenu];
    NSMenuItem* item = [menu addItemWithTitle:title action:sel keyEquivalent:key];
    [item setKeyEquivalentModifierMask:mods];
}

- (void) wrapNextInThing:(NSString*)thing {
    NSRange selection = self.selectedRange;
    NSUInteger childIndex;
    LVColl* coll = [self.file.topLevelElement deepestCollAtPos:selection.location childsIndex:&childIndex];
    
    if (childIndex < [coll.childElements count]) {
        id<LVElement> element = [coll.childElements objectAtIndex:childIndex];
        
        NSRange rangeToTempDelete = [element fullyEnclosedRange];
        NSString* theStr = [[[self textStorage] string] substringWithRange:rangeToTempDelete];
        
        self.selectedRange = rangeToTempDelete;
        [self delete:self];
        [self insertText:[NSString stringWithFormat:thing, theStr]];
        
        NSRange rangeToSelect = NSMakeRange(rangeToTempDelete.location + 1, 0);
        
        self.selectedRange = rangeToSelect;
        [self scrollRangeToVisible:self.selectedRange];
    }
}

- (IBAction) spliceSexp:(id)sender {
    NSRange selection = self.selectedRange;
    NSUInteger childIndex;
    LVColl* coll = [self.file.topLevelElement deepestCollAtPos:selection.location childsIndex:&childIndex];
    
    NSRange outerRange = coll.fullyEnclosedRange;
    NSUInteger start = NSMaxRange(coll.openingToken.range);
    NSRange innerRange = NSMakeRange(start, coll.closingToken.range.location - start);
    
    NSString* newStr = [[[self textStorage] string] substringWithRange:innerRange];
    
    self.selectedRange = outerRange;
    [self delete:sender];
    [self insertText:newStr];
    
    self.selectedRange = NSMakeRange(outerRange.location, 0);
    [self scrollRangeToVisible:self.selectedRange];
}

- (IBAction) extendSelectionToNext:(id)sender {
    NSRange selection = self.selectedRange;
    NSUInteger childIndex;
    LVColl* coll = [self.file.topLevelElement deepestCollAtPos:NSMaxRange(selection) childsIndex:&childIndex];
    
    if (childIndex < [coll.childElements count]) {
        id<LVElement> child = [coll.childElements objectAtIndex:childIndex];
        NSRange newRange = NSUnionRange(selection, [child fullyEnclosedRange]);
        
        self.selectedRange = newRange;
        [self scrollRangeToVisible:self.selectedRange];
    }
}

- (IBAction) cancelOperation:(id)sender {
    self.selectedRange = NSMakeRange(self.selectedRange.location, 0);
}

- (IBAction) wrapNextInBrackets:(id)sender {
    [self wrapNextInThing:@"[%@]"];
}

- (IBAction) wrapNextInBraces:(id)sender {
    [self wrapNextInThing:@"{%@}"];
}

- (IBAction) wrapNextInParens:(id)sender {
    [self wrapNextInThing:@"(%@)"];
}

- (IBAction) forwardSexp:(id)sender {
    NSRange selection = self.selectedRange;
    NSUInteger childIndex;
    LVColl* coll = [self.file.topLevelElement deepestCollAtPos:selection.location childsIndex:&childIndex];
    
    if (childIndex < [coll.childElements count]) {
        id<LVElement> element = [coll.childElements objectAtIndex:childIndex];
        self.selectedRange = NSMakeRange(NSMaxRange([element fullyEnclosedRange]), 0);
        [self scrollRangeToVisible:self.selectedRange];
    }
    else {
        [self outForwardSexp:sender];
    }
}

- (IBAction) backwardSexp:(id)sender {
    NSRange selection = self.selectedRange;
    NSUInteger childIndex;
    LVColl* coll = [self.file.topLevelElement deepestCollAtPos:selection.location childsIndex:&childIndex];
    
    if (childIndex > 0) {
        id<LVElement> element = [coll.childElements objectAtIndex:childIndex - 1];
        self.selectedRange = NSMakeRange([element fullyEnclosedRange].location, 0);
        [self scrollRangeToVisible:self.selectedRange];
    }
    else {
        [self outBackwardSexp:sender];
    }
}

- (IBAction) outBackwardSexp:(id)sender {
    NSRange selection = self.selectedRange;
    NSUInteger childIndex;
    LVColl* coll = [self.file.topLevelElement deepestCollAtPos:selection.location childsIndex:&childIndex];
    
    self.selectedRange = NSMakeRange([coll fullyEnclosedRange].location, 0);
    [self scrollRangeToVisible:self.selectedRange];
}

- (IBAction) outForwardSexp:(id)sender {
    NSRange selection = self.selectedRange;
    NSUInteger childIndex;
    LVColl* coll = [self.file.topLevelElement deepestCollAtPos:selection.location childsIndex:&childIndex];
    
    self.selectedRange = NSMakeRange(NSMaxRange([coll fullyEnclosedRange]), 0);
    [self scrollRangeToVisible:self.selectedRange];
}

- (IBAction) inForwardSexp:(id)sender {
    NSRange selection = self.selectedRange;
    NSUInteger childIndex;
    LVColl* coll = [self.file.topLevelElement deepestCollAtPos:selection.location childsIndex:&childIndex];
    
    if (childIndex < [coll.childElements count]) {
        LVColl* childColl;
        for (NSUInteger i = childIndex; i < [[coll childElements] count]; i++) {
            id<LVElement> child = [[coll childElements] objectAtIndex:i];
            if ([child isColl]) {
                childColl = child;
                break;
            }
        }
        
        if (childColl) {
            self.selectedRange = NSMakeRange(NSMaxRange([childColl openingToken].range), 0);
            [self scrollRangeToVisible:self.selectedRange];
        }
    }
}

- (IBAction) inBackwardSexp:(id)sender {
    NSRange selection = self.selectedRange;
    NSUInteger childIndex;
    LVColl* coll = [self.file.topLevelElement deepestCollAtPos:selection.location childsIndex:&childIndex];
    
    if (childIndex > 0) {
        LVColl* childColl;
        for (NSInteger i = childIndex - 1; i >= 0; i--) {
            id<LVElement> child = [[coll childElements] objectAtIndex:i];
            if ([child isColl]) {
                childColl = child;
                break;
            }
        }
        
        if (childColl) {
            self.selectedRange = NSMakeRange([childColl closingToken].range.location, 0);
            [self scrollRangeToVisible:self.selectedRange];
        }
    }
}

- (IBAction) killNextSexp:(id)sender {
    NSRange selection = self.selectedRange;
    NSUInteger childIndex;
    LVColl* coll = [self.file.topLevelElement deepestCollAtPos:selection.location childsIndex:&childIndex];
    
    if (childIndex < [coll.childElements count]) {
        id<LVElement> element = [coll.childElements objectAtIndex:childIndex];
        
        NSRange rangeToDelete = [element fullyEnclosedRange];
        self.selectedRange = rangeToDelete;
        [self delete:sender];
        self.selectedRange = NSMakeRange(rangeToDelete.location, 0);
        [self scrollRangeToVisible:self.selectedRange];
    }
}

- (void) deleteToEndOfParagraph:(id)sender {
    NSRange selection = self.selectedRange;
    NSUInteger childIndex;
    LVColl* coll = [self.file.topLevelElement deepestCollAtPos:selection.location childsIndex:&childIndex];
    
    if (childIndex < [coll.childElements count]) {
        //        NSArray* deleteChildren = [coll.childElements subarrayWithRange:NSMakeRange(childIndex, [coll.childElements count] - childIndex)];
        //        id<SDElement> firstDeletableChild = [deleteChildren objectAtIndex:0];
        //        NSRange range = NSUnionRange([firstDeletableChild fullyEnclosedRange], NSMakeRange([coll closingToken].range.location, 0));
        
        NSRange range = NSUnionRange(selection, NSMakeRange([coll closingToken].range.location, 0));
        
        if ([self shouldChangeTextInRange:range replacementString:@""]) {
            [[self textStorage] replaceCharactersInRange:range withString:@""];
            [self didChangeText];
        }
    }
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

@end
