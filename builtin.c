#include <stdlib.h>
#include <stdio.h>

#include <base.h>
#include <runtime.h>
#include <builtin.h>

object *type_eq(object *a, char type);

object *display(object *obj) {
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

object *symbolp(object *a) { return type_eq(a, T_SYMBOL);}
object *charp(object *a) { return type_eq(a, T_CHAR);}
object *vectorp(object *a) { return type_eq(a, T_VECTOR);}
object *pairp(object *a) { return type_eq(a, T_PAIR);}
object *procedurep(object *a) { return type_eq(a, T_PROC);}

object *booleanp(object *a) {
  if (a->type == T_TRUE || 
      a->type == T_FALSE) {
    return &true_object;
  }
  return &false_object;
}

object *numberp(object *a) { 
  if (a->type == T_INT ||
      a->type == T_REAL) {
    return &true_object;
  }
  return &false_object;
}

object *type_eq(object *a, char type) {
  if (a->type == type) {
      return &true_object;
  }
  return &false_object;
}

#define ADD(scm_name,func,arity) add_to_environment(env,#scm_name,new_builtin_proc(&func,arity))
void add_builtins_to_env(environ *env) {
  ADD(display, display,1);
  ADD(print,   print,1);

  ADD(cons,    cons,2);

  ADD(symbol?, symbolp,1);
  ADD(char?,   charp, 1);
  ADD(vector?, vectorp, 1);
  ADD(pair?,   pairp,1);
  ADD(procedure?, procedurep, 1);
  ADD(boolean?,   booleanp, 1);
  ADD(number?, numberp, 1);

  // Some test builtins
  object *test = new_object(T_INT);
  test->val.int_ = 666;
  add_to_environment(&builtins, "evil", test);
  ADD(sunday,  sunday, 0);
}
