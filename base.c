#include "base.h"

#include <execinfo.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Obtain a backtrace and print it to stdout. */
void print_trace (void) {
  void *array[10];
  size_t size;
  char **strings;
  size_t i;
  
  size = backtrace (array, 10);
  strings = backtrace_symbols (array, size);
  
  printf ("Obtained %zd stack frames.\n", size);
  
  for (i = 0; i < size; i++)
    printf ("%s\n", strings[i]);
  
  free (strings);
}

void *mallocz(size_t size) {
  void *buf = malloc(size);
  if (buf == NULL) {
    FatalSysError("malloc failed");
  }
  bzero(buf, size);
  return buf;
}
