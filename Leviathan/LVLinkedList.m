//
//  LVLinkedList.m
//  Leviathan
//
//  Created by Steven Degutis on 10/23/13.
//  Copyright (c) 2013 Steven Degutis. All rights reserved.
//

#import "LVLinkedList.h"

LVLinkedList* LVLinkedListCreate() {
    LVLinkedList* list = malloc(sizeof(LVLinkedList));
    list->head = NULL;
    list->len = 0;
    return list;
}

void LVLinkedListDestroy(LVLinkedList* list) {
    free(list);
}

void LVLinkedListAppend(LVLinkedList* list, void* ptr) {
    LVLinkedListNode* node = malloc(sizeof(LVLinkedListNode));
    node->prev = NULL;
    node->next = NULL;
    node->val = ptr;
    
    if (list->head) {
        LVLinkedListNode* lastNode = list->head;
        while (lastNode->next)
            lastNode = lastNode->next;
        lastNode->next = node;
        node->prev = lastNode;
    }
    else {
        list->head = node;
    }
    
    list->len++;
}
