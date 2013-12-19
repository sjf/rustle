CC = gcc
CFLAGS = -g -Werror -Wshadow -std=c99 -Wall -Wno-unused-variable -Wno-error=unused-but-set-variable -D_GNU_SOURCE -D_DEBUG_ -I.

C_SRCS = base.c runtime.c builtin.c
OBJS = $(patsubst %.c,%.o,$(C_SRCS))

SCM = csc
SCM_SRCS = main.scm c_code.scm preprocessor.scm string.scm util.scm
SCM_FLAGS = -scrutinize

all: main

# Build rule for object files
%.o: %.c %.h
	$(CC) -c -o $@ $< $(CFLAGS)

# Runtime library for compiled scm files
runtime.a: $(OBJS)
	ar cvr libruntime.a $^

# Main compiler binary, compiles the C runtime library first.
main: $(SCM_SRCS) runtime.a
	$(SCM) $(SCM_FLAGS) $<

.PHONY: clean
clean :
	-rm -f *.so *.o *.a main *.s *.i
	-find tests/ -not -iname '*.scm' -type f |xargs rm  2>/dev/null
