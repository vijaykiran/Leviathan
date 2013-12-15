//
//  Beowulf.m
//  Beowulf
//
//  Created by Steven on 9/10/13.
//
//

#import "Beowulf.h"




@interface BWEnv ()
- (void) pinEnvOnTail:(BWEnv*)env;
@end


@interface BWSymbol ()
+ (BWSymbol*) with:(NSString*)str;
@end
#define SYM(x) [BWSymbol with:x]

@interface BWNumber ()
+ (BWNumber*) withDoubleValue:(double)val;
@end

@interface BWFunction ()
+ (BWFunction*) with:(BWObject*(*)(BWList* args))fn;
@end

@interface BWObject ()
- (BWObject*) eval:(BWEnv*)env;
- (BWObject*) quasiEval:(BWEnv*)env;
@end

@interface BWList ()
+ (BWList*) listWithFirst:(BWObject*)first rest:(BWList*)rest;
@end

@interface BWClosure ()
@property BWEnv* initialEnv;
@property BWVector* params;
@property BWObject* body;
@property BOOL isMacro;
- (id) call:(BWList*)args env:(BWEnv*)callingEnv;
@end



@interface BWEvalError ()
+ (void) reason:(NSString*)str pos:(NSUInteger)pos;
@end









@interface BWLoopRecur : NSObject
@property BWList* args;
@end

@implementation BWLoopRecur

+ (BWLoopRecur*) withArgs:(BWList*)args {
    BWLoopRecur* recur = [[BWLoopRecur alloc] init];
    recur.args = args;
    return recur;
}

@end







static BWObject* BWBuiltinFunctionAdd(BWList* args) {
    double i = 0.0;
    
    while (args) {
        BWNumber* arg = (id)args.first;
        i += [arg.value doubleValue];
        args = args.next;
    }
    
    return [BWNumber withDoubleValue: i];
}

static BWObject* BWBuiltinFunctionSub(BWList* args) {
    BWNumber* arg = (id)args.first;
    double i = [arg.value doubleValue];
    args = args.next;
    
    while (args) {
        arg = (id)args.first;
        i -= [arg.value doubleValue];
        args = args.next;
    }
    
    return [BWNumber withDoubleValue: i];
}

static BWObject* BWBuiltinFunctionLessThan(BWList* args) {
    while (args && args.next) {
        BWNumber* arg1 = (id)args.first;
        args = args.next;
        BWNumber* arg2 = (id)args.first;
        
        if ([arg1.value doubleValue] >= [arg2.value doubleValue])
            return BWFalse;
    }
    
    return BWTrue;
}

static BWObject* BWBuiltinFunctionList(BWList* args) {
    return args;
}

static BWObject* BWBuiltinFunctionCons(BWList* args) {
    return [BWList listWithFirst:args.first rest:(BWList*)args.next.first];
}

static BWObject* BWBuiltinFunctionRecur(BWList* args) {
    @throw [BWLoopRecur withArgs:args];
}

static BWObject* BWBuiltinFunctionFirst(BWList* args) {
    id<BWSeq> seq = (id)args.first;
    return [seq first];
}

static BWObject* BWBuiltinFunctionPrn(BWList* args) {
    while (args) {
        BWNumber* arg = (id)args.first;
        printf("%s\n", [[arg description] cStringUsingEncoding:NSASCIIStringEncoding]);
        args = args.next;
    }
    
    return BWNil;
}

static BWObject* BWBuiltinFunctionEquals(BWList* args) {
    if ([args.first isEqual: args.next.first])
        return BWTrue;
    else
        return BWFalse;
}


BWEnv* BWFreshEnv() {
    BWEnv* env = [[BWEnv alloc] init];
    env.names[@"+"] = [BWFunction with:BWBuiltinFunctionAdd];
    env.names[@"-"] = [BWFunction with:BWBuiltinFunctionSub];
    env.names[@"<"] = [BWFunction with:BWBuiltinFunctionLessThan];
    env.names[@"list"] = [BWFunction with:BWBuiltinFunctionList];
    env.names[@"cons"] = [BWFunction with:BWBuiltinFunctionCons];
    env.names[@"="] = [BWFunction with:BWBuiltinFunctionEquals];
    env.names[@"prn"] = [BWFunction with:BWBuiltinFunctionPrn];
    env.names[@"recur"] = [BWFunction with:BWBuiltinFunctionRecur];
    
    env.names[@"first"] = [BWFunction with:BWBuiltinFunctionFirst];
    
    NSURL* preludeURL = [[NSBundle bundleForClass:[BWEnv class]] URLForResource:@"Beowulf" withExtension:@"bwlf"];
    if (preludeURL) {
        NSString* prelude = [NSString stringWithContentsOfURL:preludeURL encoding:NSUTF8StringEncoding error:NULL];
        BWEval(prelude, env, NULL);
    }
    
    return env;
}


















@implementation BWObject

- (BWObject*) eval:(BWEnv*)env {
    return self;
}

- (BWObject*) quasiEval:(BWEnv*)env {
    return self;
}

- (id) copyWithZone:(NSZone *)zone {
    return self;  // yay immutability!
}

- (id) toObjC {
    return nil;
}

@end







@implementation BWBooleanType

- (NSString*) description {
    if (self == BWTrue)
        return @"true";
    else
        return @"false";
}

- (id) toObjC {
    if (self == BWTrue)
        return @YES;
    else
        return @NO;
}

@end









@implementation BWNilType

- (NSString*) description {
    return @"nil";
}

- (id) toObjC {
    return [NSNull null];
}

@end









@implementation BWString

+ (BWString*) with:(NSString*)str {
    BWString* obj = [[BWString alloc] init];
    obj.value = str;
    return obj;
}

- (NSString*) description {
    return self.value;
}

- (BOOL) isEqual:(BWString*)other {
    return ([other isKindOfClass:[self class]] &&
            (self.value == other.value || [self.value isEqualToString: other.value]));
}

- (NSUInteger) hash {
    return [self.value hash];
}

- (id) toObjC {
    return [self.value substringWithRange:NSMakeRange(1, [self.value length] - 2)];
}

@end










@implementation BWRegex

