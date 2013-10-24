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

- (void) parseFromFile {
    // this method assumes it's only called once per file!
    
    if (self.fileURL) {
        self.textOnDisk = [NSString stringWithContentsOfURL:self.fileURL encoding:NSUTF8StringEncoding error:NULL];
        self.textStorage = [[NSTextStorage alloc] initWithString:self.textOnDisk];
    }
    else {
        self.textOnDisk = @"";
        self.textStorage = [[NSTextStorage alloc] initWithString:@""];
    }
    self.topLevelElement = LVParse([self.textOnDisk UTF8String]);
}

- (void) initialHighlight {
    [self.textStorage beginEditing];
    
    if (self.topLevelElement) {
        LVHighlight((void*)self.topLevelElement, self.textStorage, 0);
    }
    
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
