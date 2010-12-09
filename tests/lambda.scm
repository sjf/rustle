(define f (lambda (x) (print x)))
(f 999)
;>999
(f 888)
;>888
(define g 
 (lambda (a b c) 
  (print a) 
  (print b) 
  (print c) 
  (set! a 111) 
  (print a)))
(g 1 2 3)
;>1
;>2
;>3
;>111
