//
//  LVTestBed.m
//  Leviathan
//
//  Created by Steven on 10/19/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVTestBed.h"

#import "lexer.h"
#import "coll.h"
#import "parser.h"
#import "atom.h"

#import "linked_list.h"

struct LVTokenList {
    LVToken** toks;
    size_t size;
};

#define TOKARRAY(...) ((LVToken*[]){ __VA_ARGS__ })
#define TOKCOUNT(...) (sizeof(TOKARRAY(__VA_ARGS__)) / sizeof(LVToken*))
#define TOKLIST(...) ((struct LVTokenList){TOKARRAY(__VA_ARGS__), TOKCOUNT(__VA_ARGS__)})
#define TOK(typ, chr) LVTokenCreate(typ, bfromcstr(chr))

static void LVLexerShouldEqual(char* raw, struct LVTokenList expected) {
    size_t actual_size;
    LVToken** tokens = LVLex(raw, &actual_size);
    
    if (actual_size != expected.size) {
        printf("wrong size: %s\n", raw);
        printf("want:\n");
        for (size_t i = 0; i < expected.size; i++) {
            LVToken* tok = expected.toks[i];
            printf("[%s]\n", tok->val->data);
        }
        printf("got:\n");
        for (size_t i = 0; i < actual_size; i++) {
            LVToken* tok = tokens[i];
            printf("[%s]\n", tok->val->data);
        }
        exit(1);
    }
    
    for (size_t i = 0; i < actual_size; i++) {
        LVToken* t1 = tokens[i];
        LVToken* t2 = expected.toks[i];
        
        if (t1->type != t2->type) {
            printf("wrong token type for: %s\n", raw);
            printf("want val %s, got val %s\n", t2->val->data, t1->val->data);
            printf("want %llu, got %llu\n", t2->type, t1->type);
            exit(1);
        }
        
        if (bstrcmp(t1->val, t2->val) != 0) {
            printf("wrong token string for: %s\n", raw);
            printf("want %s, got %s\n", t2->val->data, t1->val->data);
            exit(1);
        }
    }
}

@implementation LVTestBed

