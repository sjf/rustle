#include <stdlib.h>
#include <stdio.h>

#include <base.h>
#include <runtime.h>
#include <builtin.h>

/** 
 * Type Predicates
 **/

object *type_eq(object *a, char type) {
  if (a->type == type) {
      return &true_object;
  }
  return &false_object;
}

int true(object *a) {
  return a->type == T_TRUE;
}

object *__symbolp(object *a) { return type_eq(a, T_SYMBOL); }
object *__charp(object *a) { return type_eq(a, T_CHAR); }
object *__vectorp(object *a) { return type_eq(a, T_VECTOR); }
object *__pairp(object *a) { return type_eq(a, T_PAIR); }
object *__procedurep(object *a) { return type_eq(a, T_PROC); }
object *__nullp(object *a) { return type_eq(a, T_NULL); }

object *__booleanp(object *a) {
  if (a->type == T_TRUE || 
      a->type == T_FALSE) {
    return &true_object;
  }
  return &false_object;
}

object *__numberp(object *a) { 
  if (a->type == T_INT ||
      a->type == T_REAL) {
    return &true_object;
  }
  return &false_object;
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

object *__cons(object *a, object *b) {
  object *res = new_object(T_PAIR);
  res->val.pair.car = a;
  res->val.pair.cdr = b;
  return res;
}

/**
 * Setting up the global environment 
 **/

#define ADD(scm_name,func,arity) add_to_environment(env,#scm_name,new_builtin_proc(&func,arity))
void add_builtins_to_env(environ *env) {
  ADD(display,    __display,1);

  ADD(cons,       __cons,2);

  ADD(symbol?,    __symbolp,1);
  ADD(char?,      __charp, 1);
  ADD(vector?,    __vectorp, 1);
  ADD(pair?,      __pairp,1);
  ADD(procedure?, __procedurep, 1);
  ADD(boolean?,   __booleanp, 1);
  ADD(number?,    __numberp, 1);
  ADD(null?,      __nullp, 1);

  // Some test builtins
  ADD(print,   print,1);
  object *test = new_object(T_INT);
  test->val.int_ = 666;
  add_to_environment(&builtins, "evil", test);
  ADD(sunday,  sunday, 0);
}
