//
//  parser.mm
//  Leviathan
//
//  Created by Steven on 10/19/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "parser.h"

#import "lexer.h"
#import "atom.h"

#import "LVParseError.h"

static LVColl* parseColl(LVToken*** iter, LVCollType collType, LVTokenType endTokenType);

static LVElement* parseOne(LVToken*** iter) {
    LVToken* currentToken = **iter;
    
    if (currentToken->token_type & LVTokenType_LParen) {
        return (LVElement*)parseColl(iter, LVCollType_List, LVTokenType_RParen);
    }
    else if (currentToken->token_type & LVTokenType_LBracket) {
        return (LVElement*)parseColl(iter, LVCollType_Vector, LVTokenType_RBracket);
    }
    else if (currentToken->token_type & LVTokenType_LBrace) {
        return (LVElement*)parseColl(iter, LVCollType_Map, LVTokenType_RBrace);
    }
    else if (currentToken->token_type & LVTokenType_AnonFnStart) {
        return (LVElement*)parseColl(iter, LVCollType_AnonFn, LVTokenType_RParen);
    }
    else if (currentToken->token_type & LVTokenType_SetStart) {
        return (LVElement*)parseColl(iter, LVCollType_Set, LVTokenType_RBrace);
    }
    else if (currentToken->token_type & LVTokenType_Spaces) {
        ++*iter;
        return (LVElement*)LVAtomCreate(LVAtomType_Spaces, currentToken);
    }
    else if (currentToken->token_type & LVTokenType_Var) {
        ++*iter;
        return (LVElement*)LVAtomCreate(LVAtomType_Var, currentToken);
    }
    else if (currentToken->token_type & LVTokenType_ReaderMacro) {
        ++*iter;
        return (LVElement*)LVAtomCreate(LVAtomType_ReaderMacro, currentToken);
    }
    else if (currentToken->token_type & LVTokenType_Number) {
        ++*iter;
        return (LVElement*)LVAtomCreate(LVAtomType_Number, currentToken);
    }
    else if (currentToken->token_type & LVTokenType_TypeOp) {
        ++*iter;
        return (LVElement*)LVAtomCreate(LVAtomType_TypeOp, currentToken);
    }
    else if (currentToken->token_type & LVTokenType_Quote) {
        ++*iter;
        return (LVElement*)LVAtomCreate(LVAtomType_Quote, currentToken);
    }
    else if (currentToken->token_type & LVTokenType_Unquote) {
        ++*iter;
        return (LVElement*)LVAtomCreate(LVAtomType_Unquote, currentToken);
    }
    else if (currentToken->token_type & LVTokenType_SyntaxQuote) {
        ++*iter;
        return (LVElement*)LVAtomCreate(LVAtomType_SyntaxQuote, currentToken);
    }
    else if (currentToken->token_type & LVTokenType_Splice) {
        ++*iter;
        return (LVElement*)LVAtomCreate(LVAtomType_Splice, currentToken);
    }
    else if (currentToken->token_type & LVTokenType_Keyword) {
        ++*iter;
        return (LVElement*)LVAtomCreate(LVAtomType_Keyword, currentToken);
    }
    else if (currentToken->token_type & LVTokenType_String) {
        ++*iter;
        return (LVElement*)LVAtomCreate(LVAtomType_String, currentToken);
    }
    else if (currentToken->token_type & LVTokenType_Regex) {
        ++*iter;
        return (LVElement*)LVAtomCreate(LVAtomType_Regex, currentToken);
    }
    else if (currentToken->token_type & LVTokenType_CommentLiteral) {
        ++*iter;
        return (LVElement*)LVAtomCreate(LVAtomType_Comment, currentToken);
    }
    else if (currentToken->token_type & LVTokenType_Newlines) {
        ++*iter;
        return (LVElement*)LVAtomCreate(LVAtomType_Newlines, currentToken);
    }
    else if (currentToken->token_type & LVTokenType_Comma) {
        ++*iter;
        return (LVElement*)LVAtomCreate(LVAtomType_Comma, currentToken);
    }
    else if (currentToken->token_type & LVTokenType_ReaderCommentStart) {
        // TODO: reader-comments could be considered a type of list, with "#_" as the opening token and "" as the closing
        ++*iter;
        return (LVElement*)LVAtomCreate(LVAtomType_ReaderComment, currentToken);
    }
    else if (currentToken->token_type & LVTokenType_Symbol) {
        ++*iter;
        LVAtom* atom = LVAtomCreate(LVAtomType_Symbol, currentToken);
        
             if (currentToken->token_type & LVTokenType_TrueSymbol)  atom->atom_type |= LVAtomType_TrueAtom;
        else if (currentToken->token_type & LVTokenType_FalseSymbol) atom->atom_type |= LVAtomType_FalseAtom;
        else if (currentToken->token_type & LVTokenType_NilSymbol)   atom->atom_type |= LVAtomType_NilAtom;
        
        return (LVElement*)atom;
    }
    else if (currentToken->token_type & LVTokenType_FileEnd) {
        printf("reached end of tokens too early\n");
        @throw [LVParseError exceptionWithName:@"uhh" reason:@"heh" userInfo:nil];
    }
    
    printf("Can't handle this token type: %llu, %s\n", currentToken->token_type, CFStringGetCStringPtr(currentToken->string, kCFStringEncodingUTF8));
    @throw [LVParseError exceptionWithName:@"uhh" reason:@"heh" userInfo:nil];
}

