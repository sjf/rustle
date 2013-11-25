TARGET=main
SCM_SRCS=string.scm util.scm c_code.scm 

OBJS = $(patsubst %.scm,%.o,$(SCM_SRCS))

%.o : %.scm
	csc -embedded $<

all: ${TARGET}

${TARGET}: $(OBJS) main.scm
	csc -o $@ $(OBJS) main.scm

.PHONY: clean
clean :
	-rm -f *.so *.o main
