//
//  LVEditorViewController.m
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVEditorViewController.h"

@interface LVEditorViewController ()

@end

@implementation LVEditorViewController

- (NSString*) nibName {
    return @"Editor";
}

+ (LVEditorViewController*) editorForFile:(LVFile*)file {
    LVEditorViewController* c = [[LVEditorViewController alloc] init];
    c.file = file;
    c.title = @"Untitled";
    // TODO: set title based on file
    return c;
}

@end