static LVColl* parseColl(LVToken*** iter, LVCollType collType, LVTokenType endTokenType) {
    LVColl* coll = LVCollCreate();
    coll->coll_type = collType;
    
    LVElementListAppend(coll, (LVElement*)LVAtomCreate(LVAtomType_CollDelim | LVAtomType_CollOpener, **iter));
    
    ++*iter;
    
    for (LVToken* currentToken; ; ) {
        currentToken = **iter;
        
        if (currentToken->token_type == endTokenType) {
            LVElementListAppend(coll, (LVElement*)LVAtomCreate(LVAtomType_CollDelim | LVAtomType_CollCloser, currentToken));
            ++*iter;
            break;
        }
        
        if (currentToken->token_type == LVTokenType_FileEnd) {
            printf("unclosed coll somewhere :(\n");
            @throw [LVParseError exceptionWithName:@"uhh" reason:@"heh" userInfo:nil];
        }
        
        LVElement* child = parseOne(iter);
        LVElementListAppend(coll, child);
    }
    
    if (coll->coll_type & LVCollType_List) {
        LVAtom* defAtom = nil;
        
        BOOL lastWasTypeOp = NO;
        
        for (int i = 0; i < coll->children_len; i++) {
            LVElement* child = coll->children[i];
            LVAtom* atom = (void*)child;
            
            if (!atom->is_atom || !LVAtomIsSemantic(atom))
                continue;
            
            // finally found a semantic atom!
            
            if (!defAtom) {
                // it's the first one, too!
                
                if (atom->token->token_type & LVTokenType_Deflike) {
                    defAtom = atom;
                    // it's deflike!
                }
                else {
                    // womp womp, it's not deflike.
                    break;
                }
            }
            else {
                if (atom->atom_type & LVAtomType_TypeOp) {
                    lastWasTypeOp = YES;
                    continue;
                }
                
                if (lastWasTypeOp) {
                    lastWasTypeOp = NO;
                    continue;
                }
                
                lastWasTypeOp = NO;
                
                LVAtom* defName = atom;
                coll->coll_type |= LVCollType_Definition;
                defAtom->atom_type |= LVAtomType_DefType;
                defName->atom_type |= LVAtomType_DefName;
                
                break;
            }
        }
    }
    
    return coll;
}

LVColl* LVParseTokens(LVToken** tokens) {
    LVColl* topLevelColl = parseColl(&tokens, LVCollType_TopLevel, LVTokenType_FileEnd);
    topLevelColl->parent = NULL;
    return topLevelColl;
}
