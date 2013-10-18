//
//  LVFile.m
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVFile.h"

#import "LVParser.h"

#import "LVThemeManager.h"
#import "LVHighlighter.h"

#import "LVPreferences.h"

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

- (void) parseFromFile {
    if (self.fileURL) {
        self.textOnDisk = [NSString stringWithContentsOfURL:self.fileURL encoding:NSUTF8StringEncoding error:NULL];
        self.textStorage = [[NSTextStorage alloc] initWithString:self.textOnDisk];
        
        LVParseError* error;
        self.topLevelElement = [LVParser parse:self.textOnDisk error:&error];
        
//        if (error) {
//            NSLog(@"error %d %@", error.errorType, self.fileURL);
//        }
        
//        NSLog(@"%d, %ld - %ld, %@", error.errorType, error.badRange.location, error.badRange.length, self.fileURL);
    }
    else {
        self.textOnDisk = @"";
        self.textStorage = [[NSTextStorage alloc] initWithString:@""];
    }
}

- (void) textStorageDidProcessEditing:(NSNotification*)note {
    [self highlight];
}

- (void) highlight {
    NSString* rawString = [self.textStorage string];
    
    [self.textStorage beginEditing];
    
    LVParseError* error;
    self.topLevelElement = [LVParser parse:rawString error:&error];
    
    if (error) {
        self.topLevelElement = nil;
        LVApplyStyle(self.textStorage, LVStyleForSyntaxError, error.badRange, 1);
    }
    else {
        [LVHighlighter highlight:self.topLevelElement
                              in:self.textStorage
                         atLevel:0];
    }
    
    [self.textStorage endEditing];
}

- (BOOL) hasChanges {
    return ![[self.textStorage string] isEqualToString:self.textOnDisk];
}

- (void) save {
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
