//
//  LVHighlighter.m
//  Leviathan
//
//  Created by Steven on 10/18/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVHighlighter.h"

#import "LVThemeManager.h"
#import "coll.h"
#import "atom.h"


@interface LVHighlighter ()

@property NSDictionary* tempStyle1;
@property NSDictionary* tempStyle2;

@end

@implementation LVHighlighter

+ (LVHighlighter*) sharedHighlighter {
    static LVHighlighter* highlighter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        highlighter = [[LVHighlighter alloc] init];
        [highlighter setup];
    });
    return highlighter;
}

- (void) setup {
    self.tempStyle1 = @{NSForegroundColorAttributeName: [NSColor redColor], NSFontAttributeName: [NSFont fontWithName:@"Arial" size:15]};
    self.tempStyle2 = @{NSForegroundColorAttributeName: [NSColor blueColor], NSFontAttributeName: [NSFont fontWithName:@"Arial" size:15]};
}

- (NSDictionary*) attributesForTree:(LVColl*)topLevelColl atPosition:(NSUInteger)absPos effectiveRange:(NSRange*)rangePtr {
    size_t childsIndex;
    LVColl* foundColl = LVFindDeepestColl(topLevelColl, 0, absPos, &childsIndex);
    
    LVToken* foundToken = NULL;
    
    if (childsIndex == foundColl->children_len) {
        // we're at its end_token
        if (rangePtr) rangePtr->location = LVGetAbsolutePosition((void*)foundColl) + LVElementLength((void*)foundColl) - foundColl->close_token->string->slen;
        foundToken = foundColl->close_token;
    }
    else {
        // we're at another legit element
        LVElement* child = foundColl->children[childsIndex];
        
        if (rangePtr) rangePtr->location = LVGetAbsolutePosition(child);
        
        if (child->is_atom) {
            // we're an atom!
            foundToken = ((LVAtom*)child)->token;
        }
        else {
            // we're really at its open-token
            foundToken = ((LVColl*)child)->open_token;
        }
    }
    
    if (rangePtr) rangePtr->length = foundToken->string->slen;
    
    
    
    NSDictionary* attrs;
    
    if (foundToken->token_type & LVTokenType_Symbol)
        attrs = self.tempStyle1;
    else
        attrs = self.tempStyle2;
    
    return attrs;
}

@end



//
//static void highlight(LVElement* element, NSTextStorage* attrString, int deepness, size_t* startPos) {
//    if (!element->is_atom) {
//        LVColl* coll = (void*)element;
//        
//        BOOL notTopLevel = !(coll->coll_type & LVCollType_TopLevel);
//        
//        LVThemeStyle* rainbows = [LVThemeManager sharedThemeManager].currentTheme.rainbowparens;
//        
//        if (notTopLevel) {
//            [rainbows highlightIn:attrString range:NSMakeRange(*startPos, coll->open_token->string->slen) depth:deepness];
//            *startPos += coll->open_token->string->slen;
//        }
//        
//        for (int i = 0; i < coll->children_len; i++) {
//            LVElement* child = coll->children[i];
//            highlight(child, attrString, deepness + 1, startPos);
//        }
//        
//        if (notTopLevel) {
//            [rainbows highlightIn:attrString range:NSMakeRange(*startPos, coll->close_token->string->slen) depth:deepness];
//            *startPos += coll->close_token->string->slen;
//        }
//    }
//    else {
//        LVAtom* atom = (void*)element;
//        
//        LVTheme* theme = [LVThemeManager sharedThemeManager].currentTheme;
//        LVThemeStyle* style;
//        
//        if (atom->atom_type & LVAtomType_DefType) style = theme.def;
//        else if (atom->atom_type & LVAtomType_DefName) style = theme.defname;
//        else if (atom->atom_type & LVAtomType_Symbol) style = theme.symbol;
//        else if (atom->atom_type & LVAtomType_Keyword) style = theme.keyword;
//        else if (atom->atom_type & LVAtomType_String) style = theme.string;
//        else if (atom->atom_type & LVAtomType_Regex) style = theme.regex;
//        else if (atom->atom_type & LVAtomType_Number) style = theme.number;
//        else if (atom->atom_type & LVAtomType_TrueAtom) style = theme._true;
//        else if (atom->atom_type & LVAtomType_FalseAtom) style = theme._false;
//        else if (atom->atom_type & LVAtomType_NilAtom) style = theme._nil;
//        else if (atom->atom_type & LVAtomType_Comment) style = theme.comment;
//        else if (atom->atom_type & LVAtomType_TypeOp) style = theme.typeop;
//        else if (atom->atom_type & LVAtomType_Quote) style = theme.quote;
//        else if (atom->atom_type & LVAtomType_Unquote) style = theme.unquote;
//        else if (atom->atom_type & LVAtomType_SyntaxQuote) style = theme.syntaxquote;
//        else if (atom->atom_type & LVAtomType_Splice) style = theme.splice;
//        
//        [style highlightIn: attrString range: NSMakeRange(*startPos, atom->token->string->slen) depth: deepness];
//        
//        *startPos += atom->token->string->slen;
//    }
//}
//
//void LVHighlight(LVElement* element, NSTextStorage* attrString, NSUInteger startPos) {
//    int depth = 0;
//    
//    LVElement* iter = element;
//    
//    while (iter->parent) {
//        depth++;
//        iter = (void*)iter->parent;
//    }
//    
//    highlight(element, attrString, depth, &startPos);
//}
