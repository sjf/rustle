#include <string.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
//#define __USE_GNU
#include <search.h>
#include <errno.h>

#include <runtime.h>
#include <builtin.h>
#include <base.h>

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

object *new_proc_object(char* scm_name, void *func, int arity, int has_optional, environ* env){
  object *res = new_object(T_PROC);
  res->val.proc.scm_name = strdup(scm_name);
  res->val.proc.func = func;
  res->val.proc.arity = arity;
  res->val.proc.has_optional = has_optional;
  res->val.proc.closure = env;
  return res;
}

void obj_set_str_val(object *obj, const char *str) {
  size_t size = (strlen(str) + 1) * sizeof(char);
  free(obj->val.str);
  obj->val.str = malloc(size);
  memcpy(obj->val.str, str, size);
}

void obj_set_pair_val(object *obj, object *a, object *b) {
  obj->val.pair.car = a;
  obj->val.pair.cdr = b;
}

void obj_set_sym_val(object *obj, const char *sym) {
  size_t size = (strlen(sym) + 1) * sizeof(char);
  free(obj->val.sym);
  obj->val.sym = malloc(size);
  memcpy(obj->val.sym, sym, size);
}

object *new_static_object(char type, void *value){
  object *res = malloc(sizeof(object));;
  bzero(res, sizeof(object));
  res->type = type;
  switch (type) {
  case T_INT:
    res->val.int_ = *((int *)value);
    break;
  case T_STRING:
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
  res->val.proc.arity = arity;
  res->val.proc.builtin = 1;
  res->val.proc.func = func;
  return res;
}

const char* obj_type_name(object *a) {
  return TYPE_NAME[(int)a->type];
}

void init_env(environ *env) {
  bzero(env, sizeof(environ));
  if (hcreate_r(1024, &(env->table)) == 0){
    FatalError("Error setting up hashtable");
  }
}

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

//note args cannot be zero
//#define FP(args...) object*(*)(environ*, args)

object *call_builtin(object *obj, int arglen, ...) {
  object *args[arglen];
  va_list ap;
  va_start(ap, arglen);
  for (int i = 0; i < arglen; i++) {
    args[i] = va_arg(ap, object *);
  }
  va_end(ap);
  return call_builtin1(obj, args, arglen);
}

object *call_builtin1(object *obj, object **args, int arglen) {
  int arity = obj->val.proc.arity;
  if (arglen != arity) {
    // TODO support optional arguments for builtins
    FatalError("Prodecure expected %d arguments, recieved %d", arity, arglen);
  }

  switch (arity) {
  case 0:
    return ((FPC1)obj->val.proc.func)();
  case 1:
    return ((FPC(ARG))obj->val.proc.func)(args[0]);
  case 2:
    return ((FPC(ARG,ARG))obj->val.proc.func)(args[0],args[1]);
  case 3:
    return ((FPC(ARG,ARG,ARG))obj->val.proc.func)(args[0],args[1],args[2]);
  case 4:
    return ((FPC(ARG,ARG,ARG,ARG))obj->val.proc.func)(args[0],args[1],args[2],args[3]);
  default:
    FatalError("Error calling builtin function with unsupported arity: %d",obj->val.proc.arity);
    return &none_object; // Avoid gcc error
  }
}

object *call_proc(object *theproc, environ *env, 
                  object **args, int arglen) {
  CHECK_TYPE_PROC(theproc);
  if (theproc->val.proc.builtin) {
    return call_builtin1(theproc, args, arglen);
  } else {
    // Restore the environment that was available where the
    // function was defined.
    // Create new namespace for this invocation of the function.
    environ *new_env = new_environment(theproc->val.proc.closure);
    // Check function arity matches call
    check_arity(theproc, arglen);
    // Call function
    return ((FP) theproc->val.proc.func)(new_env, args, arglen);
  }
}

void check_arity(const object *obj, int arg_len) {
  proc p = obj->val.proc;
  if ((!p.has_optional && p.arity != arg_len) ||
      ( p.has_optional && p.arity > arg_len)) {
    // todo return false instead of failing here
    FatalError("Calling function of arity %d with %d arguments",
               p.arity, arg_len);
  }
}

environ* setup_main_environment() {
  none_object.type  = T_NONE;
  true_object.type  = T_TRUE;
  false_object.type = T_FALSE;
  null_object.type  = T_NULL;

  init_env(&builtins);
  add_builtins_to_env(&builtins);

  return new_environment(&builtins);
}
