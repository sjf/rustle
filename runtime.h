#ifndef RUNTIME_H_
#define RUNTIME_H_

#include <search.h>

#define T_NONE    0
#define T_INT     1
#define T_STRING  2
#define T_CHAR    3
#define T_TRUE    4
#define T_FALSE   5
#define T_SYMBOL  6
#define T_PAIR    7
#define T_PROC    8
#define T_NULL    9
#define T_REAL   10
#define T_VECTOR 11

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

struct object_ {
  char type;
  union value {
    int int_;
    char *str;
    char *sym;
    char chr;
    proc proc;
    pair pair;
    // others list, vector, char, t/f
  } val;
};

// Singleton objects
environ builtins;
object none_object; 
object true_object;
object false_object;
object null_object;

object *new_object(char type);
object *new_object_from(object *obj);
object *new_proc_object(void *func, int arity, environ* env);
object *new_builtin_proc(void *func, int arity);
object *new_static_object(char type, void *value);

void obj_set_str_val(object *obj, const char *str);
void obj_set_sym_val(object *obj, const char *sym);
void obj_set_pair_val(object *obj, object *a, object *b);

void copy_object(object *dest, object *src);

environ* setup_main_environment();
environ* new_environment(environ* parent);
void add_to_environment(environ *env, char *sym, object *obj);
object *lookup_sym(environ* env, char *sym);

object *call_procedure(object *obj, int arglen, ...);

#endif