+ (BWRegex*) with:(NSString*)str {
    BWRegex* obj = [[BWRegex alloc] init];
    obj.value = str;
    return obj;
}

- (NSString*) description {
    return self.value;
}

- (BOOL) isEqual:(BWRegex*)other {
    return ([other isKindOfClass:[self class]] &&
            (self.value == other.value || [self.value isEqualToString: other.value]));
}

- (NSUInteger) hash {
    return [self.value hash];
}

- (id) toObjC {
    NSError* __autoreleasing error;
    NSString* str = [self.value substringWithRange:NSMakeRange(2, [self.value length] - 3)];
    return [NSRegularExpression regularExpressionWithPattern:str options:0 error:&error];
}

@end











@implementation BWKeyword

+ (BWKeyword*) with:(NSString*)str {
    BWKeyword* kw = [[BWKeyword alloc] init];
    kw.value = str;
    return kw;
}

- (NSString*) description {
    return self.value;
}

- (BOOL) isEqual:(BWKeyword*)other {
    return ([other isKindOfClass:[self class]] &&
            (self.value == other.value || [self.value isEqualToString: other.value]));
}

- (NSUInteger) hash {
    return [self.value hash];
}

- (id) toObjC {
    return [self.value substringWithRange:NSMakeRange(1, [self.value length] - 1)];
}

@end








@implementation BWSymbol

- (NSString*) description {
    return self.value;
}

+ (BWSymbol*) with:(NSString*)str {
    BWSymbol* sym = [[BWSymbol alloc] init];
    sym.value = str;
    return sym;
}

- (BWObject*) eval:(BWEnv*)env {
    id found = [env lookup: [self value]];
    if (!found)
        [BWEvalError reason:[NSString stringWithFormat:@"Symbol not found: %@", self.value] pos:0];
    
    return found;
}

- (BOOL) isEqual:(BWSymbol*)other {
    return ([other isKindOfClass:[self class]] &&
            (self.value == other.value || [self.value isEqualToString: other.value]));
}

- (NSUInteger) hash {
    return [self.value hash];
}

- (id) toObjC {
    return self.value;
}

@end






@implementation BWNumber

+ (BWNumber*) withDoubleValue:(double)val {
    BWNumber* num = [[BWNumber alloc] init];
    num.value = @(val);
    return num;
}

- (NSString*) description {
    return [self.value description];
}

+ (BWNumber*) with:(NSString*)str {
    static NSNumberFormatter* formatter; if (!formatter) formatter = [[NSNumberFormatter alloc] init];
    BWNumber* sym = [[BWNumber alloc] init];
    sym.value = [formatter numberFromString:str];
    return sym;
}

- (BOOL) isEqual:(BWNumber*)other {
    return ([other isKindOfClass:[self class]] &&
            (self.value == other.value || [self.value isEqualToNumber: other.value]));
}

- (NSUInteger) hash {
    return [self.value hash];
}

- (id) toObjC {
    return self.value;
}

@end












BOOL BWIsTruthy(BWObject* obj) {
    return (obj != BWFalse && obj != BWNil);
}















@implementation BWList

id<BWSeq> BWListFromArray(NSArray* array) {
    BWList* tail;
    for (id obj in [array reverseObjectEnumerator]) {
        tail = [BWList listWithFirst:obj rest:tail];
    }
    return tail;
}

- (NSString*) description {
    NSMutableArray* childs = [NSMutableArray array];
    
    BWList* iter = self;
    while (iter) {
        [childs addObject:[iter.first description]];
        iter = iter.next;
    }
    
    return [NSString stringWithFormat:@"(%@)", [childs componentsJoinedByString:@" "]];
}

+ (BWList*) fromArray:(NSArray*)array {
    return BWListFromArray(array);
}

id<BWSeq> BWEvalUnquoteSplice(BWObject* rawForm, BWEnv* env) {
    if (![rawForm isKindOfClass: [BWList self]])
        return nil;
    
    BWList* rawList = (id)rawForm;
    if (![rawList.first isKindOfClass: [BWSymbol self]])
        return nil;
    
    BWSymbol* firstSymbol = (BWSymbol*)rawList.first;
    if (![firstSymbol.value isEqualToString: @"unquote-splice"])
        return nil;
    
    BWObject* rawSecondForm = (id)rawList.next.first;
    if (!rawSecondForm)
        return nil;
    
    return (id)[rawSecondForm eval: env];
}

- (BWObject*) quasiEval:(BWEnv*)env {
    BWObject* rawForm = self.first;
    
    if ([rawForm isKindOfClass: [BWSymbol self]]) {
        BWSymbol* rawFirstSymbol = (id)rawForm;
        if ([rawFirstSymbol.value isEqualToString: @"unquote"]) {
            BWObject* rawSecond = self.next.first;
            return [rawSecond eval:env];
        }
    }
    
    BWList* evaledRest = (BWList*)[self.next quasiEval:env];
    
    id<BWSeq> innerSeq = BWEvalUnquoteSplice(rawForm, env);
    if (innerSeq) {
        
        NSMutableArray* splicedElements = [NSMutableArray array];
        
        while (innerSeq && [innerSeq first]) {
            [splicedElements addObject: [innerSeq first]];
            innerSeq = [innerSeq next];
        }
        
        BWList* newList = [BWList fromArray: splicedElements]; // TODO: this should really be +[BWList fromSeq:] or something. BUT we need to make sure all types have the same "rest" semantics!
        
        BWList* tail = newList;
        while (tail.next)
            tail = tail.next;
        
        tail.next = evaledRest;
        
        return newList;
    }
    else {
        return [BWList listWithFirst:[self.first quasiEval:env]
                                rest:evaledRest];
    }
}

BWObject* BWRecurEval(BWObject* body, NSArray* params, BWList* args, BWEnv* newEnv) {
    @try {
        for (BWSymbol* name in params) {
            BWObject* val = args.first;
            newEnv.names[name.value] = val;
            args = args.next;
        }
        return [body eval: newEnv];
    }
    @catch (BWLoopRecur *recur) {
        return BWRecurEval(body, params, recur.args, newEnv);
    }
}

