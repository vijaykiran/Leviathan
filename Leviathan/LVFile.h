//
//  LVFile.h
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LVFile : NSObject

@property NSURL* fileURL;
@property NSString* longName;
@property NSString* shortName;

@property NSTextStorage* textStorage;

//@property SDColl* topLevelElement;

- (void) parseFromFile;
- (void) highlight:(NSTextView*)tv;

@end
