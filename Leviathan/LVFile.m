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

@implementation LVFile

+ (LVFile*) fileWithURL:(NSURL*)theURL shortName:(NSString*)shortName longName:(NSString*)longName {
    LVFile* file = [[LVFile alloc] init];
    
    file.fileURL = theURL;
    file.longName = longName;
    file.shortName = shortName;
    
    [file parseFromFile];
    
    return file;
}

- (void) parseFromFile {
    if (self.fileURL) {
        NSString* rawString = [NSString stringWithContentsOfURL:self.fileURL encoding:NSUTF8StringEncoding error:NULL];
        self.textStorage = [[NSTextStorage alloc] initWithString:rawString];
        
        LVParseError* error;
        self.topLevelElement = [LVParser parse:rawString error:&error];
        
//        if (error) {
//            NSLog(@"error %d %@", error.errorType, self.fileURL);
//        }
        
//        NSLog(@"%d, %ld - %ld, %@", error.errorType, error.badRange.location, error.badRange.length, self.fileURL);
    }
    else {
        self.textStorage = [[NSTextStorage alloc] initWithString:@""];
    }
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

- (void) save {
    if (self.fileURL) {
        NSError* __autoreleasing error;
        
        BOOL success =
        [[self.textStorage string] writeToURL:self.fileURL
                                   atomically:YES
                                     encoding:NSUTF8StringEncoding
                                        error:&error];
        
        if (!success) {
            [NSApp presentError:error];
        }
    }
    else {
        // TODO: save it based on the namespace
    }
}

@end