- (BWObject*) eval:(BWEnv*)env {
    BWObject* rawFirst = self.first;
    
    if ([rawFirst isKindOfClass: [BWSymbol self]]) {
        BWSymbol* rawFirstSymbol = (id)rawFirst;
        if ([rawFirstSymbol.value isEqualToString: @"quote"]) {
            BWObject* rawSecond = self.next.first;
            return rawSecond;
        }
        else if ([rawFirstSymbol.value isEqualToString: @"if"]) {
            BWObject* rawCondition = self.next.first;
            BWObject* rawTrueClause = self.next.next.first;
            
            if (BWIsTruthy([rawCondition eval:env])) {
                return [rawTrueClause eval:env];
            }
            else {
                BWObject* rawFalseClause = self.next.next.next.first;
                if (rawFalseClause)
                    return [rawFalseClause eval:env];
                else
                    return BWNil;
            }
        }
        else if ([rawFirstSymbol.value isEqualToString: @"do"]) {
            BWList* argsIter = self.next;
            BWObject* last;
            
            while (argsIter) {
                last = [argsIter.first eval:env];
                argsIter = argsIter.next;
            }
            
            return last;
        }
        else if ([rawFirstSymbol.value isEqualToString: @"def"]) {
            BWSymbol* rawName = (id)self.next.first;
            BWObject* rawValue = self.next.next.first;
            
            BWEnv* topLevelEnv = env;
            while (topLevelEnv.parent)
                topLevelEnv = topLevelEnv.parent;
            
            NSString* name = [rawName value];
            topLevelEnv.names[name] = [rawValue eval:env];
            
            return BWNil;
        }
        else if ([rawFirstSymbol.value isEqualToString: @"syntax-quote"]) {
            BWObject* rawSecond = self.next.first;
            return [rawSecond quasiEval:env];
        }
        else if ([rawFirstSymbol.value isEqualToString: @"fn*"]) {
            BWClosure* func = [[BWClosure alloc] init];
            func.params = (BWVector*)self.next.first;
            func.body = self.next.next.first;
            func.initialEnv = env;
            return func;
        }
        else if ([rawFirstSymbol.value isEqualToString: @"macro*"]) {
            BWClosure* func = [[BWClosure alloc] init];
            func.params = (BWVector*)self.next.first;
            func.body = self.next.next.first;
            func.initialEnv = env;
            func.isMacro = YES;
            return func;
        }
        else if ([rawFirstSymbol.value isEqualToString: @"let*"]) {
            BWVector* params = (BWVector*)self.next.first;
            BWObject* body = self.next.next.first;
            
            BWEnv* newEnv = [[BWEnv alloc] init];
            
            NSMutableArray* rawParams = [params.array mutableCopy];
            while ([rawParams count] > 0) {
                BWSymbol* name = rawParams[0];
                BWObject* val = rawParams[1];
                [rawParams removeObjectsInRange:NSMakeRange(0, 2)];
                newEnv.names[name.value] = [val eval:env];
            }
            
            newEnv.parent = env;
            return [body eval: newEnv];
        }
        else if ([rawFirstSymbol.value isEqualToString: @"loop*"]) {
            BWVector* rawParams = (BWVector*)self.next.first;
            BWObject* body = self.next.next.first;
            
            BWEnv* newEnv = [[BWEnv alloc] init];
            newEnv.parent = env;
            
            NSMutableArray* params = [NSMutableArray array];
            NSMutableArray* args = [NSMutableArray array];
            for (NSUInteger i = 0; i < [rawParams.array count] / 2; i++) {
                [params addObject: rawParams.array[i*2]];
                [args addObject: [rawParams.array[i*2+1] eval:env]];
            }
            
            BWList* argsList = [BWList fromArray:args];
            return BWRecurEval(body, params, argsList, newEnv);
        }
    }
    
    BWObject* evaledFirst = [rawFirst eval:env];
    
    if ([evaledFirst isKindOfClass:[BWFunction self]]) {
        BWFunction* fn = (id)evaledFirst;
        
        BWList* evaledArgs = [self.next simpleEval:env];
        return fn.fn(evaledArgs);
    }
    else if ([evaledFirst isKindOfClass:[BWClosure self]]) {
        BWClosure* fn = (id)evaledFirst;
        
        if (fn.isMacro) {
            BWObject* resultForm = [fn call:self.next env:env];
            return [resultForm eval:env];
        }
        else {
            BWList* evaledArgs = [self.next simpleEval:env];
            return [fn call:evaledArgs env:env];
        }
    }
    
    [BWEvalError reason:@"Tried to eval non-function list." pos:0];
    abort();
}

- (BWList*) simpleEval:(BWEnv*)env {
    return [BWList listWithFirst:[self.first eval:env]
                            rest:[self.next simpleEval:env]];
}

+ (BWList*) listWithFirst:(BWObject*)first second:(BWObject*)second {
    return [self listWithFirst:first rest:[self listWithFirst:second rest:nil]];
}

+ (BWList*) listWithFirst:(BWObject*)first rest:(BWList*)rest {
    BWList* list = [[BWList alloc] init];
    list.first = first;
    list.next = rest;
    return list;
}

- (BOOL) isEqual:(BWList*)other {
    return ([other isKindOfClass:[self class]] &&
            (self.first == other.first || [self.first isEqual: other.first]) &&
            (self.next == other.next || [self.next isEqual: other.next]));
}

- (NSUInteger) hash {
    return [@[@(self.first.hash), @(self.next.hash)] hash];
}

- (id) toObjC {
    NSMutableArray* array = [NSMutableArray array];
    BWList* iter = self;
    while (iter) {
        [array addObject: [iter.first toObjC]];
        iter = iter.next;
    }
    return array;
}

@end

















@implementation BWVector

id<BWSeq> BWVectorFromArray(NSArray* array) {
    BWVector* vec = [[BWVector alloc] init];
    vec.array = array;
    return vec;
}

- (BWObject*) first {
    return [self.array firstObject] ?: BWNil;
}

- (id<BWSeq>) next {
    if ([self.array count] < 2)
        return nil;
    
    BWVector* vec = [[BWVector alloc] init];
    vec.array = [self.array subarrayWithRange:NSMakeRange(1, [self.array count] - 1)];
    return vec;
}

//- (id<BWSeq>) next { return nil; }

