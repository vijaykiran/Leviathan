//
//  LVTextView.m
//  Leviathan
//
//  Created by Steven Degutis on 10/17/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVTextView.h"

#import "SDTheme.h"

@implementation LVTextView

- (BOOL) becomeFirstResponder {
    BOOL did = [super becomeFirstResponder];
    if (did) {
        [self.customDelegate textViewWasFocused:self];
    }
    return did;
}

- (void) awakeFromNib {
    self.enclosingScrollView.verticalScroller.knobStyle = NSScrollerKnobStyleLight;
    self.enclosingScrollView.horizontalScroller.knobStyle = NSScrollerKnobStyleLight;
    
    self.font = [NSFont fontWithName:@"Menlo" size:13]; // TODO: replace this with NSUserDefaults somehow
    self.backgroundColor = SDColorFromHex([[[SDTheme temporaryTheme] attributes] objectForKey:SDThemeBackgroundColor]);
    self.insertionPointColor = SDColorFromHex([[[SDTheme temporaryTheme] attributes] objectForKey:SDThemeCursorColor]);
    self.selectedTextAttributes = @{NSBackgroundColorAttributeName: SDColorFromHex([[[SDTheme temporaryTheme] attributes] objectForKey:SDThemeSelectionColor])};
}

@end
