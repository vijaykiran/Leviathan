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
    LVFile* file = [LVFile untitledFileInProject:self];
    [self.files addObject:file];
    return file;
}

- (void) loadFiles {
    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    
    NSDirectoryEnumerator *dirEnumerator = [localFileManager enumeratorAtURL:self.projectURL
                                                  includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
                                                                     options:NSDirectoryEnumerationSkipsHiddenFiles | NSDirectoryEnumerationSkipsPackageDescendants
                                                                errorHandler:nil];
    
    for (NSURL *theURL in dirEnumerator) {
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
            BOOL isClojure = [[theURL pathExtension] isEqualToString:@"clj"];
            
            if (isClojure) {
                LVFile* file = [LVFile untitledFileInProject:self];
                [file loadFromFileURL:theURL];
                [self.files addObject:file];
            }
        }
    }
    
    [self buildFileTree];
}

- (void) buildFileTree {
    self.fileTree = [[LVProjectTreeItem alloc] init];
    self.fileTree.children = [NSMutableArray array];
    
    for (LVFile* file in self.files) {
        NSMutableArray* sections = [[[file longName] pathComponents] mutableCopy];
        NSString* name = [sections lastObject];
        [sections removeLastObject];
        
        LVProjectTreeItem* subtree = self.fileTree;
        
        for (NSString* section in sections) {
            NSUInteger found = [subtree.children indexOfObjectPassingTest:^BOOL(LVProjectTreeItem* maybe, NSUInteger idx, BOOL *stop) {
                return [maybe.name isEqual: section];
            }];
            
            LVProjectTreeItem* nextSubtree;
            if (found == NSNotFound) {
                nextSubtree = [[LVProjectTreeItem alloc] init];
                nextSubtree.children = [NSMutableArray array];
                nextSubtree.name = section;
                [subtree.children addObject: nextSubtree];
            }
            else {
                nextSubtree = [subtree.children objectAtIndex:found];
            }
            
            subtree = nextSubtree;
        }
        
        LVProjectTreeItem* tail = [[LVProjectTreeItem alloc] init];
        tail.name = name;
        tail.file = file;
        [subtree.children addObject: tail];
    }
}

@end

@implementation LVProjectTreeItem
@end
