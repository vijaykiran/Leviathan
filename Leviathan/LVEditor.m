//
//  LVEditorViewController.m
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVEditor.h"

#import "LVPreferences.h"

@implementation LVEditor

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) defaultsFontChanged:(NSNotification*)note {
    [self.file.textStorage rehighlight];
}

- (NSString*) nibName {
    return @"Editor";
}

- (NSUndoManager *)undoManagerForTextView:(NSTextView *)aTextView {
    return self.file.textStorage.undoManager;
}

- (void) jumpToDefinition:(LVDefinition*)def {
    size_t absPos = def.defName->token->pos;
    self.textView.selectedRange = NSMakeRange(absPos, CFStringGetLength(def.defName->token->string));
    double delayInSeconds = 0.25;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self.textView centerSelectionInVisibleArea:nil];
    });
}

- (void) startEditingFile:(LVFile*)file {
    self.file = file;
    self.title = file.shortName;
    self.textView.file = file;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(defaultsFontChanged:) name:LVDefaultsFontChangedNotification object:nil];
    
    [[self.textView layoutManager] replaceTextStorage:file.textStorage];
    [[self.textView undoManager] removeAllActions];
    
    [self.textView setSelectedRange:NSMakeRange(0, 0)];
    
    self.file.textStorage.delegate = self;
}

- (void) makeFirstResponder {
    [[self.view window] makeFirstResponder: self.textView];
}

- (void) textViewWasFocused:(NSTextView*)view {
    [self.delegate editorWasSelected:self];
}

- (IBAction) saveDocument:(id)sender {
    [self.file save];
}







- (void) textStorageDidProcessEditing:(NSNotification *)notification {
    if ([self.textView.undoManager isUndoing] || [self.textView.undoManager isRedoing])
        return;
    
    [self.textView.undoManager beginUndoGrouping];
    
    double delayInSeconds = 0.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self indentText];
        [self.textView.undoManager endUndoGrouping];
    });
}

void LVMakeTokenMutable2(LVToken* token) {
    CFMutableStringRef tmpStr = CFStringCreateMutableCopy(NULL, 0, token->string);
    CFRelease(token->string);
    token->string = tmpStr;
}

size_t LVGetIndentationForInsideOfColl2(LVColl* coll) {
    size_t count = 0;
    
    LVAtom* openingAtom = (LVAtom*)coll->children[0];
    for (LVToken* token = openingAtom->token; !((token->tokenType & LVTokenType_Newlines) || (token->prevToken == NULL)); token = token->prevToken) {
        count += CFStringGetLength(token->string);
    }
    
    return count;
}

- (void) indentText {
    // find each newline TOKEN
    // NEVER MIND: empty-out any whitespace tokens IMMEDIATELY BEFORE IT
    // something else
    
    LVDoc* doc = self.file.textStorage.doc;
    
    for (LVToken* tok = doc->firstToken->nextToken; tok->nextToken; tok = tok->nextToken) {
        if (tok->tokenType & LVTokenType_Newlines) {
            LVToken* nextTok = tok->nextToken;
            LVMakeTokenMutable2(nextTok);
            CFMutableStringRef tmpStr = (CFMutableStringRef)nextTok->string;
            
            if (nextTok->tokenType & LVTokenType_Spaces) {
                // empty it out
                CFStringDelete(tmpStr, CFRangeMake(0, CFStringGetLength(tmpStr)));
            }
            
            // insert that many spaces to the beginning of NextTok
            
            LVAtom* newlineAtom = tok->atom;
            LVColl* newlineParent = newlineAtom->parent;
            size_t indentationForInsideOfColl = LVGetIndentationForInsideOfColl2(newlineParent);
            
            CFMutableStringRef spacesString = CFStringCreateMutable(NULL, 0);
            CFStringPad(spacesString, CFSTR(" "), indentationForInsideOfColl, 0);
            
            CFStringInsert(tmpStr, 0, spacesString);
            
            CFRelease(spacesString);
        }
    }
    
    // rebuild string
    CFStringRef s = LVStringForColl(doc->topLevelColl);
    NSString* newstr = (__bridge_transfer NSString*)s;
    //    NSLog(@"%@", newstr);
    //    NSLog(@"%@", NSStringFromRange(NSMakeRange(0, self.textStorage.length)));
    NSRange r = self.textView.selectedRange;
    
    if (![self.file.textStorage.string isEqualToString:newstr]) {
        [self.textView replace:NSMakeRange(0, self.file.textStorage.length) string:newstr cursor:r.location];
    }
    
    //    [self.file.textStorage replaceCharactersInRange:NSMakeRange(0, self.textStorage.length) withString:newstr];
    //    self.selectedRange = r;
}

@end
