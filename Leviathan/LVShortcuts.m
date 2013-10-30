//
//  LVShortcuts.m
//  Leviathan
//
//  Created by Steven on 10/28/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVShortcuts.h"

#import "doc.h"
#import "element.h"

@implementation LVShortcut
@end


@interface LVShortcuts ()

@property NSMutableArray* shortcuts;

@end

@implementation LVShortcuts

- (id) init {
    if (self = [super init]) {
        self.shortcuts = [NSMutableArray array];
        
        [self add:@selector(outBackwardSexp:) title:@"Out Backward" keyEquiv:@"u" mods:@[@"CTRL", @"ALT"]];
        [self add:@selector(forwardSexp:) title:@"Forward" keyEquiv:@"f" mods:@[@"CTRL", @"ALT"]];
        [self add:@selector(outForwardSexp:) title:@"Out Forward" keyEquiv:@"n" mods:@[@"CTRL", @"ALT"]];
        [self add:@selector(raiseSexp:) title:@"Raise" keyEquiv:@"r" mods:@[@"ALT"]];
    }
    return self;
}

- (void) add:(SEL)action title:(NSString*)title keyEquiv:(NSString*)keyEquiv mods:(NSArray*)mods {
    LVShortcut* shortcut = [[LVShortcut alloc] init];
    shortcut.title = title;
    shortcut.keyEquiv = keyEquiv;
    shortcut.target = self;
    shortcut.action = action;
    shortcut.mods = mods;
    [self.shortcuts addObject:shortcut];
    
//    NSMenu* menu = [[[NSApp menu] itemWithTitle:@"Paredit"] submenu];
//    NSMenuItem* item = [menu insertItemWithTitle:shortcut.title action:shortcut.action keyEquivalent:shortcut.keyEquiv atIndex:0];
//    NSUInteger realMods = 0;
//    if ([mods containsObject:@"CTRL"]) realMods |= NSControlKeyMask;
//    if ([mods containsObject:@"ALT"]) realMods |= NSAlternateKeyMask;
//    [item setKeyEquivalentModifierMask:realMods];
    
    // TODO: insert the target into the responder chain, between self and self.nextResponder
}

- (void) outBackwardSexp:(NSEvent*)event {
    NSRange selection = self.textView.selectedRange;
    
    size_t childIndex;
    LVColl* parent = LVFindElementAtPosition(self.clojureText.doc, selection.location, &childIndex);
    
    self.textView.selectedRange = NSMakeRange(LVGetAbsolutePosition((void*)parent), 0);
    [self.textView scrollRangeToVisible:self.textView.selectedRange];
}

- (void) outForwardSexp:(NSEvent*)event {
    NSRange selection = self.textView.selectedRange;
    
    size_t childIndex;
    LVColl* parent = LVFindElementAtPosition(self.clojureText.doc, selection.location, &childIndex);
    
    self.textView.selectedRange = NSMakeRange(LVGetAbsolutePosition((void*)parent) + LVElementLength((void*)parent), 0);
    [self.textView scrollRangeToVisible:self.textView.selectedRange];
}

- (void) forwardSexp:(NSEvent*)event {
    NSRange selection = self.textView.selectedRange;
    
    size_t childIndex;
    LVColl* parent = LVFindElementAtPosition(self.clojureText.doc, selection.location, &childIndex);
    
    LVElement* elementToMoveToEndOf = NULL;
    size_t posAfterElement;
    
    LVElement* semanticChildren[parent->children_len];
    size_t semanticChildrenCount;
    LVGetSemanticDirectChildren(parent, childIndex, semanticChildren, &semanticChildrenCount);
    
    for (int i = 0; i < semanticChildrenCount; i++) {
        LVElement* semanticChild = semanticChildren[i];
        
        posAfterElement = LVGetAbsolutePosition(semanticChild) + LVElementLength(semanticChild);
        
        // are we in the middle of the semantic element?
        if (selection.location < posAfterElement) {
            // if so, great! we'll use this one
            elementToMoveToEndOf = semanticChild;
            break;
        }
    }
    
    if (elementToMoveToEndOf) {
        self.textView.selectedRange = NSMakeRange(posAfterElement, 0);
        [self.textView scrollRangeToVisible:self.textView.selectedRange];
    }
    else {
        [self outForwardSexp:event];
    }
}

- (void) raiseSexp:(NSEvent*)event {
//    NSRange selection = self.textView.selectedRange;
//    
//    size_t childIndex;
//    LVColl* parent = LVFindElementAtPosition(self.clojureText.doc, selection.location, &childIndex);
//    
//    LVElement* elementToRaise = NULL;
//    size_t posAfterElement;
//    
//    LVElement* semanticChildren[parent->children_len];
//    size_t semanticChildrenCount;
//    LVGetSemanticDirectChildren(parent, childIndex, semanticChildren, &semanticChildrenCount);
//    
//    for (int i = 0; i < semanticChildrenCount; i++) {
//        LVElement* semanticChild = semanticChildren[i];
//        
//        posAfterElement = LVGetAbsolutePosition(semanticChild) + LVElementLength(semanticChild);
//        
//        // are we in the middle of the semantic element?
//        if (selection.location < posAfterElement) {
//            // if so, great! we'll use this one
//            elementToRaise = semanticChild;
//            break;
//        }
//    }
//    
//    if (elementToRaise) {
//        LVElement* child = elementToRaise;
//        
//        size_t relativeOffset = selection.location - LVGetAbsolutePosition(child);
//        
//        LVColl* grandparent = parent->parent;
//        size_t parentIndex = LVGetElementIndexInSiblings((void*)parent);
//        
//        NSRange oldParentRange = NSMakeRange(LVGetAbsolutePosition((void*)parent), LVElementLength((void*)parent));
//        
//        grandparent->children[parentIndex] = child;
//        child->parent = grandparent;
//        
//        // TODO: re-indent grandparent (or maybe just child?) right here
//        
//        bstring str = LVStringForElement(child);
//        NSString* newstr = [NSString stringWithFormat:@"%s", str->data];
//        bdestroy(str);
//        
//        [self replace:oldParentRange string:newstr cursor:oldParentRange.location + relativeOffset];
//    }
}

- (void) replace:(NSRange)r string:(NSString*)str cursor:(NSUInteger)newpos {
    NSString* oldString = [self.clojureText.string substringWithRange:r];
    NSRange newRange = NSMakeRange(r.location, [str length]);
    
    [[[self.clojureText undoManager] prepareWithInvocationTarget:self] replace:newRange
                                                                        string:oldString
                                                                        cursor:self.textView.selectedRange.location];
    
    [self.clojureText replaceCharactersInRange:r withString:str];
    self.textView.selectedRange = NSMakeRange(newpos, 0);
}

@end
