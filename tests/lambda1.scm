(define f (lambda () (display "ok")))
(f) 
;> ok
(define g (lambda (x) (display "lets go")))
(g 1)
;>lets go
(define x 42)
(define h (lambda () (display "the meaning is ") 
                     (display x)
                     (set! x 56)
                     (display x)))
(h)
;>the meaning is 
;>42
;>56
(display "after h")
(display x)
;>after h
;>56
