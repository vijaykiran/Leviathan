
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

#import "LVReplClient.h"
#import "LVEmbeddedRepl.h"

LV_DEFINE(LVTabTitleChangedNotification);

@interface LVProjectWindow : NSWindow
@end

@implementation LVProjectWindow

- (BOOL) respondsToSelector:(SEL)aSelector {
    if (aSelector == @selector(performClose:))
        return NO;
    else
        return [super respondsToSelector:aSelector];
}

@end

@interface LVProjectWindowController ()

@property (weak) id<LVProjectWindowController> delegate;
@property (weak) IBOutlet LVTabView* tabView;

@property (weak) IBOutlet NSOutlineView* projectTreeView;

@property IBOutlet NSTextView* replTextView;

@property LVReplClient* repl;
@property LVEmbeddedRepl* embeddedRepl;

@end

@implementation LVProjectWindowController

+ (LVProjectWindowController*) openWith:(NSURL*)url delegate:(id<LVProjectWindowController>)delegate {
    LVProjectWindowController* c = [[LVProjectWindowController alloc] init];
    c.project = [LVProject openProjectAtURL:url];
    c.delegate = delegate;
    
    [[c window] setTitleWithRepresentedFilename:[url path]];
    [c setWindowFrameAutosaveName:[url path]];
    [c showWindow:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:c selector:@selector(tabTitleChanged:) name:LVTabTitleChangedNotification object:nil];
    
    return c;
}

- (void) tabTitleChanged:(NSNotification*)note {
    [self.tabView updateTabTitles];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSString*) windowNibName {
    return @"ProjectWindow";
}

- (void) windowDidBecomeMain:(NSNotification *)notification {
    [self.tabView undim];
}

- (void) windowDidResignMain:(NSNotification *)notification {
    [self.tabView dim];
}

- (void) awakeFromNib {
    [super awakeFromNib];
    [self makeTitleBarPrettier];
    [self.tabView dim];
    
    [self.projectTreeView setDoubleAction:@selector(selectFileFromProjectNavView:)];
    
    // TODO: this is a temporary hack
    [[[self window] drawers] makeObjectsPerformSelector:@selector(open)];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    [self newTab:nil];
}

- (void) makeTitleBarPrettier {
    self.window.styleMask |= NSTexturedBackgroundWindowMask;
    [self.window setContentBorderThickness:0.0 forEdge:NSMaxYEdge];
}




// repl

NSString* LVGetQuickStringFromUser(NSString* prompt) {
    NSAlert *alert = [NSAlert alertWithMessageText:prompt defaultButton:@"OK" alternateButton:@"Cancel" otherButton:nil informativeTextWithFormat:@""];
    
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 22)];
    [alert setAccessoryView:input];
    
    NSInteger button = [alert runModal];
    if (button == NSAlertDefaultReturn) {
        [input validateEditing];
        return [input stringValue];
    }
    
    return nil;
}

- (void) insertReplText:(NSString*)text {
    NSUInteger len = [[self.replTextView textStorage] length];
    [self.replTextView shouldChangeTextInRange:NSMakeRange(len, 0) replacementString:text];
    [self.replTextView replaceCharactersInRange:NSMakeRange(len, 0) withString:text];
    [self.replTextView didChangeText];
    [self.replTextView setNeedsDisplay:YES];
    [self.replTextView scrollToEndOfDocument:self];
}

- (void) openRepl:(NSUInteger)port {
    self.repl = [[LVReplClient alloc] init];
    [self.repl connect:port ready:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self insertReplText:@"Done!\n\n"];
        });
    }];
}

- (void) addReplView {
    NSDrawer* d = [[self.window drawers] firstObject];
    [d open];
    
    [self insertReplText:@"Connecting... "];
}

- (IBAction) connectToNRepl:(id)sender {
    NSUInteger port = [LVGetQuickStringFromUser(@"nREPL port:") integerValue];
    if (!port)
        return;
    
    [self addReplView];
    [self openRepl:port];
}

- (IBAction) startNReplServerAndConnect:(id)sender {
    [self addReplView];
    
    __weak LVProjectWindowController* _self = self;
    
    self.embeddedRepl = [[LVEmbeddedRepl alloc] init];
    self.embeddedRepl.baseURL = self.project.projectURL;
    self.embeddedRepl.ready = ^(NSUInteger port) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [_self openRepl:port];
        });
    };
    [self.embeddedRepl open];
}