- (NSString*) description {
    NSMutableArray* childs = [NSMutableArray array];
    for (BWObject* child in self.array) {
        [childs addObject:[child description]];
    }
    return [NSString stringWithFormat:@"[%@]", [childs componentsJoinedByString:@" "]];
}

+ (BWVector*) fromArray:(NSArray*)array {
    return BWVectorFromArray(array);
}

- (BWObject*) eval:(BWEnv*)env {
    NSMutableArray* array = [NSMutableArray array];
    for (BWObject* obj in self.array) {
        [array addObject:[obj eval:env]];
    }
    return [BWVector fromArray:array];
}

- (BWObject*) quasiEval:(BWEnv*)env {
    NSMutableArray* array = [NSMutableArray array];
    for (BWObject* rawForm in self.array) {
        id<BWSeq> innerSeq = BWEvalUnquoteSplice(rawForm, env);
        if (innerSeq) {
            while (innerSeq && [innerSeq first] != BWNil) {
                [array addObject: [innerSeq first]];
                innerSeq = [innerSeq next];
            }
        }
        else {
            [array addObject:[rawForm quasiEval:env]];
        }
    }
    return [BWVector fromArray:array];
}

- (BOOL) isEqual:(BWVector*)other {
    return ([other isKindOfClass:[self class]] &&
            (self.array == other.array || [self.array isEqual: other.array]));
}

- (NSUInteger) hash {
    return [self.array hash];
}

- (id) toObjC {
    NSMutableArray* array = [NSMutableArray array];
    for (BWObject* obj in self.array) {
        [array addObject:[obj toObjC]];
    }
    return array;
}

@end















@implementation BWMap

id<BWSeq> BWMapFromArray(NSArray* array) {
    BWMap* map = [[BWMap alloc] init];
    
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    
    for (NSUInteger i = 0; i < [array count] / 2; i++) {
        BWObject* key = [array objectAtIndex:i*2];
        BWObject* val = [array objectAtIndex:i*2+1];
        dict[key] = val;
    }
    
    map.map = dict;
    
    return map;
}

- (BWObject*) first { return nil; }
//- (id<BWSeq>) rest { return nil; }
- (id<BWSeq>) next { return nil; }

- (NSString*) description {
    NSMutableArray* childs = [NSMutableArray array];
    for (BWObject* key in self.map) {
        BWObject* val = [self.map objectForKey:key];
        NSString* pairString = [NSString stringWithFormat:@"%@ %@", [key description], [val description]];
        [childs addObject:pairString];
    }
    [childs sortUsingSelector:@selector(compare:)];
    return [NSString stringWithFormat:@"{%@}", [childs componentsJoinedByString:@", "]];
}

+ (BWMap*) fromArray:(NSArray*)array {
    return BWMapFromArray(array);
}

- (BWObject*) eval:(BWEnv*)env {
    NSMutableArray* array = [NSMutableArray array];
    for (BWObject* key in self.map) {
        BWObject* val = [self.map objectForKey:key];
        [array addObject:[key eval:env]];
        [array addObject:[val eval:env]];
    }
    return [BWMap fromArray:array];
}

- (BWObject*) quasiEval:(BWEnv*)env {
    NSMutableArray* array = [NSMutableArray array];
    for (BWObject* key in self.map) {
        BWObject* val = [self.map objectForKey:key];
        [array addObject:[key quasiEval:env]];
        [array addObject:[val quasiEval:env]];
    }
    return [BWMap fromArray:array];
}

- (BOOL) isEqual:(BWMap*)other {
    return ([other isKindOfClass:[self class]] &&
            (self.map == other.map || [self.map isEqual: other.map]));
}

- (NSUInteger) hash {
    return [self.map hash];
}

- (id) toObjC {
    NSMutableDictionary* map = [NSMutableDictionary dictionary];
    for (BWObject* key in self.map) {
        BWObject* val = self.map[key];
        id newKey = [key toObjC];
        id newVal = [val toObjC];
        map[newKey] = newVal;
    }
    return map;
}

@end













@implementation BWSet

id<BWSeq> BWSetFromArray(NSArray* array) {
    BWSet* set = [[BWSet alloc] init];
    set.set = [NSSet setWithArray:array];
    return set;
}

- (BWObject*) first {
    return nil;
}

- (id<BWSeq>) next {
    return nil;
}

//- (id<BWSeq>) next { return nil; }

- (NSString*) description {
    NSMutableArray* childs = [NSMutableArray array];
    for (BWObject* child in self.set) {
        [childs addObject:[child description]];
    }
    return [NSString stringWithFormat:@"[%@]", [childs componentsJoinedByString:@" "]];
}

+ (BWSet*) fromArray:(NSArray*)array {
    return BWSetFromArray(array);
}

- (BWObject*) eval:(BWEnv*)env {
    NSMutableArray* array = [NSMutableArray array];
    for (BWObject* obj in self.set) {
        [array addObject:[obj eval:env]];
    }
    return [BWSet fromArray:array];
}

- (BWObject*) quasiEval:(BWEnv*)env {
    NSMutableArray* array = [NSMutableArray array];
    for (BWObject* rawForm in self.set) {
        id<BWSeq> innerSeq = BWEvalUnquoteSplice(rawForm, env);
        if (innerSeq) {
            while (innerSeq && [innerSeq first]) {
                [array addObject: [innerSeq first]];
                innerSeq = [innerSeq next];
            }
        }
        else {
            [array addObject:[rawForm quasiEval:env]];
        }
    }
    return [BWSet fromArray:array];
}

- (BOOL) isEqual:(BWSet*)other {
    return ([other isKindOfClass:[self class]] &&
            (self.set == other.set || [self.set isEqual: other.set]));
}

- (NSUInteger) hash {
    return [self.set hash];
}

- (id) toObjC {
    NSMutableSet* set = [NSMutableSet set];
    for (BWObject* obj in self.set) {
        [set addObject:[obj toObjC]];
    }
    return set;
}

@end













@implementation BWClosure

- (NSString*) description {
    return [NSString stringWithFormat:@"<BWClosure: %p>", self];
}

- (BWObject*) eval:(BWEnv*)env {
    return self;
}

