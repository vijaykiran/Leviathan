
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

#import <objc/runtime.h>

static void sd_swizzle(Class kls, NSString* selName, IMP imp) {
    SEL sel = NSSelectorFromString(selName);
    Method meth = class_getInstanceMethod(kls, sel);
    const char* enc = method_getTypeEncoding(meth);
    class_addMethod(kls, sel, imp, enc);
}


@interface LVProjectWindowController ()

@property (weak) id<LVProjectWindowController> delegate;
@property (weak) IBOutlet LVTabView* tabView;

@end

@implementation LVProjectWindowController

+ (LVProjectWindowController*) openWith:(NSURL*)url delegate:(id<LVProjectWindowController>)delegate {
    LVProjectWindowController* c = [[LVProjectWindowController alloc] init];
    c.project = [LVProject openProjectAtURL:url];
    c.delegate = delegate;
    
    [[c window] setTitleWithRepresentedFilename:[url path]];
    [c setWindowFrameAutosaveName:[url path]];
    [c showWindow:nil];
    
    return c;
}

- (NSString*) windowNibName {
    return @"ProjectWindow";
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
//    [self makeTitleBarPrettier];
    
    [self newTab:nil];
}

- (void) makeTitleBarPrettier {
//    [[self.window standardWindowButton:NSWindowCloseButton] setHidden:YES];
//    [[self.window standardWindowButton:NSWindowMiniaturizeButton] setHidden:YES];
//    [[self.window standardWindowButton:NSWindowZoomButton] setHidden:YES];
    
    NSView* themeView = [self.window.contentView superview];
    NSString* className = [@"SD" stringByAppendingString: [themeView className]];
    Class c = NSClassFromString(className);
    if (c == nil) {
        c = objc_allocateClassPair([themeView class], [className UTF8String], 0);
        sd_swizzle(c, @"class", imp_implementationWithBlock(^{ return NSClassFromString(@"NSThemeFrame"); }));
        sd_swizzle(c, @"className", imp_implementationWithBlock(^{ return @"NSThemeFrame"; }));
//        sd_swizzle(c, @"_titlebarTitleRect", imp_implementationWithBlock(^{ return NSZeroRect; }));
        sd_swizzle(c, @"_titlebarHeight", imp_implementationWithBlock(^{ return 52.0; }));
        objc_registerClassPair(c);
    }
    object_setClass(themeView, c);
}





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


- (BOOL) tryClosingCompletely {
    NSArray* unsavedFiles = [self.project.files filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self.hasChanges = TRUE"]];
    
    if ([unsavedFiles count] > 0) {
        [self.tabView closeAllTabs];
        
        for (LVFile* file in unsavedFiles) {
            [self editFileInNewTab:file];
        }
        
        NSInteger result = NSRunAlertPanel(@"Unsaved Files", @"You have some unsaved files. I opened them for you so you can take a look.", @"Close window", @"Take a look", nil);
        
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
            [readableNames addObject:[NSString stringWithFormat:@"%s %s", CFStringGetCStringPtr(def.defType->token->string, kCFStringEncodingUTF8), CFStringGetCStringPtr(def.defName->token->string, kCFStringEncodingUTF8)]];
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
                [editor makeFirstResponder];
                
                return YES;
            }
        }
    }
    
    return NO;
}

@end
