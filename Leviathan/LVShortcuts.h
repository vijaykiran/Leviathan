//
//  LVShortcuts.h
//  Leviathan
//
//  Created by Steven on 10/28/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LVClojureText.h"



@interface LVShortcut : NSObject

@property id target;
@property SEL action;

@property NSString* title;
@property NSString* keyEquiv;
@property NSArray* mods;

@end



@interface LVShortcuts : NSObject

@property LVClojureText* clojureText;
@property NSTextView* textView;

@end
