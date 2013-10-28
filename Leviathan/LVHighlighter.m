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


@implementation LVHighlighter

+ (LVHighlighter*) sharedHighlighter {
    static LVHighlighter* highlighter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        highlighter = [[LVHighlighter alloc] init];
    });
    return highlighter;
}

- (NSDictionary*) attributesForTree:(LVDoc*)doc atPosition:(NSUInteger)absPos effectiveRange:(NSRange*)rangePtr {
    LVAtom* atom = LVFindAtom(doc, absPos);
    
    if (rangePtr) {
        rangePtr->location = atom->token->pos;
        rangePtr->length = atom->token->string->slen;
    }
    
    LVTheme* theme = [LVThemeManager sharedThemeManager].currentTheme;
    
    if (atom->atom_type & LVAtomType_Spaces) return theme.symbol.attrs;
    if (atom->atom_type & LVAtomType_Newline) return theme.symbol.attrs;
    if (atom->atom_type & LVAtomType_Comma) return theme.symbol.attrs;
    
    if (atom->atom_type & LVAtomType_DefType) return theme.def.attrs;
    if (atom->atom_type & LVAtomType_DefName) return theme.defname.attrs;
    if (atom->atom_type & LVAtomType_Symbol) return theme.symbol.attrs;
    if (atom->atom_type & LVAtomType_Keyword) return theme.keyword.attrs;
    if (atom->atom_type & LVAtomType_String) return theme.string.attrs;
    if (atom->atom_type & LVAtomType_Regex) return theme.regex.attrs;
    if (atom->atom_type & LVAtomType_Number) return theme.number.attrs;
    if (atom->atom_type & LVAtomType_TrueAtom) return theme._true.attrs;
    if (atom->atom_type & LVAtomType_FalseAtom) return theme._false.attrs;
    if (atom->atom_type & LVAtomType_NilAtom) return theme._nil.attrs;
    if (atom->atom_type & LVAtomType_Comment) return theme.comment.attrs;
    if (atom->atom_type & LVAtomType_TypeOp) return theme.typeop.attrs;
    if (atom->atom_type & LVAtomType_Quote) return theme.quote.attrs;
    if (atom->atom_type & LVAtomType_Unquote) return theme.unquote.attrs;
    if (atom->atom_type & LVAtomType_SyntaxQuote) return theme.syntaxquote.attrs;
    if (atom->atom_type & LVAtomType_Splice) return theme.splice.attrs;
    
    if (atom->atom_type & LVAtomType_CollDelim) {
        size_t depth = LVGetElementDepth((void*)atom);
        NSArray* rainbows = [LVThemeManager sharedThemeManager].currentTheme.rainbowparens;
        LVThemeStyle* style = [rainbows objectAtIndex: depth % [rainbows count]];
        return style.attrs;
    }
    
//    size_t childsIndex;
//    LVColl* foundColl = LVFindDeepestColl(topLevelColl, 0, absPos, &childsIndex);
//    
//    LVToken* foundToken = NULL;
//    LVAtom* foundAtom = NULL;
//    
//    size_t depth = LVGetElementDepth((void*)foundColl);
//    
//    if (childsIndex == foundColl->children_len) {
//        // we're at its end_token
//        depth--;
//        if (rangePtr) rangePtr->location = LVGetAbsolutePosition((void*)foundColl) + LVElementLength((void*)foundColl) - foundColl->close_token->string->slen;
//        foundToken = foundColl->close_token;
//    }
//    else {
//        // we're at another legit element
//        LVElement* child = foundColl->children[childsIndex];
//        
//        if (rangePtr) rangePtr->location = LVGetAbsolutePosition(child);
//        
//        if (child->is_atom) {
//            // we're an atom!
//            foundAtom = (LVAtom*)child;
//            foundToken = foundAtom->token;
//        }
//        else {
//            // we're really at its open-token
//            foundToken = ((LVColl*)child)->open_token;
//        }
//    }
//    
//    if (rangePtr) rangePtr->length = foundToken->string->slen;
//    
//    LVTheme* theme = [LVThemeManager sharedThemeManager].currentTheme;
//    
//    if (foundAtom) {
//        if (foundAtom->atom_type & LVAtomType_Spaces) return theme.symbol.attrs;
//        if (foundAtom->atom_type & LVAtomType_Newline) return theme.symbol.attrs;
//        if (foundAtom->atom_type & LVAtomType_Comma) return theme.symbol.attrs;
//        
//        if (foundAtom->atom_type & LVAtomType_DefType) return theme.def.attrs;
//        if (foundAtom->atom_type & LVAtomType_DefName) return theme.defname.attrs;
//        if (foundAtom->atom_type & LVAtomType_Symbol) return theme.symbol.attrs;
//        if (foundAtom->atom_type & LVAtomType_Keyword) return theme.keyword.attrs;
//        if (foundAtom->atom_type & LVAtomType_String) return theme.string.attrs;
//        if (foundAtom->atom_type & LVAtomType_Regex) return theme.regex.attrs;
//        if (foundAtom->atom_type & LVAtomType_Number) return theme.number.attrs;
//        if (foundAtom->atom_type & LVAtomType_TrueAtom) return theme._true.attrs;
//        if (foundAtom->atom_type & LVAtomType_FalseAtom) return theme._false.attrs;
//        if (foundAtom->atom_type & LVAtomType_NilAtom) return theme._nil.attrs;
//        if (foundAtom->atom_type & LVAtomType_Comment) return theme.comment.attrs;
//        if (foundAtom->atom_type & LVAtomType_TypeOp) return theme.typeop.attrs;
//        if (foundAtom->atom_type & LVAtomType_Quote) return theme.quote.attrs;
//        if (foundAtom->atom_type & LVAtomType_Unquote) return theme.unquote.attrs;
//        if (foundAtom->atom_type & LVAtomType_SyntaxQuote) return theme.syntaxquote.attrs;
//        if (foundAtom->atom_type & LVAtomType_Splice) return theme.splice.attrs;
//    }
//    else {
//        NSArray* rainbows = [LVThemeManager sharedThemeManager].currentTheme.rainbowparens;
//        LVThemeStyle* style = [rainbows objectAtIndex: depth % [rainbows count]];
//        return style.attrs;
//    }
//    
    abort();
}

@end




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
