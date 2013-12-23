#ifndef RUNTIME_H_
#define RUNTIME_H_

#include <search.h>
#include <base.h>

#define T_NONE    0
#define T_TRUE    1
#define T_FALSE   2
#define T_NULL    3

#define T_SYMBOL  4
#define T_CHAR    5
#define T_STRING  6

#define T_INT     7
#define T_REAL    8

#define T_PAIR    9
#define T_PROC   10
#define T_VECTOR 11

static const char *TYPE_NAME[] =
  {"none/unspecified", "true", "false", "null/empty list",
   "symbol", "char", "string",
   "int", "real",
   "pair", "proc", "vector"};

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
  char *scm_name; // scheme name of the function or "lambda" if it was not created with define.
  void *func;
  int arity;
  char has_optional; // function takes optional arguments
  char builtin; // is builtin c function
  environ* closure;
  //char** arg;
} proc; //should be renamed to lambda

struct object_ {
  char type;
  union value {
    int int_;
    double real;
    char *str;
    char *sym;
    char chr;
    proc proc;
    pair pair;
    // TODO others vector, port
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
object *new_proc_object(char* scm_name, void *func, int arity, int has_optional, environ* env);
object *new_builtin_proc(void *func, int arity);
object *new_static_object(char type, void *value);

void obj_set_str_val(object *obj, const char *str);
void obj_set_sym_val(object *obj, const char *sym);
void obj_set_pair_val(object *obj, object *a, object *b);

const char* obj_type_name(object *a);

void copy_object(object *dest, object *src);

environ *setup_main_environment();
environ *new_environment(environ* parent);
void     add_to_environment(environ *env, char *sym, object *obj);
object *lookup_sym(environ* env, char *sym);

object *call_builtin(object *obj, int arglen, ...);
object *call_builtin1(object *obj, object **args, int arglen);
object *call_proc(object *theproc, environ *env, 
                  object **args, int arglen);
// Function pointer
#define FP object *(*)(environ *, object **, int)

void check_arity(const object *obj, int arg_len);

#define CHECK_TYPE_PROC(obj) \
  do { if (obj->type != T_PROC) { \
      FatalError("Cannot call object of type: %s", obj_type_name(obj));}} while(0)

#endif
