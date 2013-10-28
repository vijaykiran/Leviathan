//
//  LVClojureText.h
//  Leviathan
//
//  Created by Steven Degutis on 10/27/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "coll.h" // TODO: ridda this!
#import "doc.h"

@interface LVClojureText : NSTextStorage

@property LVDoc* doc;
@property LVColl* topLevelElement; // TODO: get rid of this!

@end
