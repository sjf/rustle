(define msg "hello")
(display msg)
;>hello
(display " ")
;> 
(set! msg "world")
(display msg)
;> world
(display (display "foo!"))
;>foo!
;>#No-value
(display evil)
;>666
(display sunday)
;>#Procedure-(0 arguments)
(sunday)
;>Jarvis Cocker's Sunday Service
