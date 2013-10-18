//
//  LVProjectWindowController.m
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVProjectWindowController.h"

#import "LVTabView.h"
#import "LVTab.h"
#import "LVEditor.h"

#import "SDFuzzyMatcher.h"

@interface LVProjectWindowController ()

@property (weak) id<LVProjectWindowController> delegate;
@property (weak) IBOutlet LVTabView* tabView;

@end

@implementation LVProjectWindowController

+ (LVProjectWindowController*) openWith:(NSURL*)url delegate:(id<LVProjectWindowController>)delegate {
    LVProjectWindowController* c = [[LVProjectWindowController alloc] init];
    c.project = [LVProject openProjectAtURL:url];
    c.delegate = delegate;
    [c showWindow:nil];
    return c;
}

- (NSString*) windowNibName {
    return @"ProjectWindow";
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self openProjectTab:nil];
}

- (void) windowWillClose:(NSNotification *)notification {
    [self.delegate projectWindowClosed:self];
}

- (IBAction) closeProjectTabSplit:(id)sender {
    if ([[self.tabView.currentTab splits] count] == 1) {
        [self closeProjectTab:sender];
    }
    else {
        // TODO: check for unsaved file in split (it always has exactly one file)
        [self.tabView.currentTab closeCurrentSplit];
    }
}

- (IBAction) jumpToFile:(id)sender {
    NSArray* files = [self.project.files filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"fileURL != NULL"]];
    
    NSArray* names = [files valueForKey:@"longName"];
    CGFloat maxLen = [[files valueForKeyPath:@"longName.@max.length"] doubleValue];
    
    [SDFuzzyMatcher showChoices:names
                      charsWide:maxLen * 2.2 / 3.0
                      linesTall:10
                    windowTitle:@"Jump to File"
                  choseCallback:^(long chosenIndex) {
                      LVFile* file = [files objectAtIndex:chosenIndex];
                      [self replaceCurrentEditorWithFile:file];
                  }];
}

- (IBAction) jumpToDefinition:(id)sender {
    NSLog(@"not implemented yet...");
}

- (void) replaceCurrentEditorWithFile:(LVFile*)file {
    // TODO: dont do it if it's unsaved!
    
    [self.tabView.currentTab.currentEditor startEditingFile:file];
    [self.tabView titlesChanged];
}

- (IBAction) closeProjectTab:(id)sender {
    if ([self.tabView.tabs count] == 1) {
        [self closeProjectWindow:sender];
    }
    else {
        // TODO: check for unsaved files in tab
        [self.tabView closeCurrentTab];
    }
}

- (IBAction) openProjectTab:(id)sender {
    LVFile* file = [self.project openNewFile];
    LVEditor* editorController = [[LVEditor alloc] init];
    
    LVTab* tab = [[LVTab alloc] init];
    [tab startWithEditor: editorController];
    
    [editorController startEditingFile:file];
    
    [self.tabView addTab:tab];
}

- (IBAction) closeProjectWindow:(id)sender {
    // TODO: check for unsaved files in all tabs and their splits
    [self close];
}

- (IBAction) addSplitToEast:(id)sender {
    LVFile* file = [self.project openNewFile];
    LVEditor* editorController = [[LVEditor alloc] init];
    
    [self.tabView.currentTab addEditor:editorController
                           inDirection:LVSplitDirectionEast];
    
    [editorController startEditingFile:file];
}

@end
