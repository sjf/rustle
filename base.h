#include <stdlib.h>
#include <signal.h>

#define FatalError(x, args...) do{fprintf(stderr," !! error at %s:%i:%s ", __FILE__,__LINE__,__FUNCTION__); \
                                  fprintf(stderr,x, ##args); fprintf(stderr,"\n"); \
                                  fail(); \
                               } while(0)

#define FatalSysError(x, args...) do{perror(" !! error:"); \
                                  fprintf(stderr," !! error at %s:%i:%s ", __FILE__,__LINE__,__FUNCTION__); \
                                  fprintf(stderr,x, ##args); fprintf(stderr,"\n"); \
                                  fail(); \
                               } while(0)

#define Error(x, args...) do{fprintf(stderr," ## error at %s:%i:%s ", __FILE__,__LINE__,__FUNCTION__); \
                             fprintf(stderr,x, ##args); fprintf(stderr,"\n"); \
                              } while(0)
#define Warn(x, args...) do{printf(" == warning at %s:%i:%s ", __FILE__,__LINE__,__FUNCTION__); \
                             printf(x, ##args); printf("\n"); \
                          } while(0)
#define Info(x, args...) do {printf(" ++ ");printf(x, ## args);printf("\n"); \
                                                  } while (0)
/*
#define InfoFile(x, args...) do {printf(" ++ ");printf(x,##args);printf("\n");\
                                 fprintf(sr->log,"%lu ",time(NULL));fprintf(sr->log,x, ## args);\
                                 fprintf(sr->log,"\n");fflush(sr->log); } while (0)
*/

#define Todo(x, args...) do {printf(" ** Todo at %s: ",__FUNCTION__);printf(x, ## args);printf("\n"); \
                          } while (0)
#define Fine(x, args...) do {printf("    ");printf(x, ## args);printf("\n"); \
                          } while (0)

#ifdef _DEBUG_
#define fail() raise(SIGSEGV)
#else
#define fail() exit(1)
#endif

void *mallocz(size_t size);
