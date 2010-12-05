#include <string.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>


#define T_INT   0
#define T_STR   1
#define T_CHR   2
#define T_TRUE  3
#define T_FALSE 4
#define T_SYM   5
#define T_LIST  6

// others list, vector, char, t/f, symbol

typedef struct object_ {
  char type;
  union value {
    int int_;
    char * str;
    char chr;
  } val;
} object;

object *new_object(char type) {
  object *res = malloc(sizeof(object));
  bzero(res,sizeof(object));
  res->type = type;  
  return res;
}

void set_str_val(object *obj, const char *str) {
  size_t size = strlen(str) * sizeof(char);
  obj->val.str = malloc(size);
  memcpy(obj->val.str, str, size);
}

int display(object *obj) {
  switch (obj->type) {
  case T_INT:
    printf("%i\n", obj->val.int_);
    break;
  case T_STR:
    printf("%s\n", obj->val.str);
    break;
  case T_CHR:
    printf("%c\n", obj->val.chr);
    break;
  case T_TRUE:
    printf("#t\n");
    break;
  case T_FALSE:
    printf("#f\n");
    break;
  otherwise:
    printf("Unsupported type\n",obj->type);
  }
}

int add(int a, int b){ return a+b; }
int sub(int a, int b){ return a-b; }
int mul(int a, int b){ return a*b; }
int divv(int a, int b){ return a/b; }
