//
//  LVLinkedList.h
//  Leviathan
//
//  Created by Steven Degutis on 10/23/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

typedef struct __LVLinkedListNode LVLinkedListNode;

struct __LVLinkedListNode {
    LVLinkedListNode* prev;
    LVLinkedListNode* next;
    void* val;
};

typedef struct __LVLinkedList {
    LVLinkedListNode* head;
    size_t len;
} LVLinkedList;

LVLinkedList* LVLinkedListCreate();
void LVLinkedListDestroy(LVLinkedList* list);

void LVLinkedListAppend(LVLinkedList* list, void* ptr);