+ (void) runTests {
    LVLexerShouldEqual("(foobar)", TOKLIST(TOK(LVTokenType_FileBegin, ""), TOK(LVTokenType_LParen, "("), TOK(LVTokenType_Symbol, "foobar"), TOK(LVTokenType_RParen, ")"), TOK(LVTokenType_FileEnd, "")));
    
    LVLexerShouldEqual("foobar", TOKLIST(TOK(LVTokenType_FileBegin, ""), TOK(LVTokenType_Symbol, "foobar"), TOK(LVTokenType_FileEnd, "")));
    LVLexerShouldEqual("(    foobar", TOKLIST(TOK(LVTokenType_FileBegin, ""), TOK(LVTokenType_LParen, "("), TOK(LVTokenType_Spaces, "    "), TOK(LVTokenType_Symbol, "foobar"), TOK(LVTokenType_FileEnd, "")));
    
    LVLexerShouldEqual("~", TOKLIST(TOK(LVTokenType_FileBegin, ""), TOK(LVTokenType_Unquote, "~"), TOK(LVTokenType_FileEnd, "")));
    LVLexerShouldEqual("~@", TOKLIST(TOK(LVTokenType_FileBegin, ""), TOK(LVTokenType_Splice, "~@"), TOK(LVTokenType_FileEnd, "")));
    
    LVLexerShouldEqual("\"yes\"", TOKLIST(TOK(LVTokenType_FileBegin, ""), TOK(LVTokenType_String, "\"yes\""), TOK(LVTokenType_FileEnd, "")));
    LVLexerShouldEqual("\"y\\\"es\"", TOKLIST(TOK(LVTokenType_FileBegin, ""), TOK(LVTokenType_String, "\"y\\\"es\""), TOK(LVTokenType_FileEnd, "")));
    
    LVLexerShouldEqual(";foobar\nhello", TOKLIST(TOK(LVTokenType_FileBegin, ""), TOK(LVTokenType_CommentLiteral, ";foobar"), TOK(LVTokenType_Newline, "\n"), TOK(LVTokenType_Symbol, "hello"), TOK(LVTokenType_FileEnd, "")));
    
    LVLexerShouldEqual("foo 123 :hello", TOKLIST(TOK(LVTokenType_FileBegin, ""), TOK(LVTokenType_Symbol, "foo"), TOK(LVTokenType_Spaces, " "), TOK(LVTokenType_Number, "123"), TOK(LVTokenType_Spaces, " "), TOK(LVTokenType_Keyword, ":hello"), TOK(LVTokenType_FileEnd, "")));
    
    LVLexerShouldEqual("#'foo", TOKLIST(TOK(LVTokenType_FileBegin, ""), TOK(LVTokenType_Var, "#'foo"), TOK(LVTokenType_FileEnd, "")));
    LVLexerShouldEqual("#(foo)", TOKLIST(TOK(LVTokenType_FileBegin, ""), TOK(LVTokenType_AnonFnStart, "#("), TOK(LVTokenType_Symbol, "foo"), TOK(LVTokenType_RParen, ")"), TOK(LVTokenType_FileEnd, "")));
    LVLexerShouldEqual("#{foo}", TOKLIST(TOK(LVTokenType_FileBegin, ""), TOK(LVTokenType_SetStart, "#{"), TOK(LVTokenType_Symbol, "foo"), TOK(LVTokenType_RBrace, "}"), TOK(LVTokenType_FileEnd, "")));
    LVLexerShouldEqual("#_foo", TOKLIST(TOK(LVTokenType_FileBegin, ""), TOK(LVTokenType_ReaderCommentStart, "#_"), TOK(LVTokenType_Symbol, "foo"), TOK(LVTokenType_FileEnd, "")));
    LVLexerShouldEqual("#foo bar", TOKLIST(TOK(LVTokenType_FileBegin, ""), TOK(LVTokenType_ReaderMacro, "#foo"), TOK(LVTokenType_Spaces, " "), TOK(LVTokenType_Symbol, "bar"), TOK(LVTokenType_FileEnd, "")));
    
    LVLexerShouldEqual("#\"yes\"", TOKLIST(TOK(LVTokenType_FileBegin, ""), TOK(LVTokenType_Regex, "#\"yes\""), TOK(LVTokenType_FileEnd, "")));
    LVLexerShouldEqual("#\"y\\\"es\"", TOKLIST(TOK(LVTokenType_FileBegin, ""), TOK(LVTokenType_Regex, "#\"y\\\"es\""), TOK(LVTokenType_FileEnd, "")));
    
    
    {
        LVLinkedList* list = LVLinkedListCreate();
        
        char* foo = "foo";
        char* bar = "bar";
        
        assert(list->len == 0);
        assert(list->head == NULL);
        
        LVLinkedListAppend(list, foo);
        
        assert(list->len == 1);
        assert(list->head != NULL);
        assert(list->head->val == foo);
        assert(list->head->prev == NULL);
        assert(list->head->next == NULL);
        
        LVLinkedListAppend(list, bar);
        
        assert(list->len == 2);
        assert(list->head != NULL);
        assert(list->head->val == foo);
        assert(list->head->prev == NULL);
        assert(list->head->next != NULL);
        assert(list->head->next->val == bar);
        assert(list->head->next->prev == list->head);
        assert(list->head->next->next == NULL);
        
        LVLinkedListDestroy(list);
    }
    
    {
        LVLinkedList* list = LVLinkedListCreate();
        
        char* foo = "foo";
        char* bar = "bar";
        char* quux = "quux";
        
//        for (LVLinkedListNode* node = list->head; node; node = node->next) {
//            printf("%s\n", node->val);
//        }
        
        LVLinkedListAppend(list, foo);
        LVLinkedListAppend(list, bar);
        LVLinkedListAppend(list, quux);
        
//        LVLinkedListRemove(list, 1, 1);
        
//        for (LVLinkedListNode* node = list->head; node; node = node->next) {
//            printf("%s\n", node->val);
//        }
        
//        assert(list->len == 2);
//        assert(list->head != NULL);
//        assert(list->head->val == foo);
//        assert(list->head->prev == NULL);
//        assert(list->head->next != NULL);
//        assert(list->head->next->val == bar);
//        assert(list->head->next->prev == list->head);
//        assert(list->head->next->next == NULL);
        
        LVLinkedListDestroy(list);
    }
    
    
    
    
    
    
    {
        LVColl* top = LVParse("foo");
        assert(top->collType == LVCollType_TopLevel);
        assert(top->children.len == 1);
        
        LVAtom* atom = (void*)top->children.elements[0];
        assert(atom->elementType == LVElementType_Atom);
        assert(atom->atomType == LVAtomType_Symbol);
        assert(atom->token->type == LVTokenType_Symbol);
        assert(biseq(atom->token->val, bfromcstr("foo")));
        
        LVCollDestroy(top);
    }
    
    {
        LVColl* top = LVParse("(foo)");
        assert(top->collType == LVCollType_TopLevel);
        assert(top->children.len == 1);
        
        LVColl* list = (void*)top->children.elements[0];
        assert(list->elementType == LVElementType_Coll);
        assert(list->collType == LVCollType_List);
        assert(list->children.len == 1);
        
        LVAtom* atom = (void*)list->children.elements[0];
        assert(atom->elementType == LVElementType_Atom);
        assert(atom->atomType == LVAtomType_Symbol);
        assert(atom->token->type == LVTokenType_Symbol);
        assert(biseq(atom->token->val, bfromcstr("foo")));
        
        LVCollDestroy(top);
    }
    
    {
        LVColl* top = LVParse("[foo]");
        assert(top->collType == LVCollType_TopLevel);
        assert(top->children.len == 1);
        
        LVColl* list = (void*)top->children.elements[0];
        assert(list->elementType == LVElementType_Coll);
        assert(list->collType == LVCollType_Vector);
        assert(list->children.len == 1);
        
        LVAtom* atom = (void*)list->children.elements[0];
        assert(atom->elementType == LVElementType_Atom);
        assert(atom->atomType == LVAtomType_Symbol);
        assert(atom->token->type == LVTokenType_Symbol);
        assert(biseq(atom->token->val, bfromcstr("foo")));
        
        LVCollDestroy(top);
    }
    
    {
        LVColl* top = LVParse("#(foo)");
        assert(top->collType == LVCollType_TopLevel);
        assert(top->children.len == 1);
        
        LVColl* list = (void*)top->children.elements[0];
        assert(list->elementType == LVElementType_Coll);
        assert(list->collType == LVCollType_AnonFn);
        assert(list->children.len == 1);
        
        LVAtom* atom = (void*)list->children.elements[0];
        assert(atom->elementType == LVElementType_Atom);
        assert(atom->atomType == LVAtomType_Symbol);
        assert(atom->token->type == LVTokenType_Symbol);
        assert(biseq(atom->token->val, bfromcstr("foo")));
        
        LVCollDestroy(top);
    }
    
    {
        LVColl* top = LVParse("{foo bar}");
        assert(top->collType == LVCollType_TopLevel);
        assert(top->children.len == 1);
        
        LVColl* list = (void*)top->children.elements[0];
        assert(list->elementType == LVElementType_Coll);
        assert(list->collType == LVCollType_Map);
        assert(list->children.len == 3);
        
        {
            LVAtom* atom = (void*)list->children.elements[0];
            assert(atom->elementType == LVElementType_Atom);
            assert(atom->atomType == LVAtomType_Symbol);
            assert(atom->token->type == LVTokenType_Symbol);
            assert(biseq(atom->token->val, bfromcstr("foo")));
        }
        
        {
            LVAtom* atom = (void*)list->children.elements[1];
            assert(atom->elementType == LVElementType_Atom);
            assert(atom->atomType == LVAtomType_Spaces);
            assert(atom->token->type == LVTokenType_Spaces);
            assert(biseq(atom->token->val, bfromcstr(" ")));
        }
        
        {
            LVAtom* atom = (void*)list->children.elements[2];
            assert(atom->elementType == LVElementType_Atom);
            assert(atom->atomType == LVAtomType_Symbol);
            assert(atom->token->type == LVTokenType_Symbol);
            assert(biseq(atom->token->val, bfromcstr("bar")));
        }
        
        LVCollDestroy(top);
    }
    
    {
        LVColl* top = LVParse("123");
        assert(top->collType == LVCollType_TopLevel);
        assert(top->children.len == 1);
        
        LVAtom* atom = (void*)top->children.elements[0];
        assert(atom->elementType == LVElementType_Atom);
        assert(atom->atomType == LVAtomType_Number);
        assert(atom->token->type == LVTokenType_Number);
        assert(biseq(atom->token->val, bfromcstr("123")));
        
        LVCollDestroy(top);
    }
    
    {
        LVColl* top = LVParse(":bla");
        assert(top->collType == LVCollType_TopLevel);
        assert(top->children.len == 1);
        
        LVAtom* atom = (void*)top->children.elements[0];
        assert(atom->elementType == LVElementType_Atom);
        assert(atom->atomType == LVAtomType_Keyword);
        assert(atom->token->type == LVTokenType_Keyword);
        assert(biseq(atom->token->val, bfromcstr(":bla")));
        
        LVCollDestroy(top);
    }
    
    {
        LVColl* top = LVParse("((baryes)foo((no)))");
        LVCollDestroy(top);
    }
    
    {
        LVColl* top = LVParse("((bar yes) foo ((no)))");
        LVCollDestroy(top);
    }
    
    printf("ok\n");
    [NSApp terminate:self];
}

@end
