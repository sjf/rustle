#define _GNU_SOURCE

#include <string.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
//#define __USE_GNU
#include <search.h>
#include <errno.h>
#include <builtin.h>

#define T_NONE  0
#define T_INT   1
#define T_STR   2
#define T_CHR   3
#define T_TRUE  4
#define T_FALSE 5
#define T_SYM   6
#define T_LIST  7
#define T_PROC  8

#define LOG(x) printf("%s: %d\n",#x,x);

// others list, vector, char, t/f, symbol

typedef struct proc_ {
  void *function;
  int arity;
} proc;

typedef struct object_ {
  char type;
  union value {
    int int_;
    char *str;
    char chr;
    proc proc;
  } val;
} object;

object none_object; 
object true_object;
object false_object;

struct environ_ {
  struct hsearch_data table;
  struct environ_ *parent;
};
typedef struct environ_ environ;

environ builtins;

object *new_object(char type) {
  object *res = malloc(sizeof(object));
  bzero(res,sizeof(object));
  res->type = type;  
  return res;
}

object *new_static_object(char type, void *value){
  object *res = malloc(sizeof(object));;
  bzero(res,sizeof(object));
  res->type = type;
  switch (type) {
  case T_INT:
    res->val.int_ = *((int *)value);
    break;
  case T_STR:
    res->val.str = value;
    break;
  case T_PROC:
    //res->val.proc = *((proc *)value);
    break;
  default:
    FatalError("Unsupported type: %d", type);
  }
  return res;
}

object *new_static_proc(void *func, int arity){
  object *res = new_static_object(T_PROC, NULL);
  res->val.proc.function = func;
  res->val.proc.arity = arity;
  return res;
}

void obj_set_str_val(object *obj, const char *str) {
  size_t size = strlen(str) * sizeof(char);
  obj->val.str = malloc(size);
  memcpy(obj->val.str, str, size);
}


void copy_obj(object *dest, object *src) {
  memcpy(dest, src, sizeof(object));
}

void init_env(environ *env) {
  bzero(env, sizeof(environ));
  if (hcreate_r(1024, &(env->table)) == 0){
    FatalError("Error setting up hashtable");
  }
}

////////

object *display(object *obj) {
  switch (obj->type) {
  case T_NONE:
    printf("#No-value\n");
    break;
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
  case T_PROC:
    printf("#Procedure-(%d arguments)\n", obj->val.proc.arity);
    break;
  default:
    FatalError("Unsupported type: %i", obj->type);
  }
  return &none_object;
}

object* add(object* a, object* b){ 
  //return a+b;
  Todo("Add");
  return NULL;
}

int sub(int a, int b){ return a-b; }
int mul(int a, int b){ return a*b; }
int divv(int a, int b){ return a/b; }

object *sunday() {
  printf("Jarvis Cocker's Sunday Service\n");
  return &none_object;
}

////////

void new_environment(environ* env, environ* parent) {
  init_env(env);
  env->parent = parent;
}

void add_to_environment(environ *env, char *sym, object *obj) {
  //printf("** Inserting %s\n",sym);
  ENTRY item;
  item.key = sym;
  item.data = obj;
  ENTRY *result = NULL;
  int res = hsearch_r(item, ENTER, &result, &(env->table));
  if (res == 0) {
    FatalError("Hashtable is full");
  }
  if (result != NULL) {
    result->data = obj;
  } else {
    FatalError("Unexpected error looking up hashtable");
  }
}

object *lookup_sym(environ* env, char *sym) {
  ENTRY item;
  item.key = sym;
  ENTRY *result;

  int res = hsearch_r(item, FIND, &result, &(env->table));
  if (res == 0 || result == NULL) {
    if (env->parent == NULL) {
      FatalError("Undefined var: %s", sym);
    }
    return lookup_sym(env->parent, sym);
  }
  return (object *)result->data;
}

object *call_procedure(object *obj, int arglen, ...) {
  if (obj->type != T_PROC) {
    FatalError("Cannot call object of type: %d", obj->type);
  }
  int arity = obj->val.proc.arity;
  if (arglen != arity) {
    FatalError("Prodecure expected %d arguments, recieved %d", arity, arglen);
  }

  object *args[arglen];
  va_list ap;
  va_start(ap, arglen);
  for (int i = 0; i < arglen; i++) {
    args[i] = va_arg(ap, object *);
  }
  va_end(ap);

  switch (arity) {
  case 0:
    return ((object*(*)())obj->val.proc.function)();
    break;
  case 1:
    return ((object*(*)(object *))obj->val.proc.function)(args[0]);
    break;
  case 2:
    //break;
  case 3:
    //break;
  case 4:
    //break;
  default:
    FatalError("Unsupported arity: %d",obj->val.proc.arity);
  }
  return &none_object;
}

void setup_main_environment(environ* env) {
  none_object.type = T_NONE;
  true_object.type = T_TRUE;
  false_object.type = T_FALSE;

  init_env(&builtins);

  add_to_environment(&builtins, "display", new_static_proc(&display, 1));

  // Some test builtins
  object *test = new_object(T_INT);
  test->val.int_ = 666;
  add_to_environment(&builtins, "evil", test);

  object *test2 = new_object(T_PROC);
  test2->val.proc.function = &sunday;
  test2->val.proc.arity = 0;
  add_to_environment(&builtins, "sunday", test2);

  new_environment(env, &builtins);
  
}
