(define var 42)
(define g (lambda (x) (display x) (set! x 111)))
(g var)
;>42
(display var)
;>42
