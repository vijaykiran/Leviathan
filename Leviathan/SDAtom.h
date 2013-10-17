//
//  SDAtom.h
//  Leviathan
//
//  Created by Steven on 10/12/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SDElement.h"
#import "SDToken.h"

@interface SDAtom : NSObject <SDElement>

@property SDToken* token;
+ (SDAtom*) with:(SDToken*)tok;

@end


@interface SDAtomSymbol : SDAtom @end
@interface SDAtomKeyword : SDAtom @end
@interface SDAtomString : SDAtom @end
@interface SDAtomRegex : SDAtom @end
@interface SDAtomNumber : SDAtom @end
@interface SDAtomTrue : SDAtom @end
@interface SDAtomFalse : SDAtom @end
@interface SDAtomNil : SDAtom @end
@interface SDAtomComment : SDAtom @end
@interface SDAtomTypeOp : SDAtom @end
@interface SDAtomQuote : SDAtom @end
@interface SDAtomUnquote : SDAtom @end
@interface SDAtomSyntaxQuote : SDAtom @end
@interface SDAtomSplice : SDAtom @end
