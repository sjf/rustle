(define f (lambda (x) (display x)))
(f 999)
;>999
(f 888)
;>888
(define g 
 (lambda (a b c) 
  (display a) 
  (display b) 
  (display c) 
  (set! a 111) 
  (display a)))
(g 1 2 3)
;>1
;>2
;>3
;>111
