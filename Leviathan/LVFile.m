//
//  LVFile.m
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVFile.h"

#import "LVThemeManager.h"
#import "LVHighlighter.h"

#import "LVPreferences.h"

#import "parser.h"

@interface LVFile ()

@property NSString* textOnDisk;

@end

@implementation LVFile

+ (LVFile*) fileWithURL:(NSURL*)theURL shortName:(NSString*)shortName longName:(NSString*)longName {
    LVFile* file = [[LVFile alloc] init];
    
    file.undoManager = [[NSUndoManager alloc] init];
    file.fileURL = theURL;
    file.longName = longName;
    file.shortName = shortName;
    
    [file parseFromFile];
    [file setFont];
    file.textStorage.delegate = file;
    
    return file;
}

- (void) setFont {
    NSRange fullRange = NSMakeRange(0, [self.textStorage length]);
    [self.textStorage addAttribute:NSFontAttributeName
                             value:[LVPreferences userFont]
                             range:fullRange];
}

#include <sys/time.h>
#include <sys/resource.h>

double get_time() {
    struct timeval t;
    struct timezone tzp;
    gettimeofday(&t, &tzp);
    return t.tv_sec + t.tv_usec*1e-6;
}

- (void) parseFromFile {
    if (self.fileURL) {
        self.textOnDisk = [NSString stringWithContentsOfURL:self.fileURL encoding:NSUTF8StringEncoding error:NULL];
        self.textStorage = [[NSTextStorage alloc] initWithString:self.textOnDisk];
        
        if (self.topLevelElement)
            LVCollDestroy(self.topLevelElement);
        
        self.topLevelElement = LVParse([self.textOnDisk UTF8String]);
    }
    else {
        self.textOnDisk = @"";
        self.textStorage = [[NSTextStorage alloc] initWithString:@""];
    }
}

- (void) textStorageDidProcessEditing:(NSNotification*)note {
//    NSString* rawString = [self.textStorage string];
//    
////    LVParseError* error;
////    self.topLevelElement = [LVParser parse:rawString error:&error];
//    
//    if ([self.textStorage editedMask] & NSTextStorageEditedCharacters) {
//        [self highlight];
//    }
}

- (void) highlight {
//    NSLog(@"highlight called");
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(reallyHighlight) object:nil];
    [self performSelector:@selector(reallyHighlight) withObject:nil afterDelay:0.0];
}

- (void) reallyHighlight {
//    NSLog(@"really-highlight called");
    NSString* rawString = [self.textStorage string];
    
    [self.textStorage beginEditing];
    
//    LVParseError* error;
//    self.topLevelElement = [LVParser parse:rawString error:&error];
//    
//    if (error) {
//        self.topLevelElement = nil;
//        
//        [[LVThemeManager sharedThemeManager].currentTheme.syntaxerror highlightIn:self.textStorage
//                                                                            range:error.badRange
//                                                                            depth:1];
//    }
//    else {
    
    if (self.topLevelElement)
    
        [LVHighlighter highlight:(void*)self.topLevelElement in:self.textStorage];
//    }
    
    [self.textStorage endEditing];
}

- (BOOL) hasChanges {
    return ![[self.textStorage string] isEqualToString:self.textOnDisk];
}

- (void) save {
//    bstring str = LVStringForColl(self.topLevelElement);
//    printf("%s\n", str->data);
//    bdestroy(str);
//    
//    return;
    
    if (self.fileURL) {
        NSString* tempString = [self.textStorage string];
        
        NSError* __autoreleasing error;
        BOOL success =
        [tempString writeToURL:self.fileURL
                    atomically:YES
                      encoding:NSUTF8StringEncoding
                         error:&error];
        
        if (!success) {
            [NSApp presentError:error];
        }
        
        self.textOnDisk = tempString;
    }
    else {
        // TODO: save it based on the namespace
    }
}

@end
