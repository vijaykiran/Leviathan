//
//  Beowulf.h
//  Beowulf
//
//  Created by Steven on 9/10/13.
//
//

#import <Foundation/Foundation.h>

@interface BWEnv : NSObject <NSCopying>
@property BWEnv* parent;
@property NSMutableDictionary* names;
- (id) lookup:(NSString*)name;
@end

@interface BWObject : NSObject <NSCopying>
- (id) toObjC;
@end

@interface BWEvalError : NSObject
@property NSString* reason;
@property NSUInteger pos;
@end





// You'll probably use this stuff.




void BWInitialize(); // call early on in your program
BWEnv* BWFreshEnv();
BWObject* BWEval(NSString* raw, BWEnv* env, BWEvalError*__autoreleasing* error);






// You might need this stuff.


@protocol BWSeq <NSObject, NSCopying>

- (BWObject*) first;
//- (id<BWSeq>) rest;
- (id<BWSeq>) next;

@end

@interface BWBooleanType : BWObject
@end
extern BWBooleanType* BWTrue;
extern BWBooleanType* BWFalse;

@interface BWNilType : BWObject
@end
extern BWNilType* BWNil;

@interface BWString : BWObject
@property NSString* value; // surrounded by quotes
@end

@interface BWRegex : BWObject
@property NSString* value; // surrounded by quotes and prefixed with hash
@end

@interface BWKeyword : BWObject
@property NSString* value; // prefixed with colon
@end

@interface BWSymbol : BWObject
@property NSString* value;
@end

@interface BWNumber : BWObject
@property NSNumber* value;
@end

@interface BWList : BWObject <BWSeq>
@property BWObject* first;
@property BWList* next;
@end

@interface BWVector : BWObject <BWSeq>
@property NSArray* array;
@end

@interface BWMap : BWObject <BWSeq>
@property NSDictionary* map;
@end

@interface BWSet : BWObject <BWSeq>
@property NSSet* set;
@end

@interface BWClosure : BWObject
// TBD
@end

@interface BWFunction : BWObject
@property BWObject*(*fn)(BWList* args);
@end






// You probably won't need this.

void BWRunInternalTests(NSString* preludeContents);
