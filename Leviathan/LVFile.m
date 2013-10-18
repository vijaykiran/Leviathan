//
//  LVFile.m
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVFile.h"

#import "SDParser.h"

#import "SDTheme.h"

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
        
        SDParseError* error;
        self.topLevelElement = [SDParser parse:rawString error:&error];
        
        if (error) {
            NSLog(@"error %d %@", error.errorType, self.fileURL);
        }
        
//        NSLog(@"%d, %ld - %ld, %@", error.errorType, error.badRange.location, error.badRange.length, self.fileURL);
    }
    else {
        self.textStorage = [[NSTextStorage alloc] initWithString:@""];
    }
    
    NSFont* font = [NSFont fontWithName:@"Menlo" size:12]; // TODO: replace this with NSUserDefaults somehow
    
    NSRange fullRange = NSMakeRange(0, [self.textStorage length]);
    [self.textStorage addAttribute:NSFontAttributeName value:font range:fullRange];
}

- (void) highlight {
    NSString* rawString = [self.textStorage string];
    
    [self.textStorage beginEditing];
    
    SDParseError* error;
    self.topLevelElement = [SDParser parse:rawString error:&error];
    
    if (error) {
        self.topLevelElement = nil;
        SDApplyStyle(self.textStorage, SDThemeForSyntaxError, error.badRange, 1);
    }
    else {
        [self.topLevelElement highlightIn:self.textStorage atLevel:0];
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
