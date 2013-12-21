(define not (lambda (x) (if x #f #t)))
(define eq? eqv?)

(define zero? (lambda (x) (if (eq? 0 x) #t #f)))
(define positive? (lambda (x) (if (< 0 x) #t #f)))
(define negative? (lambda (x) (if (> 0 x) #t #f)))
(define abs (lambda (x) (if (positive? x) x (- 0 x))))
