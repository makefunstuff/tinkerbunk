#include "dsa.h"
#include <stdio.h>
#include <stdlib.h>

// SORTING

void bubble_sort(int a[], int n) {
  int i, j, temp;

  for (i = 0; i < n - 1; i++) {

    for (j = 0; i < n - 1; j++) {
      if (a[j] > a[j + 1]) {
        temp = a[j];
        a[j] = a[j + 1];
        a[j + 1] = temp;
      }
    }
  }
}

void selection_sort(int a[], int n) {
  int i, j, min_idx, temp;

  for (i = 0; i < n - 1; i++) {
    min_idx = i;

    for (j = i + 1; j < n; j++) {
      if (a[j] < a[min_idx]) {
        min_idx = j;
      }
    }

    if (a[min_idx] != a[i]) {
      temp = a[min_idx];
      a[min_idx] = a[i];
      a[i] = temp;
    }
  }
}

// DATA

// Linked list
typedef struct node {
  int data;
  struct node *next;
} node_t;

void push(node_t **head, int new_data) {
  node_t *new_node = (node_t *)malloc(sizeof(node_t));

  new_node->data = new_data;
  new_node->next = (*head);

  (*head) = new_node;
}

void l_free(node_t **head) {
  node_t *current = *head;
  node_t *next = NULL;

  while (current != NULL) {
    next = current->next;
    free(current);
    current = next;
  }

  *head = NULL;
}

// 3 -> 2 -> 1 -> NULL
void p_list(node_t *node) {
  while (node != NULL) {
    printf("%d -> ", node->data);
    node = node->next;
  }
  printf("NULL\n");
}

// Stack
typedef struct {
  node_t *top;
} mstack_t;

typedef enum { S_EMPTY = -1 } S_STATUS;

void s_push(mstack_t *stack, int data) {
  node_t *new_node = (node_t *)malloc(sizeof(node_t));

  if (new_node == NULL) {
    printf("Memfail for new node\n");
    return;
  }

  new_node->data = data;
  new_node->next = stack->top;
  stack->top = new_node;
}

int s_pop(mstack_t *stack) {
  if (stack->top == NULL) {
    printf("Empty stack!\n");
    return S_EMPTY;
  }

  node_t *temp = stack->top;
  int popped = temp->data;
  stack->top = stack->top->next;

  free(temp);
  return popped;
}

int s_peek(mstack_t *stack) {

  if (stack->top == NULL) {
    printf("Empty stack!\n");
    return S_EMPTY;
  }

  return stack->top->data;
}

void c_clean(mstack_t *stack) {
  node_t *current = stack->top;
  node_t *next;

  while (current != NULL) {
    next = current->next;
    free(current);
    current = next;
  }

  stack->top = NULL;
}
