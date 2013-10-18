//
//  SDExpectation.m
//  Beowulf
//
//  Created by Steven Degutis on 9/20/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "SDExpectation.h"

@implementation SDExpectation

+ (SDExpectation*) expectationFor:(id)recv in:(NSString*)file at:(NSUInteger)line ctx:(XCTestCase*)ctx {
    SDExpectation* e = [[SDExpectation alloc] init];
    e.recv = recv;
    e.file = file;
    e.line = line;
    e.ctx = ctx;
    return e;
}

- (void) toEqual:(id)other {
    dispatch_block_t blk = ^{
        if ((self.recv != other) && [self.recv isEqual: other] == NO) {
            NSString* str = [NSString stringWithFormat:@"Wanted: %@\n   Got: %@", other, self.recv];
            _XCTFailureHandler(self.ctx, YES, [self.file UTF8String], self.line, str, @"");
        }
    };
    
    [[SDExpectation expectationFor:blk
                                in:self.file
                                at:self.line
                               ctx:self.ctx] toNotRaise];
}

- (void) toNotRaise {
    @try {
        dispatch_block_t blk = self.recv;
        blk();
    }
    @catch (NSException *exception) {
        NSString* str = [NSString stringWithFormat:@"Got unwanted exception: %@", exception];
        _XCTFailureHandler(self.ctx, YES, [self.file UTF8String], self.line, str, @"");
    }
}

@end
