(define var 42)
(define g (lambda (x) (print x) (set! x 111)))
(g var)
;>42
(print var)
;>42
