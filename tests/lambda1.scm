(define f (lambda () (print "ok")))
(f) 
;> ok
(define g (lambda (x) (print "lets go")))
(g 1)
;>lets go
(define x 42)
(define h (lambda () (print "the meaning is ") 
                     (print x)
                     (set! x 56)
                     (print x)))
(h)
;>the meaning is 
;>42
;>56
(print "after h")
(print x)
;>after h
;>56
