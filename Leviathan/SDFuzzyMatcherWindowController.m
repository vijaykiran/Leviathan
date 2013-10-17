//
//  SDFuzzyMatcherWindowController.m
//  Oxide
//
//  Created by Steven on 7/28/13.
//  Copyright (c) 2013 Giant Robot Software. All rights reserved.
//

#import "SDFuzzyMatcherWindowController.h"

#import "SDChoice.h"


@interface SDFuzzyMatcherWindowController ()

@property NSString* sofar;

@property IBOutlet NSArrayController* choicesArrayController;
@property IBOutlet NSTextField* tryTextField;

@property IBOutlet NSScrollView* choicesTableContainer;
@property IBOutlet NSTableView* choicesTable;

@property NSIndexSet* selectionIndexes;
@property long selection;

@property long chosenIdx;
@property BOOL actuallyChoseOne;

@end



@implementation SDFuzzyMatcherWindowController

- (NSString*) windowNibName {
    return @"SDFuzzyMatcherWindow";
}

- (void) windowDidLoad {
    [super windowDidLoad];
    
    self.choicesTable.target = self;
    self.choicesTable.doubleAction = @selector(chooseByDoubleClicking:);
    
    [self resizeWindowOrElse];
    
    [self.choicesTable sizeLastColumnToFit];
    [self.choicesTable sizeToFit];
    
    self.choicesArrayController.sortDescriptors = @[[[NSSortDescriptor alloc] initWithKey:@"score" ascending:NO]];
}

- (void) positionWindowAndShow {
    [[self window] center];
    [self showWindow:self];
}

- (void) resizeWindowOrElse {
    CGFloat margin = 15;
    
    NSRect windowFrame = [self.window frame];
    NSRect innerWindowFrame = [[self.window contentView] frame];
    
    CGFloat diffX = windowFrame.size.width - innerWindowFrame.size.width;
    CGFloat diffY = windowFrame.size.height - innerWindowFrame.size.height;
    
    NSRect tableFrame = self.choicesTableContainer.frame;
    tableFrame.size.height = 22 * self.listSize.height;
    tableFrame.size.width = 10 * self.listSize.width;
    tableFrame.origin = NSMakePoint(margin, margin);
    
    NSRect fieldFrame;
    CGFloat extraWindowHeight = 0;
    
    fieldFrame = self.tryTextField.frame;
    fieldFrame.origin.y = margin + NSMaxY(tableFrame);
    fieldFrame.origin.x = margin;
    fieldFrame.size.width = tableFrame.size.width;
    
    extraWindowHeight = fieldFrame.size.height + margin;
    
    windowFrame.size.width = diffX + tableFrame.size.width + (margin * 2.0);
    windowFrame.size.height = diffY + tableFrame.size.height + (margin * 2.0) + extraWindowHeight;
    
    [self.window setFrame:windowFrame display:NO];
    self.choicesTableContainer.frame = tableFrame;
    
    self.tryTextField.frame = fieldFrame;
}

- (void) chooseCurrentChoice {
    self.actuallyChoseOne = YES;
    self.chosenIdx = self.selection;
    
    [self close];
}

- (void) justGiveUp {
    [self close];
}

- (void)controlTextDidChange:(NSNotification *)aNotification {
    NSString* val = [self.tryTextField stringValue];
    
    for (SDChoice* choice in self.choices) {
        choice.tryString = val;
        [choice updateScore];
    }
    
    [self.choicesArrayController rearrangeObjects];
    
    self.selection = 0;
    [self.choicesTable scrollRowToVisible:[self.choicesTable selectedRow]];
}

- (void) setSelectionIndexes:(NSIndexSet *)selectionIndexes {
    self.selection = [selectionIndexes firstIndex];
}

- (IBAction) chooseByDoubleClicking:(id)sender {
    if ([self.choicesTable selectedRow] > -1)
        [self chooseCurrentChoice];
    else
        NSBeep();
}

- (NSIndexSet*) selectionIndexes {
    return [NSIndexSet indexSetWithIndex:self.selection];
}

+ (NSSet*) keyPathsForValuesAffectingSelectionIndexes {
    return [NSSet setWithArray: @[@"selection"]];
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)command {
//    NSLog(@"%@", NSStringFromSelector(command));
    
    if (command == @selector(cancelOperation:)) {
        [self justGiveUp];
        return YES;
    }
    if (command == @selector(insertNewline:)) {
        [self chooseCurrentChoice];
        return YES;
    }
    if (command == @selector(moveUp:)) {
        self.selection = MAX(0, self.selection - 1);
        [self.choicesTable scrollRowToVisible:[self.choicesTable selectedRow]];
        return YES;
    }
    if (command == @selector(moveDown:)) {
        self.selection = MIN([self.choices count] - 1, self.selection + 1);
        [self.choicesTable scrollRowToVisible:[self.choicesTable selectedRow]];
        return YES;
    }
    
    return NO;
}

- (void) windowWillClose:(NSNotification *)notification {
    if (self.actuallyChoseOne) {
        if (self.choseCallback) {
            SDChoice* choice = [[self.choicesArrayController arrangedObjects] objectAtIndex:self.selection];
            long idx = [self.choices indexOfObject:choice];
            self.choseCallback(idx);
        }
    }
    
    [self.killedDelegate btwImDead:self];
}

@end