- (IBAction) evaluateFile:(id)sender {
    NSString* code = self.tabView.currentTab.currentEditor.file.clojureTextStorage.string;
    [self.repl sendRawCommand:@{@"op": @"eval", @"code": code}];
    
    while (1) {
        NSDictionary* result = [self.repl receiveRawResponse];
//        NSLog(@"result: %@", result);
        
        NSString* outString = [result objectForKey:@"out"];
        NSString* valueString = [result objectForKey:@"value"];
        
        if (outString)
            [self insertReplText: [outString stringByAppendingString:@"\n"]];
        
        if (valueString)
            [self insertReplText: [[@"=> " stringByAppendingString:valueString] stringByAppendingString:@"\n"]];
        
        NSString* status = [result objectForKey:@"status"];
        if ([status isEqual:@[@"done"]])
            break;
    }
}

//- (IBAction) evaluatePrecedingExpression:(id)sender {
//    
//}
//
//- (IBAction) evaluateFollowingExpression:(id)sender {
//    
//}


// closing things

- (void) windowWillClose:(NSNotification *)notification {
    [self.delegate projectWindowClosed:self];
}

- (IBAction) closeProjectTabSplit:(id)sender {
    if ([[self.tabView.currentTab editors] count] == 1) {
        [self closeProjectTab:sender];
    }
    else {
        [self.tabView.currentTab closeCurrentSplit];
    }
}

- (IBAction) closeProjectTab:(id)sender {
    if ([self.tabView.tabs count] == 1) {
        [self closeProjectWindow:sender];
    }
    else {
        [self.tabView closeCurrentTab];
    }
}

- (IBAction) closeProjectWindow:(id)sender {
    [self tryClosingCompletely];
}

- (IBAction) performClose:(id)sender {
    [self closeProjectTab:sender];
}

- (BOOL) tryClosingCompletely {
    NSArray* unsavedFiles = [self.project.files filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.hasChanges = TRUE"]];
    
    if ([unsavedFiles count] > 0) {
        [self.tabView closeAllTabs];
        
        for (LVFile* file in unsavedFiles) {
            [self editFileInNewTab:file];
        }
        
        NSInteger result = NSRunAlertPanel(@"Unsaved Changes", @"All these tabs have unsaved changes.", @"Close", @"Review Changes", nil);
        
        if (result != NSAlertDefaultReturn)
            return NO;
    }
    
    [[self window] performClose:self];
    
    return YES;
}




// opening basic things

- (IBAction) addSplitToEast:(id)sender {
    [self editFile:[self.project openNewFile]
       inDirection:LVSplitDirectionEast];
}

- (IBAction) newTab:(id)sender {
    [self editFileInNewTab:[self.project openNewFile]];
}






// opening complex things

- (IBAction) openTestInSplit:(id)sender {
    if ([self.tabView.currentTab.currentEditor.file fileURL] == nil)
        return;
    
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
        [self editFile:found
           inDirection:LVSplitDirectionEast];
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
                      [self editFileInCurrentEditor:file];
                  }];
}

- (IBAction) jumpToDefinitionAtPoint:(id)sender {
    NSLog(@"not ready yet");
    NSBeep();
}

- (IBAction) jumpToDefinition:(id)sender {
    NSMutableArray* defFiles = [NSMutableArray array];
    NSMutableArray* defDefs = [NSMutableArray array];
    NSMutableArray* readableNames = [NSMutableArray array];
    
    for (LVFile* file in self.project.files) {
        NSMutableArray* defs = [NSMutableArray array];
        
        LVFindDefinitions(file.clojureTextStorage.doc, defs);
        
        for (LVDefinition* def in defs) {
            [defFiles addObject:file];
            [defDefs addObject:def];
            [readableNames addObject:[NSString stringWithFormat:@"%s %s", CFStringGetCStringPtr(LVStringForToken(def.defType->token), kCFStringEncodingUTF8), CFStringGetCStringPtr(LVStringForToken(def.defName->token), kCFStringEncodingUTF8)]];
        }
    }
    
    CGFloat maxLen = [[readableNames valueForKeyPath:@"@max.length"] doubleValue];
    
    [SDFuzzyMatcher showChoices:readableNames
                      charsWide:maxLen * 2.2 / 3.0
                      linesTall:10
                    windowTitle:@"Jump to Definition"
                  choseCallback:^(long chosenIndex) {
                      [self openDefinition:[defDefs objectAtIndex:chosenIndex]
                                    inFile:[defFiles objectAtIndex:chosenIndex]];
                  }];
}







