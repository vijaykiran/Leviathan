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
    }
    else {
        self.textStorage = [[NSTextStorage alloc] initWithString:@""];
    }
    
    NSFont* font = [NSFont fontWithName:@"Menlo" size:13]; // TODO: replace this with NSUserDefaults somehow
    
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
        SDApplyStyle(self.textStorage, SDThemeForSyntaxError, error.offendingToken.range, 1);
    }
    else {
        [self.topLevelElement highlightIn:self.textStorage atLevel:0];
    }
    
    [self.textStorage endEditing];
}

@end