- (id) call:(BWList*)args env:(BWEnv*)callingEnv {
    BWEnv* newEnv = [[BWEnv alloc] init];
    newEnv.parent = [self.initialEnv copy]; // TODO: there's a good chance this is actually a bug. but i cant concentrate well enough right now to figure it out.
    
    [newEnv.parent pinEnvOnTail:callingEnv];
    
    for (NSUInteger i = 0; i < [self.params.array count]; i++) {
        BWSymbol* sym = self.params.array[i];
        
        if ([sym.value isEqualToString: @"&"]) {
            sym = self.params.array[i+1];
            newEnv.names[sym.value] = args;
            break;
        }
        
        BWObject* arg = [args first];
        args = args.next;
        
        newEnv.names[sym.value] = arg;
    }
    
    return [self.body eval:newEnv];
}

@end



















@implementation BWFunction

- (NSString*) description {
    return [NSString stringWithFormat:@"<BWFunction: %p>", self.fn];
}

- (BWObject*) eval:(BWEnv*)env {
    return self;
}

+ (BWFunction*) with:(BWObject*(*)(BWList* args))fn {
    BWFunction* obj = [[BWFunction alloc] init];
    obj.fn = fn;
    return obj;
}

@end









BWBooleanType* BWTrue;
BWBooleanType* BWFalse;
BWNilType* BWNil;

void BWInitialize() {
    static BOOL initialized = NO;
    if (initialized) return;
    initialized = YES;
    
    BWNil = [[BWNilType alloc] init];
    BWTrue = [[BWBooleanType alloc] init];
    BWFalse = [[BWBooleanType alloc] init];
}


















typedef enum __BWTokenType {
    BWTokenType_FileBegin,
    BWTokenType_FileEnd,
    BWTokenType_LParen,
    BWTokenType_RParen,
    BWTokenType_LBracket,
    BWTokenType_RBracket,
    BWTokenType_LBrace,
    BWTokenType_RBrace,
    BWTokenType_Symbol,
    BWTokenType_Keyword,
    BWTokenType_String,
    BWTokenType_Regex,
    BWTokenType_Number,
    BWTokenType_Quote,
    BWTokenType_SyntaxQuote,
    BWTokenType_UnQuote,
    BWTokenType_UnQuoteSplice,
    BWTokenType_TypeOp,
    BWTokenType_OpenAnonFn,
    BWTokenType_OpenSet,
} BWTokenType;

@interface BWToken : NSObject

@property BWTokenType type;
@property NSString* val;
@property NSUInteger pos;
@property NSUInteger len;

@property BWToken* next;

@end

@implementation BWToken
@end









@interface BWTokenIter : NSObject
@property NSString* wholeString;
@property BWToken* head;
@property BWToken* current;
@property BWToken* last;
@end

@implementation BWTokenIter

- (void) addToken:(BWTokenType)type pos:(NSUInteger)pos len:(NSUInteger)len {
    BWToken* token = [[BWToken alloc] init];
    token.type = type;
    token.pos = pos;
    token.len = len;
    token.val = [self.wholeString substringWithRange:NSMakeRange(pos, len)];
    
    self.last.next = token;
    self.last = token;
}

- (void) advance {
    self.current = self.current.next;
}

@end

BWTokenIter* BWLex(NSString* raw) {
    NSUInteger full = [raw length];
    
    BWTokenIter* iter = [[BWTokenIter alloc] init];
    iter.wholeString = raw;
    
    [iter addToken:BWTokenType_FileBegin pos:0 len:0];
    iter.head = iter.last;
    
    unichar chars[full];
    [raw getCharacters:chars];
    
    static const char* endSymbolCharSet = "()[]{} ,\r\n\t;";
    static const char* startNumberCharSet = "0123456789";
    
    NSUInteger i = 0;
    while (i < full) {
        unichar c = chars[i];
        
        if (c == '(') {
            [iter addToken:BWTokenType_LParen pos:i len:1];
            i += 1;
        }
        else if (c == ')') {
            [iter addToken:BWTokenType_RParen pos:i len:1];
            i += 1;
        }
        else if (c == '[') {
            [iter addToken:BWTokenType_LBracket pos:i len:1];
            i += 1;
        }
        else if (c == ']') {
            [iter addToken:BWTokenType_RBracket pos:i len:1];
            i += 1;
        }
        else if (c == '{') {
            [iter addToken:BWTokenType_LBrace pos:i len:1];
            i += 1;
        }
        else if (c == '}') {
            [iter addToken:BWTokenType_RBrace pos:i len:1];
            i += 1;
        }
        else if (c == '\'') {
            [iter addToken:BWTokenType_Quote pos:i len:1];
            i += 1;
        }
        else if (c == '`') {
            [iter addToken:BWTokenType_SyntaxQuote pos:i len:1];
            i += 1;
        }
        else if (c == '^') {
            [iter addToken:BWTokenType_TypeOp pos:i len:1];
            i += 1;
        }
        else if (c == '~') {
            if (i+1 < full && chars[i+1] == '@') {
                [iter addToken:BWTokenType_UnQuoteSplice pos:i len:2];
                i += 2;
            }
            else {
                [iter addToken:BWTokenType_UnQuote pos:i len:1];
                i += 1;
            }
        }
        else if (c == ' ' || c == '\n' || c == '\r' || c == '\t' || c == ',') {
            i += 1;
        }
        else if (c == ';') {
            do i++; while (i < full && chars[i] != '\n');
        }
        else if (c == '#') {
            if (i+1 == full) {
                [BWEvalError reason:@"Unfinished dispatch syntax." pos:0];
            }
            
            if (chars[i+1] == '(') {
                [iter addToken:BWTokenType_OpenAnonFn pos:i len:2];
                i += 2;
            }
            else if (chars[i+1] == '{') {
                [iter addToken:BWTokenType_OpenSet pos:i len:2];
                i += 2;
            }
            else if (chars[i+1] == '"') {
                NSUInteger start = i;
                i++;
                do i++; while (i < full && (chars[i] != '"' || chars[i-1] == '\\'));
                i++;
                [iter addToken:BWTokenType_Regex pos:start len:i - start];
            }
        }
        else if (c == '"') {
            NSUInteger start = i;
            do i++; while (i < full && (chars[i] != '"' || chars[i-1] == '\\'));
            i++;
            [iter addToken:BWTokenType_String pos:start len:i - start];
        }
        else if (c == ':') {
            NSUInteger start = i;
            do i++; while (i < full && !strchr(endSymbolCharSet, chars[i]));
            [iter addToken:BWTokenType_Keyword pos:start len:i - start];
        }
        else if (c == '+' && i+1 < full && strchr(startNumberCharSet, chars[i+1])) {
            NSUInteger start = i + 1;
            do i++; while (i < full && !strchr(endSymbolCharSet, chars[i]));
            [iter addToken:BWTokenType_Number pos:start len:i - start];
        }
        else if (c == '-' && i+1 < full && strchr(startNumberCharSet, chars[i+1])) {
            NSUInteger start = i;
            do i++; while (i < full && !strchr(endSymbolCharSet, chars[i]));
            [iter addToken:BWTokenType_Number pos:start len:i - start];
        }
        else if (strchr(startNumberCharSet, c)) {
            NSUInteger start = i;
            do i++; while (i < full && !strchr(endSymbolCharSet, chars[i]));
            [iter addToken:BWTokenType_Number pos:start len:i - start];
        }
        else {
            NSUInteger start = i;
            do i++; while (i < full && !strchr(endSymbolCharSet, chars[i]));
            [iter addToken:BWTokenType_Symbol pos:start len:i - start];
        }
    }
    
    [iter addToken:BWTokenType_FileEnd pos:i len:0];
    
    iter.current = iter.head;
    return iter;
}