// open proj in whatever

- (IBAction) openProjectInTerminal:(id)sender {
    [[NSWorkspace sharedWorkspace] openFile:[self.project.projectURL path]
                            withApplication:@"Terminal"];
}

- (IBAction) openProjectInGitx:(id)sender {
    [[NSWorkspace sharedWorkspace] openFile:[self.project.projectURL path]
                            withApplication:@"GitX"];
}





// low level

- (void) editFileInNewTab:(LVFile*)file {
    LVEditor* editorController = [[LVEditor alloc] init];
    
    LVTab* tab = [[LVTab alloc] init];
    [tab startWithEditor: editorController];
    
    [self.tabView addTab:tab];
    
    [editorController startEditingFile:file];
    [self.tabView updateTabTitles];
}

- (void) editFile:(LVFile*)file inDirection:(LVSplitDirection)dir {
    LVEditor* editorController = [[LVEditor alloc] init];
    
    [self.tabView.currentTab addEditor:editorController
                           inDirection:dir];
    
    [editorController startEditingFile:file];
    [self.tabView updateTabTitles];
}

- (void) editFileInCurrentEditor:(LVFile*)file {
    if (![self switchToOpenFile:file]) {
        [self.tabView.currentTab.currentEditor startEditingFile:file];
        [self.tabView updateTabTitles];
    }
}

- (void) openDefinition:(LVDefinition*)def inFile:(LVFile*)file {
    [self editFileInCurrentEditor:file];
    [self.tabView.currentTab.currentEditor jumpToDefinition:def];
}

- (BOOL) switchToOpenFile:(LVFile*)file {
    for (LVTab* tab in self.tabView.tabs) {
        for (LVEditor* editor in [tab editors]) {
            if (editor.file == file) {
                [self.tabView selectTab:tab];
                // TODO: what happens when it switches to a new tab but its in another split in that tab? also, that might need to refresh tab titles.
                [editor makeFirstResponder];
                
                return YES;
            }
        }
    }
    
    return NO;
}

- (void) editFileInUntitledEditor:(LVFile*)file {
    LVFile* currentEditorFile = self.tabView.currentTab.currentEditor.file;
    if (![self switchToOpenFile:file]) {
        if (!currentEditorFile.hasChanges && [[[currentEditorFile clojureTextStorage] string] isEqualToString:@""]) { // TODO: method -isEmpty
            [self editFileInCurrentEditor:file];
        }
        else {
            [self editFileInNewTab:file];
        }
    }
}

- (void) editFileWithLongName:(NSString*)subpath {
    for (LVFile* file in self.project.files) {
        if ([[file longName] isEqualToString:subpath]) {
            [self editFileInUntitledEditor:file];
            return;
        }
    }
}












// project tree

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(LVProjectTreeItem*)item {
    if (!item) item = self.project.fileTree;
    return [item.children count];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(LVProjectTreeItem*)item {
    if (!item) item = self.project.fileTree;
    return item.children != nil;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(LVProjectTreeItem*)item {
    if (!item) item = self.project.fileTree;
    return [item.children objectAtIndex:index];
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(LVProjectTreeItem*)item {
    if (!item) item = self.project.fileTree;
    return item.name;
}

- (void) selectFileFromProjectNavView:(id)sender {
    NSInteger row = [self.projectTreeView selectedRow];
    if (row == -1)
        return;
    
    LVProjectTreeItem* item = [self.projectTreeView itemAtRow:row];
    
    if (item.children)
        return;
    
    [self editFileInCurrentEditor:item.file];
    [self.tabView.currentTab.currentEditor makeFirstResponder];
}

@end



@interface LVProjectTreeOutlineView : NSOutlineView
@end

@implementation LVProjectTreeOutlineView

- (void) keyDown:(NSEvent*)theEvent {
    unichar key = [[theEvent charactersIgnoringModifiers] characterAtIndex:0];
    if (key == NSCarriageReturnCharacter) {
        [NSApp sendAction:@selector(selectFileFromProjectNavView:) to:nil from:self];
        return;
    }
    
    [super keyDown:theEvent];
}

@end
