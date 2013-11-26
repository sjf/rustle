/** 
 C implementations of primitive scheme functions 
**/

#ifndef BUILTIN_H_
#define BUILTIN_H_
#include <runtime.h>

void add_builtins_to_env(environ *env);

object *print(object *obj);
object *__display(object *obj);
object *print(object *obj);
object *add(object *a, object *b);
object *sunday();

object *__cons(object *a, object *b);

object *__symbolp(object *a);
object *__charp(object *a); 
object *__vectorp(object *a);
object *__pairp(object *a); 
object *__procedurep(object *a);
object *__booleanp(object *a); 
object *__numberp(object *a);

#endif
