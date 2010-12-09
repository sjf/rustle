(define p (cons "a" "b"))
;> (a . b)
(print p)
(print (pair? p))
;> #t
(print (pair? 0))
;> #f