id<BWSeq> BWParseColl(BWTokenIter* iter, BWTokenType endTokenType, id<BWSeq> (*collFn)(NSArray* array));

BWObject* BWParseOne(BWTokenIter* iter) {
    BWToken* token = iter.current;
    
    if (token.type == BWTokenType_Symbol) {
        if ([token.val isEqualToString: @"true"])  { [iter advance]; return BWTrue; }
        if ([token.val isEqualToString: @"false"]) { [iter advance]; return BWFalse; }
        if ([token.val isEqualToString: @"nil"])   { [iter advance]; return BWNil; }
        
        BWObject* obj = [BWSymbol with: token.val];
        [iter advance];
        return obj;
    }
    else if (token.type == BWTokenType_Number) {
        BWObject* obj = [BWNumber with: token.val];
        [iter advance];
        return obj;
    }
    else if (token.type == BWTokenType_String) {
        BWObject* obj = [BWString with: token.val];
        [iter advance];
        return obj;
    }
    else if (token.type == BWTokenType_Regex) {
        BWObject* obj = [BWRegex with: token.val];
        [iter advance];
        return obj;
    }
    else if (token.type == BWTokenType_Keyword) {
        BWObject* obj = [BWKeyword with: token.val];
        [iter advance];
        return obj;
    }
    else if (token.type == BWTokenType_OpenAnonFn) {
        BWList* body = BWParseColl(iter, BWTokenType_RParen, BWListFromArray);
        
        BWVector* paramList = [[BWVector alloc] init];
        NSMutableArray* fnArray = [NSMutableArray array];
        [fnArray addObject: [BWSymbol with:@"fn"]];
        [fnArray addObject: paramList];
        [fnArray addObject: body];
        
        return [BWList fromArray:fnArray]; // the aforementioned +list and -append: would be great here
    }
    else if (token.type == BWTokenType_LParen) {
        return BWParseColl(iter, BWTokenType_RParen, BWListFromArray);
    }
    else if (token.type == BWTokenType_LBracket) {
        return BWParseColl(iter, BWTokenType_RBracket, BWVectorFromArray);
    }
    else if (token.type == BWTokenType_LBrace) {
        return BWParseColl(iter, BWTokenType_RBrace, BWMapFromArray);
    }
    else if (token.type == BWTokenType_OpenSet) {
        return BWParseColl(iter, BWTokenType_RBrace, BWSetFromArray);
    }
    else if (token.type == BWTokenType_Quote) {
        [iter advance];
        return [BWList listWithFirst:SYM(@"quote") second:BWParseOne(iter)];
    }
    else if (token.type == BWTokenType_UnQuote) {
        [iter advance];
        return [BWList listWithFirst:SYM(@"unquote") second:BWParseOne(iter)];
    }
    else if (token.type == BWTokenType_UnQuoteSplice) {
        [iter advance];
        return [BWList listWithFirst:SYM(@"unquote-splice") second:BWParseOne(iter)];
    }
    else if (token.type == BWTokenType_SyntaxQuote) {
        [iter advance];
        return [BWList listWithFirst:SYM(@"syntax-quote") second:BWParseOne(iter)];
    }
    else if (token.type == BWTokenType_TypeOp) {
        [iter advance];
        return [BWList listWithFirst:SYM(@"get-class") second:BWParseOne(iter)];
    }
    
    abort();
}

id<BWSeq> BWParseColl(BWTokenIter* iter, BWTokenType endTokenType, id<BWSeq> (*collFn)(NSArray* array)) {
    [iter advance];
    NSMutableArray* children = [NSMutableArray array];
    while (iter.current.type != endTokenType) {
        id child = BWParseOne(iter);
        [children addObject: child];
    }
    [iter advance];
    return collFn(children);
}

BWObject* BWEval(NSString* raw, BWEnv* env, BWEvalError*__autoreleasing* error) {
    BWInitialize();
    
    @try {
        BWTokenIter* iter = BWLex(raw);
        BWVector* rawForms = BWParseColl(iter, BWTokenType_FileEnd, BWVectorFromArray);
        BWVector* evaledForms = (BWVector*)[rawForms eval:env];
        return [evaledForms.array lastObject];
    }
    @catch (BWEvalError* e) {
        if (error)
            *error = e;
        return nil;
    }
}









@implementation BWEvalError

+ (void) reason:(NSString*)str pos:(NSUInteger)pos {
    BWEvalError* error = [[BWEvalError alloc] init];
    error.reason = str;
    error.pos = pos;
    @throw error;
}

@end











@implementation BWEnv

- (id) init {
    if (self = [super init]) {
        self.names = [NSMutableDictionary dictionary];
    }
    return self;
}

