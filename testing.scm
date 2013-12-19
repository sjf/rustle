(print "Rustle test suite")

;(define cur-section '())(define errs '())
;(define SECTION (lambda args
;		  (display "SECTION") (print args)
;		  (set! cur-section args) #t))
;(define record-error (lambda (e) (set! errs (cons (list cur-section e) errs))))

(define test
  (lambda (expect result)
    (if (not (equal? expect result))
        ((lambda () 
           (display "ERR ") (display expect) (display "  -->  ") (print result)
           #f))
        ((lambda ()
           (display "    ") (display expect) (display "  -->  ") (print result) 
           #t)))))
;(define report-errs 
;  (lambda () 
;    (display "")
;    (if (null? errs) (display "Passed all tests")
;        ((lambda ()
;          (print "errors were:")
;          (print "(SECTION (got expected (call)))")
;          (map print errs))))
;    (display "")))

