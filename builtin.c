#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <base.h>
#include <runtime.h>
#include <builtin.h>

object *boolean(int bool) {
  return bool ? &true_object : &false_object;
}

object *type_eq(object *a, char type) {
  return boolean(a->type == type);
}

int true(object *a) {
  return a->type == T_TRUE;
}
#define CHECK_TYPE(obj, thetype) do { if (obj->type != thetype) { \
  FatalError("%s: Expected type %s, got %s",                        \
             __func__, TYPE_NAME[thetype], obj_type_name(obj));}} while(0)

#define TYPE_CHECK_NUM2(a,b) do { if (!is_number(a) || !is_number(b)){ \
  FatalError("%s unsupported for type %s and %s",                  \
                 __func__,obj_type_name(a), obj_type_name(b));}} while(0)

#define int_args(a,b) (is_int(a) && is_int(b))

/**
 * Type Predicates
 **/
object *__symbolp(object *a) { return type_eq(a, T_SYMBOL); }
object *__charp(object *a) { return type_eq(a, T_CHAR); }
object *__vectorp(object *a) { return type_eq(a, T_VECTOR); }
object *__pairp(object *a) { return type_eq(a, T_PAIR); }
object *__procedurep(object *a) { return type_eq(a, T_PROC); }
object *__nullp(object *a) { return type_eq(a, T_NULL); }

object *__booleanp(object *a) {
  return boolean(a->type == T_TRUE ||
                 a->type == T_FALSE);
}

object *__numberp(object *a) {
  return boolean(a->type == T_INT ||
                 a->type == T_REAL);
}

object *__atomp(object *a) {
  switch (a->type) {
  case T_NONE:
  case T_TRUE:
  case T_FALSE:
  case T_NULL:
  case T_SYMBOL:
  case T_CHAR:
  case T_STRING:
  case T_INT:
  case T_REAL:
    return &true_object;
  }
  return &false_object;
}

object *__stringtosymbol(object *a) {
  CHECK_TYPE(a, T_STRING);
  object *result = new_object(T_SYMBOL);
  obj_set_sym_val(result, a->val.str);
  return result;
}

/**
 * Display various kinds of objects
 **/

object *__display(object *obj) {
  switch (obj->type) {
  case T_NONE:
    printf("#No-value");
    break;
  case T_INT:
    printf("%i", obj->val.int_);
    break;
  case T_STRING:
    printf("%s", obj->val.str);
    break;
  case T_SYMBOL:
    printf("%s", obj->val.sym);
    break;
  case T_CHAR:
    // TODO Change this back and implement (write)
    printf("#\%c", obj->val.chr);
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
  case T_NULL:
    printf("()");
    break;
  case T_PAIR:
    {
    object *head = obj;
    printf("(");
    while (true(__pairp(head->val.pair.cdr))) {
      // list
      __display(head->val.pair.car);
      printf(" ");
      head = head->val.pair.cdr;
    }
    if (true(__nullp(head->val.pair.cdr))) {
      // empty list
      __display(head->val.pair.car);
    } else {
      // cons cell
      __display(head->val.pair.car);
      printf(" . ");
      __display(head->val.pair.cdr);
    }
    printf(")");
    break;
    }
  default:
    FatalError("display: Unsupported type: %i", obj->type);
  }
  return &none_object;
}

object *print(object *obj) {
  __display(obj);
  printf("\n");
  return &none_object;
}

/**
 * Numeric Functions
 **/

int is_number(object *a) {
  return true(__numberp(a));
}
int is_int(object *a) {
  return a->type == T_INT;
}
double number_value(object *a) {
  if (a->type == T_INT) {
    return a->val.int_;
  } else if (a->type == T_REAL) {
    return a->val.real;
  }
  FatalError("Unsupported numerical type: %s", obj_type_name(a));
  return 0; // avoid gcc error
}

object* __add(object* a, object* b){
  TYPE_CHECK_NUM2(a,b);
  if (int_args(a,b)){
    object *res = new_object(T_INT);
    res->val.int_ = a->val.int_ + b->val.int_;
    return res;
  }
  object *res = new_object(T_REAL);
  res->val.real = number_value(a) + number_value(b);;
  return res;
}

object* __sub(object* a, object* b){
  TYPE_CHECK_NUM2(a,b);
  if (int_args(a,b)) {
    object *res = new_object(T_INT);
    res->val.int_ = a->val.int_ - b->val.int_;
    return res;
  }
  object *res = new_object(T_REAL);
  res->val.real = number_value(a) - number_value(b);;
  return res;
}

object* __mul(object *a, object *b){
  TYPE_CHECK_NUM2(a,b);
  if (int_args(a,b)) {
    object *res = new_object(T_INT);
    res->val.int_ = a->val.int_ * b->val.int_;
    return res;
  }
  object *res = new_object(T_REAL);
  res->val.real = number_value(a) * number_value(b);;
  return res;
}

object *__gt(object *a, object *b) {
  TYPE_CHECK_NUM2(a,b);
  return boolean(number_value(a) > number_value(b));
}

object *__lt(object *a, object *b) {
  TYPE_CHECK_NUM2(a,b);
  return boolean(number_value(a) < number_value(b));
}

object *__ge(object *a, object *b) {
  TYPE_CHECK_NUM2(a,b);
  return boolean(number_value(a) >= number_value(b));
}

