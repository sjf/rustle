(define msg "hello")
(print msg)
;>hello
(print " ")
;> 
(set! msg "world")
(print msg)
;> world
(print (print "foo!"))
;>foo!
;>#No-value
(print evil)
;>666
(print sunday)
;>#Procedure-(0 arguments)
(sunday)
;>Jarvis Cocker's Sunday Service
