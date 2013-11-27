//
//  LVFile.m
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVFile.h"

#import "LVProject.h"

@interface LVFile ()

@property NSString* textOnDisk;

@end

@implementation LVFile

+ (LVFile*) untitledFileInProject:(LVProject*)project {
    LVFile* file = [[LVFile alloc] init];
    
    file.project = project;
    
    file.fileURL = nil;
    file.longName = @"";
    file.shortName = @"Untitled";
    
    [file loadFromFile];
    
    return file;
}

- (void) useFileURL:(NSURL*)fileURL {
    NSUInteger baselen = [[self.project.projectURL path] length] + 1;
    
    NSMutableString* longName = [[fileURL path] mutableCopy];
    [longName deleteCharactersInRange:NSMakeRange(0, baselen)];
    
    self.fileURL = fileURL;
    self.longName = longName;
    self.shortName = [fileURL lastPathComponent];
}

- (void) loadFromFileURL:(NSURL*)fileURL {
    [self useFileURL:fileURL];
    [self loadFromFile];
}

- (void) saveToFileURL:(NSURL*)fileURL {
    [self useFileURL:fileURL];
    [self save];
}

- (void) loadFromFile {
    // this method assumes it's only called once per file!
    
    if (self.fileURL)
        self.textOnDisk = [NSString stringWithContentsOfURL:self.fileURL encoding:NSUTF8StringEncoding error:NULL];
    else
        self.textOnDisk = @"";
    
    self.textOnDisk = [self.textOnDisk stringByReplacingOccurrencesOfString:@"\t" withString:@"  "];
    
    self.clojureTextStorage = [[LVClojureTextStorage alloc] initWithString:self.textOnDisk];
}

- (BOOL) hasChanges {
    return ![[self.clojureTextStorage string] isEqualToString:self.textOnDisk];
}

- (void) save {
    NSString* tempString = [self.clojureTextStorage string];
    
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

@end
