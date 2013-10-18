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

#import "LVAtom.h"

@interface LVProjectWindowController ()

@property (weak) id<LVProjectWindowController> delegate;
@property (weak) IBOutlet LVTabView* tabView;

@end

@implementation LVProjectWindowController

+ (LVProjectWindowController*) openWith:(NSURL*)url delegate:(id<LVProjectWindowController>)delegate {
    LVProjectWindowController* c = [[LVProjectWindowController alloc] init];
    c.project = [LVProject openProjectAtURL:url];
    c.delegate = delegate;
    
    [c setWindowFrameAutosaveName:[url path]];
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
    if ([[self.tabView.currentTab editors] count] == 1) {
        [self closeProjectTab:sender];
    }
    else {
        // TODO: check for unsaved file in split (it always has exactly one file)
        [self.tabView.currentTab closeCurrentSplit];
    }
}

- (IBAction) openTestInSplit:(id)sender {
    NSString* path = self.tabView.currentTab.currentEditor.file.longName;
    
    path = [path substringWithRange:NSMakeRange(4, [path length] - 4 - 4)];
    path = [NSString stringWithFormat:@"test/%@_test.clj", path];
    
    LVFile* found;
    
    for (LVFile* file in self.project.files) {
        if ([file.longName isEqualToString: path]) {
            found = file;
            break;
        }
    }
    
    if (found) {
        LVEditor* editorController = [[LVEditor alloc] init];
        
        [self.tabView.currentTab addEditor:editorController
                               inDirection:LVSplitDirectionEast];
        
        [editorController startEditingFile:found];
        [self.tabView titlesChanged];
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

- (void) openDefinition:(SDDefinition*)def inFile:(LVFile*)file {
    if (![self switchToOpenFile:file]) {
        LVEditor* editorController = [[LVEditor alloc] init];
        
        LVTab* tab = [[LVTab alloc] init];
        [tab startWithEditor: editorController];
        
        [self.tabView addTab:tab];
        
        [editorController startEditingFile:file];
        [self.tabView titlesChanged];
    }
    
    [self.tabView.currentTab.currentEditor jumpToDefinition:def];
}

- (IBAction) jumpToDefinition:(id)sender {
    NSMutableArray* defFiles = [NSMutableArray array];
    NSMutableArray* defDefs = [NSMutableArray array];
    NSMutableArray* readableNames = [NSMutableArray array];
    
    for (LVFile* file in self.project.files) {
        NSMutableArray* defs = [NSMutableArray array];
        [[file topLevelElement] findDefinitions:defs];
        
        for (SDDefinition* def in defs) {
            [defFiles addObject:file];
            [defDefs addObject:def];
            [readableNames addObject:[NSString stringWithFormat:@"%@ %@", def.defType.token.val, def.defName.token.val]];
        }
    }
    
    CGFloat maxLen = [[readableNames valueForKeyPath:@"@max.length"] doubleValue];
    
    [SDFuzzyMatcher showChoices:readableNames
                      charsWide:maxLen * 2.2 / 3.0
                      linesTall:10
                    windowTitle:@"Jump to File"
                  choseCallback:^(long chosenIndex) {
                      [self openDefinition:[defDefs objectAtIndex:chosenIndex]
                                    inFile:[defFiles objectAtIndex:chosenIndex]];
                  }];
}

- (BOOL) switchToOpenFile:(LVFile*)file {
    for (LVTab* tab in self.tabView.tabs) {
        for (LVEditor* editor in [tab editors]) {
            if (editor.file == file) {
                [self.tabView selectTab:tab];
                [editor makeFirstResponder];
                
                return YES;
            }
        }
    }
    
    return NO;
}

- (void) replaceCurrentEditorWithFile:(LVFile*)file {
    // TODO: dont do it if it's unsaved!
    
    if (![self switchToOpenFile:file]) {
        [self.tabView.currentTab.currentEditor startEditingFile:file];
        [self.tabView titlesChanged];
    }
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
    
    [self.tabView addTab:tab];
    
    [editorController startEditingFile:file];
    [self.tabView titlesChanged];
}

- (IBAction) closeProjectWindow:(id)sender {
    // TODO: check for unsaved files in all tabs and their splits
    
    [[self window] performClose:sender];
}

- (IBAction) addSplitToEast:(id)sender {
    LVFile* file = [self.project openNewFile];
    LVEditor* editorController = [[LVEditor alloc] init];
    
    [self.tabView.currentTab addEditor:editorController
                           inDirection:LVSplitDirectionEast];
    
    [editorController startEditingFile:file];
    [self.tabView titlesChanged];
}

@end