object *__le(object *a, object *b) {
  TYPE_CHECK_NUM2(a,b);
  return boolean(number_value(a) <= number_value(b));
}

object *__eq(object *a, object *b) {
  TYPE_CHECK_NUM2(a,b);
  return boolean(number_value(a) == number_value(a));
}

/**
 * List functions
 **/

object *__cons(object *a, object *b) {
  object *res = new_object(T_PAIR);
  res->val.pair.car = a;
  res->val.pair.cdr = b;
  return res;
}

object *__car(object *a) {
  CHECK_TYPE(a, T_PAIR);
  return a->val.pair.car;
}

object *__cdr(object *a) {
  CHECK_TYPE(a, T_PAIR);
  return a->val.pair.cdr;
}

object *__length(object *a) {
  int len = 0;
  while (a != &null_object) {
    if (!true(__pairp(a))) {
      FatalError("Cannot get length of non pair.");
    }
    len++;
    a = __cdr(a);
  }
  object *result = new_object(T_INT);
  result->val.int_ = len;
  return result;
}

/**
 * R4RS Section 6.9 Control Features
 **/

object *__apply(object *theproc, object *args) {
  int arglen = number_value(__length(args));  
  object **arglist = NULL;
  if (arglen) {
    arglist = mallocz(sizeof(object *) * arglen);
    int i = 0;
    while (args != &null_object) {
      arglist[i++] = __car(args);
      args = __cdr(args);
    }
  }
  // TODO env arg should be removed from call proc, the env
  // is restored from the proc's closure.
  object *result = call_proc(theproc, NULL, arglist, arglen);
  free(arglist);
  return result;
}

object *__not(object *a) {
  if (a->type == T_FALSE) {
    return &true_object;
  }
  return &false_object;
}

/**
 * R4RS 6.2 Equivalence predicates
 **/
// TODO all these needed to be tested properly

object *__eqvp(object *a, object *b) {
  if (a->type != b->type) {
    // Objects must have same type
    return &false_object;
  }
  switch (a->type) {
  case T_TRUE:
  case T_FALSE:
  case T_NULL:
  case T_NONE:
    // In these cases equal type means objects are equal
    return &true_object;
  case T_INT:
    return boolean(a->val.int_ == b->val.int_);
  case T_CHAR:
    return boolean(a->val.chr == b->val.chr);
  case T_REAL:
    return boolean(a->val.real == b->val.real);
  case T_STRING:
    return boolean(a->val.str == b->val.str);
  case T_SYMBOL:
    return boolean(strcmp(a->val.sym, b->val.sym) == 0);
  case T_PAIR:
    return boolean(a->val.pair.car == b->val.pair.car &&
                   a->val.pair.cdr == b->val.pair.cdr);
  case T_PROC:
    return boolean(a->val.proc.func == b->val.proc.func);
  case T_VECTOR:
  default:
    FatalError("Unimplemented for type: %s", obj_type_name(a));
  }
  return &none_object; // avoid gcc error
}

object *__equalp(object *a, object *b) {
  if (a->type != b->type) {
    // Objects must have same type 
    return &false_object;
  }
  switch (a->type) {
  case T_TRUE:
  case T_FALSE:
  case T_NULL:
  case T_NONE:
  case T_SYMBOL:
  case T_INT:
  case T_CHAR:
  case T_REAL:
  case T_PROC:
    return __eqvp(a, b);
  case T_STRING:
    return boolean(strcmp(a->val.str, b->val.str) == 0);
  case T_PAIR:
    if (true(__equalp(__car(a), __car(b))) &&
        true(__equalp(__cdr(a), __cdr(b)))) {
      return &true_object;
    }
    return &false_object;
  case T_VECTOR:
  default:
    FatalError("Unimplemented for type: %s", obj_type_name(a));  
  }
  return &none_object; // avoid gcc error
}

/**
 * Setting up the global environment
 **/

#define ADD(scm_name,func,arity) add_to_environment(env,#scm_name,new_builtin_proc(&func,arity))
void add_builtins_to_env(environ *env) {
  ADD(symbol?,    __symbolp, 1);
  ADD(char?,      __charp, 1);
  ADD(vector?,    __vectorp, 1);
  ADD(pair?,      __pairp, 1);
  ADD(procedure?, __procedurep, 1);
  ADD(boolean?,   __booleanp, 1);
  ADD(number?,    __numberp, 1);
  ADD(null?,      __nullp, 1);
  ADD(atom?,      __atomp, 1);

  ADD(string->symbol, __stringtosymbol, 1);

  ADD(apply,      __apply, 2);
  
  ADD(not,        __not, 1);
  ADD(eqv?,       __eqvp, 2);
  ADD(equal?,     __equalp, 2);

  ADD(display,    __display, 1);

  ADD(cons,       __cons, 2);
  ADD(car,        __car, 1);
  ADD(cdr,        __cdr, 2);
  
  ADD(+, __add, 2);
  ADD(-, __sub, 2);
  ADD(*, __mul, 2);

  ADD(>,  __gt, 2);
  ADD(<,  __lt, 2);
  ADD(>=, __ge, 2);
  ADD(<=, __le, 2);
  ADD(=,  __eq, 2);

  // Some test builtins
  ADD(print, print, 1);
}
