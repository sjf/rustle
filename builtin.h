#ifndef BUILTIN_H_
#define BUILTIN_H_
#include <runtime.h>

void add_builtins_to_env(environ *env);

object *print(object *obj);
object *display(object *obj);
object *print(object *obj);
object* add(object* a, object* b);
object *sunday();

object *cons(object *a, object *b);

object *symbolp(object *a);
object *charp(object *a); 
object *vectorp(object *a);
object *pairp(object *a); 
object *procedurep(object *a);
object *booleanp(object *a); 
object *numberp(object *a);

#endif
