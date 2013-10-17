//
//  LVProject.m
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVProject.h"

@implementation LVProject

+ (LVProject*) openProjectAtURL:(NSURL*)url {
    LVProject* p = [[LVProject alloc] init];
    p.projectURL = url;
    p.files = [NSMutableArray array];
    [p loadFiles];
    return p;
}

- (LVFile*) openNewFile {
    LVFile* file = [[LVFile alloc] init];
    
    file.shortName = @"Untitled";
    file.longName = @"";
    
    [self.files addObject:file];
    return file;
}

- (void) loadFiles {
    NSUInteger baselen = [[self.projectURL path] length] + 1;
    
    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    
    NSDirectoryEnumerator *dirEnumerator = [localFileManager enumeratorAtURL:self.projectURL
                                                  includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
                                                                     options:NSDirectoryEnumerationSkipsHiddenFiles | NSDirectoryEnumerationSkipsPackageDescendants
                                                                errorHandler:nil];
    
    for (NSURL *theURL in dirEnumerator) {
        NSString *shortName;
        [theURL getResourceValue:&shortName forKey:NSURLNameKey error:NULL];
        
        NSNumber *isDirectory;
        [theURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];
        
        if ([isDirectory boolValue]) {
            if ([theURL isEqual: [self.projectURL URLByAppendingPathComponent:@"datomic"]]) {
                [dirEnumerator skipDescendants];
                continue;
            }
            if ([theURL isEqual: [self.projectURL URLByAppendingPathComponent:@"target"]]) {
                [dirEnumerator skipDescendants];
                continue;
            }
        }
        else {
            NSMutableString* longName = [[theURL path] mutableCopy];
            [longName deleteCharactersInRange:NSMakeRange(0, baselen)];
            
            BOOL isClojure = [[theURL pathExtension] isEqualToString:@"clj"];
            
            if (isClojure) {
                LVFile* file = [[LVFile alloc] init];
                file.fileURL = theURL;
                file.longName = longName;
                file.shortName = shortName;
                [self.files addObject:file];
                
                [file parseFromFile];
            }
        }
    }
}

@end
