//
//  LVFile.m
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVFile.h"

@interface LVFile ()

@property NSString* textOnDisk;

@end

@implementation LVFile

+ (LVFile*) fileWithURL:(NSURL*)theURL shortName:(NSString*)shortName longName:(NSString*)longName {
    LVFile* file = [[LVFile alloc] init];
    
    file.fileURL = theURL;
    file.longName = longName;
    file.shortName = shortName;
    
    [file loadFromFile];
    
    return file;
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
    if (self.fileURL) {
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
    else {
        // TODO: save it based on the namespace
    }
}

@end