- (id) lookup:(NSString*)name {
    id found = [self.names objectForKey:name];
    if (found)
        return found;
    else
        return [self.parent lookup:name];
}

- (id) copyWithZone:(NSZone *)zone {
    BWEnv* newEnv = [[BWEnv alloc] init];
    newEnv.names = [self.names mutableCopy];
    newEnv.parent = [self.parent copy];
    return newEnv;
}

- (void) pinEnvOnTail:(BWEnv*)env {
    if (self.parent == nil)
        self.parent = env;
    else
        [[self parent] pinEnvOnTail: env];
}

@end














static BWObject* BWTestEval(NSString* raw, BWEnv* env) {
    BWEvalError *__autoreleasing error;
    BWObject* result = BWEval(raw, env, &error);
    assert(error == NULL);
    return result;
}

#define BWNUMBER(f) [BWNumber withDoubleValue: f]



void BWRunInternalTests(NSString* preludeContents) {
    BWEnv* env = BWFreshEnv();
    BWEval(preludeContents, env, NULL);
    
    assert([[(BWNumber*)BWEval(@"(+ 1 2)", env, NULL) value] isEqualToNumber:@3]);
    assert([[(BWNumber*)BWEval(@"(+ 1 (+ 2 3))", env, NULL) value] isEqualToNumber:@6]);
    assert([[BWEval(@"[1 2 3]", env, NULL) description] isEqualToString:@"[1 2 3]"]);
    assert([[BWEval(@"[(+ 2 3) 2 3]", env, NULL) description] isEqualToString:@"[5 2 3]"]);
    assert([[BWEval(@"(list 1 2 3)", env, NULL) description] isEqualToString:@"(1 2 3)"]);
    assert([[BWEval(@"{1 2 3 5}", env, NULL) description] isEqualToString:@"{1 2, 3 5}"]);
    
    assert([BWEval(@"1", env, NULL) isEqual: BWEval(@"1", env, NULL)]);
    assert([BWEval(@"[1 2 3]", env, NULL) isEqual: BWEval(@"[1 2 3]", env, NULL)]);
    assert([BWEval(@"(list 1 2 3)", env, NULL) isEqual: BWEval(@"(list 1 2 3)", env, NULL)]);
    assert([BWEval(@"{1 2}", env, NULL) isEqual: BWEval(@"{1 2}", env, NULL)]);
    assert([BWEval(@"(list 1 2 3)", env, NULL) isEqual: BWEval(@"'(1 2 3)", env, NULL)]);
    assert([BWEval(@"(list 1 (list '+ 1 2) 3)", env, NULL) isEqual: BWEval(@"'(1 (+ 1 2) 3)", env, NULL)]);
    assert([BWEval(@"'+", env, NULL) isEqual: SYM(@"+")]);
    assert([[BWEval(@":foo", env, NULL) class] isEqual: [BWKeyword self]]);
    assert([[(BWKeyword*)BWEval(@":foo", env, NULL) value] isEqual: @":foo"]);
    
    assert([[BWEval(@"\"foo\"", env, NULL) class] isEqual: [BWString self]]);
    assert([[(BWKeyword*)BWEval(@"\"foo\"", env, NULL) value] isEqual: @"\"foo\""]);
    
    assert([[(BWKeyword*)BWEval(@"\"f\\\"oo\"", env, NULL) value] isEqual: @"\"f\\\"oo\""]);
    
    assert(BWEval(@"true", env, NULL) == BWTrue);
    assert(BWEval(@"false", env, NULL) == BWFalse);
    assert(BWEval(@"nil", env, NULL) == BWNil);
    
    assert(BWEval(@";; foo bar (+ 1 2) \ntrue", env, NULL) == BWTrue);
    
    assert([BWTestEval(@"(cons 1 '(2 3))", env) isEqual: BWEval(@"'(1 2 3)", env, NULL)]);
    
    assert(BWTestEval(@"(= 1 1)", env) == BWTrue);
    assert(BWTestEval(@"(= 1 2)", env) == BWFalse);
    assert(BWTestEval(@"(= nil nil)", env) == BWTrue);
    assert(BWTestEval(@"(= nil false)", env) == BWFalse);
    assert(BWTestEval(@"(= false nil)", env) == BWFalse);
    assert(BWTestEval(@"(= false true)", env) == BWFalse);
    assert(BWTestEval(@"(= true false)", env) == BWFalse);
    assert(BWTestEval(@"(= true true)", env) == BWTrue);
    assert(BWTestEval(@"(= 'true true)", env) == BWTrue);
    
    assert([[(BWNumber*)BWTestEval(@"(if true 1)", env) value] isEqual: @1]);
    assert([BWTestEval(@"(if false 1)", env) isEqual: BWNil]);
    assert([BWTestEval(@"(if nil 1)", env) isEqual: BWNil]);
    assert([[(BWNumber*)BWTestEval(@"(if (= 2 2) 1)", env) value] isEqual: @1]);
    assert([BWTestEval(@"(if (= 1 2) 1)", env) isEqual: BWNil]);
    assert([[(BWNumber*)BWTestEval(@"(if (= 1 2) 1 1234)", env) value] isEqual: @1234]);
    
    assert(BWTestEval(@"(do 2 true)", env) == BWTrue);
    
    {
        BWEnv* env = BWFreshEnv();
        BWEval(preludeContents, env, NULL);
        
        assert([BWTestEval(@"(def a 2) (+ 1 a)", env) isEqual: BWNUMBER(3)]);
    }
    
    assert([BWTestEval(@"`(2 true)", env) isEqual: BWTestEval(@"(list 2 true)", env)]);
    assert([BWTestEval(@"`[2 true]", env) isEqual: BWTestEval(@"[2 true]", env)]);
    assert([BWTestEval(@"`(+ 1 (+ 2 3))", env) isEqual: BWTestEval(@"'(+ 1 (+ 2 3))", env)]);
    assert([BWTestEval(@"`(+ 1 ~(+ 2 3))", env) isEqual: BWTestEval(@"'(+ 1 5)", env)]);
    assert([BWTestEval(@"`[+ 1 ~(+ 2 3)]", env) isEqual: BWTestEval(@"['+ 1 5]", env)]);
    assert([BWTestEval(@"`[+ 1 ~(+ 2 (+ 1 2))]", env) isEqual: BWTestEval(@"['+ 1 5]", env)]);
    assert([BWTestEval(@"`(+ 1 ~['+ 2 3])", env) isEqual: BWTestEval(@"'(+ 1 [+ 2 3])", env)]);
    assert([BWTestEval(@"`{+ ~(+ 2 3)}", env) isEqual: BWTestEval(@"{'+ 5}", env)]);
    assert([BWTestEval(@"`(+ 1 ~@[2 (+ 1 2)])", env) isEqual: BWTestEval(@"'(+ 1 2 3)", env)]);
    assert([BWTestEval(@"`[+ 1 ~@[2 (+ 1 2)]]", env) isEqual: BWTestEval(@"'[+ 1 2 3]", env)]);
    
    // closures
    {
        assert([BWTestEval(@"((fn* [] 3))", env) isEqual: BWTestEval(@"3", env)]);
        assert([BWTestEval(@"((fn* [x] x) 2)", env) isEqual: BWTestEval(@"2", env)]);
        assert([BWTestEval(@"((fn* [x] (+ 1 x)) 2)", env) isEqual: BWTestEval(@"3", env)]);
        
        assert([BWTestEval(@"((macro* [x] `(+ 1 ~x)) 2)", env) isEqual: BWTestEval(@"3", env)]);
        assert([BWTestEval(@"((macro* [x] `(+ 1 ~x)) (+ 1 2))", env) isEqual: BWTestEval(@"4", env)]);
        
        assert([BWTestEval(@"((macro* [x] (cons + x)) (1 2))", env) isEqual: BWTestEval(@"3", env)]);
    }
    
    {
        BWEnv* env = BWFreshEnv();
        BWEval(preludeContents, env, NULL);
        assert([BWTestEval(@"(def a (fn* [x] (+ 1 x))) (a 3)", env) isEqual: BWTestEval(@"4", env)]);
    }
    
    {
        BWEnv* env = BWFreshEnv();
        BWEval(preludeContents, env, NULL);
        assert([BWTestEval(@"(defn foo [x] (+ 1 x)) (foo 2)", env) isEqual: BWTestEval(@"3", env)]);
    }
    
    {
        assert([BWTestEval(@"((fn* [a b c] [a b c]) 1 2 3)", env) isEqual: BWTestEval(@"[1 2 3]", env)]);
        assert([BWTestEval(@"((fn* [a b & c] [a b c]) 1 2 3 4 5)", env) isEqual: BWTestEval(@"[1 2 '(3 4 5)]", env)]);
    }
    
    {
        id d = @{@1: @2, @3: @5};
        assert([[BWEval(@"{1 2 3 5}", env, NULL) toObjC] isEqual: d]);
    }
    
    {
        id d = @[@1, @2, @{@3: @5}];
        assert([[BWEval(@"[1 2 {3 5}]", env, NULL) toObjC] isEqual: d]);
        assert([[BWEval(@"'(1 2 {3 5})", env, NULL) toObjC] isEqual: d]);
    }
    
    {
        id d = @[@1, @2, @{@3: @5}];
        assert([[BWEval(@"[1 2 {3 5}]", env, NULL) toObjC] isEqual: d]);
    }
    
    {
        assert([[BWEval(@"true", env, NULL) toObjC] isEqual: @YES]);
        assert([[BWEval(@"false", env, NULL) toObjC] isEqual: @NO]);
        assert([BWEval(@"nil", env, NULL) toObjC] == [NSNull null]);
        assert([[BWEval(@"\"foo\"", env, NULL) toObjC] isEqual: @"foo"]);
        assert([[BWEval(@":foo", env, NULL) toObjC] isEqual: @"foo"]);
        assert([[BWEval(@"'foo", env, NULL) toObjC] isEqual: @"foo"]);
    }
    
    assert([BWTestEval(@"(let* [x 1 y 2] (+ x y))", env) isEqual: BWTestEval(@"3", env)]);
    assert([BWTestEval(@"(loop* [x 0] (if (= x 2) :done (recur (+ x 1))))", env) isEqual: BWTestEval(@":done", env)]);
    
    assert([BWTestEval(@"((fn [a b c] [a b c]) 1 2 3)", env) isEqual: BWTestEval(@"[1 2 3]", env)]);
    
    {
        id d = @[@1, @2, [NSNull null]];
        assert([[BWTestEval(@"[1 2 nil]", env) toObjC] isEqual: d]);
    }
    
    assert([[BWTestEval(@"3", env) toObjC] isEqual: @3]);
    assert([[BWTestEval(@"123.4", env) toObjC] isEqual: @123.4]);
    assert([[BWTestEval(@"+3", env) toObjC] isEqual: @3]);
    assert([[BWTestEval(@"-3", env) toObjC] isEqual: @-3]);
    assert([[BWTestEval(@"-123.4", env) toObjC] isEqual: @-123.4]);
    
    {
        id s = [NSSet setWithObjects:@1, @2, @3, nil];
        assert([[BWTestEval(@"#{1 2 3}", env) toObjC] isEqual: s]);
    }
    
    {
        NSError* __autoreleasing error;
        assert([[BWTestEval(@"#\"foo\"", env) toObjC] isEqual: [NSRegularExpression regularExpressionWithPattern:@"foo" options:0 error:&error]]);
    }
    
    assert([BWTestEval(@"`[~@[3]]", env) isEqual: BWTestEval(@"[3]", env)]);
    assert([BWTestEval(@"`[~@[]]", env) isEqual: BWTestEval(@"[]", env)]);
    
    assert([BWTestEval(@"(first [])", env) isEqual: BWTestEval(@"nil", env)]);
    
    assert([BWTestEval(@"(#(+ 1 2))", env) isEqual: BWTestEval(@"3", env)]);
    
    assert([BWTestEval(@"(- 3 2)", env) isEqual: BWTestEval(@"1", env)]);
    
    assert([BWTestEval(@"(< 1 2)", env) isEqual: BWTestEval(@"true", env)]);
    assert([BWTestEval(@"(< 2 2)", env) isEqual: BWTestEval(@"false", env)]);
    assert([BWTestEval(@"(< 3 2)", env) isEqual: BWTestEval(@"false", env)]);
}
