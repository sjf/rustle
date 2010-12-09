#define _GNU_SOURCE

#include <string.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
//#define __USE_GNU
#include <search.h>
#include <errno.h>
#include <runtime.h>

#define T_NONE  0
#define T_INT   1
#define T_STR   2
#define T_CHR   3
#define T_TRUE  4
#define T_FALSE 5
#define T_SYM   6
#define T_PAIR  7
#define T_PROC  8
#define T_EMPTYLIST 9

#define LOG(x) printf("%s: %d\n",#x,x);
struct object_;
typedef struct object_ object;

typedef struct environ_ {
  struct hsearch_data table;
  struct environ_ *parent;
} environ;

typedef struct pair_ {
  object *car;
  struct object_ *cdr;
} pair;

typedef struct proc_ {
  void *func;
  int arity;
  environ* closure;
  char builtin;
} proc;


/*typedef*/ struct object_ {
  char type;
  union value {
    int int_;
    char *str;
    char chr;
    proc proc;
    pair pair;
    // others list, vector, char, t/f, symbol
  } val;
} /*object*/;

environ builtins;
object none_object; 
object true_object;
object false_object;


object *new_object(char type) {
  object *res = malloc(sizeof(object));
  bzero(res,sizeof(object));
  res->type = type;  
  return res;
}

void copy_object(object *dest, object *src) {
  memcpy(dest, src, sizeof(object));
}

object *new_object_from(object *obj){
  object *res = malloc(sizeof(object));
  copy_object(res,obj);
  return res;
}

object *new_proc_object(void *func, int arity, environ* env){
  object *res = new_object(T_PROC);
  res->val.proc.func = func;
  res->val.proc.arity = arity;
  res->val.proc.closure = env;
  return res;
}

void obj_set_str_val(object *obj, const char *str) {
  size_t size = strlen(str) * sizeof(char);
  obj->val.str = malloc(size);
  memcpy(obj->val.str, str, size);
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

object *new_builtin_proc(void *func, int arity) {
  object *res = new_static_object(T_PROC, NULL);
  res->type = T_PROC;
  res->val.proc.arity = arity;
  res->val.proc.builtin = 1;
  res->val.proc.func = func;
  return res;
}

void init_env(environ *env) {
  bzero(env, sizeof(environ));
  if (hcreate_r(1024, &(env->table)) == 0){
    FatalError("Error setting up hashtable");
  }
}

////////
object *print(object *obj);


object *display(object *obj) {
  switch (obj->type) {
  case T_NONE:
    printf("#No-value");
    break;
  case T_INT:
    printf("%i", obj->val.int_);
    break;
  case T_STR:
    printf("%s", obj->val.str);
    break;
  case T_CHR:
    printf("%c", obj->val.chr);
    break;
  case T_TRUE:
    printf("#t");
    break;
  case T_FALSE:
    printf("#f");
    break;
  case T_PROC:
    printf("#Procedure-(%d arguments)", obj->val.proc.arity);
    break;
  case T_PAIR:
    printf("(");
    display(obj->val.pair.car);
    printf(" . ");
    display(obj->val.pair.cdr);
    printf(")");
    break;
  default:
    FatalError("Unsupported type: %i", obj->type);
  }
  return &none_object;
}

object *print(object *obj) {
  display(obj);
  printf("\n");
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

object *cons(object *a, object *b) {
  object *res = new_object(T_PAIR);
  res->val.pair.car = a;
  res->val.pair.cdr = b;
  return res;
}

object *pairp(object *a) {
  if (a->type == T_PAIR) {
    return &true_object;
  }
  return &false_object;
}

////////

environ* new_environment(environ* parent) {
  environ *env = malloc(sizeof(environ));
  init_env(env);
  env->parent = parent;
  return env;
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

#define ARG object*
#define FPC1 object*(*)()
//note args cannot be zero
#define FPC(args...) object*(*)(args)


#define FP1 object *(*)(environ*)
//note args cannot be zero
#define FP(args...) object*(*)(environ*, args)

object *call_procedure(object *obj, int arglen, ...) {
  if (obj->type != T_PROC) {
    FatalError("Cannot call object of type: %d", obj->type);
  }
  int arity = obj->val.proc.arity;
  environ* env = obj->val.proc.closure;
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

  if (obj->val.proc.builtin) {
    //Info("calling builtin");
    switch (arity) {
    case 0:
      return ((FPC1)obj->val.proc.func)();
      break;
    case 1:
      return ((FPC(ARG))obj->val.proc.func)(args[0]);
      break;
    case 2:
      return ((FPC(ARG,ARG))obj->val.proc.func)(args[0],args[1]);
      break;
    case 3:
      return ((FPC(ARG,ARG,ARG))obj->val.proc.func)(args[0],args[1],args[2]);
      break;
    case 4:
      return ((FPC(ARG,ARG,ARG,ARG))obj->val.proc.func)(args[0],args[1],args[2],args[3]);
      break;
    default:
      FatalError("Error calling builtin function with unsupported arity: %d",obj->val.proc.arity);
    }

  } else {
    //Info("calling define procedure");
    switch (arity) {
    case 0:
      return ((FP1) obj->val.proc.func)(env);
      break;
    case 1:
      return ((FP(ARG))obj->val.proc.func)(env,args[0]);
      break;
    case 2:
      return ((FP(ARG,ARG))obj->val.proc.func)(env,args[0],args[1]);
      break;
    case 3:
      return ((FP(ARG,ARG,ARG))obj->val.proc.func)(env,args[0],args[1],args[2]);
      break;
    case 4:
      return ((FP(ARG,ARG,ARG,ARG))obj->val.proc.func)(env,args[0],args[1],args[2],args[3]);
      break;
    default:
      FatalError("Error calling procedure with unsupported arity: %d",obj->val.proc.arity);
    }
  }
  return &none_object;
}

environ* setup_main_environment() {
  none_object.type = T_NONE;
  true_object.type = T_TRUE;
  false_object.type = T_FALSE;

  init_env(&builtins);

  add_to_environment(&builtins, "display", new_builtin_proc(&display, 1));
  add_to_environment(&builtins, "print", new_builtin_proc(&print, 1));
  add_to_environment(&builtins, "cons", new_builtin_proc(&cons, 2));
  add_to_environment(&builtins, "pair?", new_builtin_proc(&pairp, 1));


  // Some test builtins
  object *test = new_object(T_INT);
  test->val.int_ = 666;
  add_to_environment(&builtins, "evil", test);

  add_to_environment(&builtins, "sunday", new_builtin_proc(&sunday, 0));

  return new_environment(&builtins);
  
}
