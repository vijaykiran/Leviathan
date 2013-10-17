//
//  LVFile.m
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVFile.h"

@implementation LVFile

- (void) parseFromFile {
    NSString* rawString = [NSString stringWithContentsOfURL:self.fileURL encoding:NSUTF8StringEncoding error:NULL];
    self.textStorage = [[NSTextStorage alloc] initWithString:rawString];
    
//    SDParseError* error;
//    self.topLevelElement = [SDParser parse:rawString error:&error];
}

- (void) highlight:(NSTextView*)tv {
//    NSString* rawString = [[tv textStorage] string];
//    
//    [[tv textStorage] beginEditing];
//    
//    SDParseError* error;
//    self.topLevelElement = [SDParser parse:rawString error:&error];
//    
//    if (error) {
//        self.topLevelElement = nil;
//        SDApplyStyle([tv textStorage], SDThemeForSyntaxError, error.offendingToken.range, 1);
//    }
//    else {
//        [self.topLevelElement highlightIn:[tv textStorage] atLevel:0];
//    }
//    
//    [[tv textStorage] endEditing];
}

@end
