(print "Rustle test suite")

(define cur-section '())(define errs '())
(define SECTION (lambda args
		  (display "SECTION") (print args)
		  (set! cur-section args) #t))
(define record-error (lambda (e) (set! errs (cons (list cur-section e) errs))))

(define test
  (lambda (expect fun . args)
    (display (cons fun args))
    (display "  --> ")
    ((lambda (res)
      (print res)
      (if (not (equal? expect res))
	  ((lambda () 
             (record-error (list res expect (cons fun args)))
             (display " BUT EXPECTED ")
	     (print expect)
	     #f))
          #t))
     (if (procedure? fun) (apply fun args) (car args)))))
(define report-errs 
  (lambda () 
    (display "")
    (if (null? errs) (display "Passed all tests")
        ((lambda ()
          (print "errors were:")
          (print "(SECTION (got expected (call)))")
          (map print errs))))
    (display "")))

