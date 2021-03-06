(require "testing")

;(SECTION 6 5 5)
(test #t (number? 3))
;;(test #t (complex? 3))
;;(test #t (real? 3))
;;(test #t (rational? 3))
;(test #t (integer? 3))

;;(test #t (exact? 3))
;;(test #f (inexact? 3))

;; (test 1 (expt 0 0))
;; (test 0 (expt 0 1))
;; (test 0 (expt 0 256))
;; ;;(test 0 (expt 0 -255)
;; (test 1 expt -1 256)
;; (test -1 expt -1 255)
;; (test 1 expt -1 -256)
;; (test -1 expt -1 -255)
;; (test 1 expt 256 0)
;; (test 1 expt -256 0)
;; (test 256 expt 256 1)
;; (test -256 expt -256 1)
;; (test 8 expt 2 3)
;; (test -8 expt -2 3)
;; (test 9 expt 3 2)
;; (test 9 expt -3 2)

;(test #t (= 22 22 22))
(test #t (= 22 22))
;(test #f (= 34 34 35))
(test #f (= 34 35))
(test #t (> 3 -6246))
;(test #f (> 9 9 -2424))
;(test #t (>= 3 -4 -6246))
(test #t (>= 9 9))
(test #f (>= 8 9))
;(test #t (< -1 2 3 4 5 6 7 8))
;(test #f (< -1 2 3 4 4 5 6 7))
;(test #t (<= -1 2 3 4 5 6 7 8))
;(test #t (<= -1 2 3 4 4 5 6 7))
;(test #f (< 1 3 2))
;(test #f (>= 1 3 2))

(test #t (zero? 0))
(test #f (zero? 1))
(test #f (zero? -1))
(test #f (zero? -100))
(test #t (positive? 4))
(test #f (positive? -4))
(test #f (positive? 0))
(test #f (negative? 4))
(test #t (negative? -4))
(test #f (negative? 0))
;; (test #t odd? 3)
;; (test #f odd? 2)
;; (test #f odd? -4)
;; (test #t odd? -1)
;; (test #f even? 3)
;; (test #t even? 2)
;; (test #t even? -4)
;; (test #f even? -1)

;; (test 38 max 34 5 7 38 6)
;; (test -24 min 3  5 5 330 4 -24)

(test 7 (+ 3 4))
;(test '3 (+ 3))
;(test 0 (+))
;(test 4 (* 4))
;(test 1 (*))
;(test 1 (/ 1))
;(test -1 (/ -1))
;(test 2 (/ 6 3))
;(test -3 (/ 6 -2))
;(test -3 (/ -6 2))
;(test 3 (/ -6 -2))
(test -1 (- 3 4))
;(test -3 (- 3))
(test 7 (abs -7))
(test 7 (abs 7))
(test 0 (abs 0))

;; (test 5 (quotient 35 7))
;; (test -5 (quotient -35 7))
;; (test -5 (quotient 35 -7))
;; (test 5 (quotient -35 -7))
;; (test 1 (modulo 13 4))
;; (test 1 (remainder 13 4))
;; (test 3 (modulo -13 4))
;; (test -1 (remainder -13 4))
;; (test -3 (modulo 13 -4))
;; (test 1 (remainder 13 -4))
;; (test -1 (modulo -13 -4))
;; (test -1 (remainder -13 -4))
;; (test 0 (modulo 0 86400))
;; (test 0 (modulo 0 -86400))
;; (define (divtest n1 n2)
;; 	(= n1 (+ (* n2 (quotient n1 n2))
;; 		 (remainder n1 n2))))
;; (test #t (divtest 238 9))
;; (test #t (divtest -238 9))
;; (test #t (divtest 238 -9))
;; (test #t (divtest -238 -9))

;; (test 4 (gcd 0 4))
;; (test 4 (gcd -4 0))
;; (test 4 (gcd 32 -36))
;; (test 0 (gcd))
;; (test 288 (lcm 32 -36))
;; (test 1 (lcm))

;; (floor -4.3)                           ==>  -5.0
;; (ceiling -4.3)                         ==>  -4.0
;; (truncate -4.3)                        ==>  -4.0
;; (round -4.3)                           ==>  -4.0

;; (floor 3.5)                            ==>  3.0
;; (ceiling 3.5)                          ==>  4.0
;; (truncate 3.5)                         ==>  3.0
;; (round 3.5)                            ==>  4.0  ; inexact

;; (round 7/2)                            ==>  4    ; exact
;; (round 7)                              ==>  7


;;(SECTION 6 5 5)
;;; Implementations which don't allow division by 0 can have fragile
;;; string->number.
;; (define (test-string->number str)
;;   (define ans (string->number str))
;;   (cond ((not ans) #t) ((number? ans) #t) (else ans)))
;; (for-each (lambda (str) (test #t test-string->number str))
;; 	  '("+#.#" "-#.#" "#.#" "1/0" "-1/0" "0/0"
;; 	    "+1/0i" "-1/0i" "0/0i" "0/0-0/0i" "1/0-1/0i" "-1/0+1/0i"
;; 	    "#i" "#e" "#" "#i0/0"))
;; (cond ((number? (string->number "1+1i")) ;More kawa bait
;;        (test #t number? (string->number "#i-i"))
;;        (test #t number? (string->number "#i+i"))
;;        (test #t number? (string->number "#i2+i"))))

;; ;;;;From: fred@sce.carleton.ca (Fred J Kaudel)
;; ;;; Modified by jaffer.
;; (define (test-inexact)
;;   (define f3.9 (string->number "3.9"))
;;   (define f4.0 (string->number "4.0"))
;;   (define f-3.25 (string->number "-3.25"))
;;   (define f.25 (string->number ".25"))
;;   (define f4.5 (string->number "4.5"))
;;   (define f3.5 (string->number "3.5"))
;;   (define f0.0 (string->number "0.0"))
;;   (define f0.8 (string->number "0.8"))
;;   (define f1.0 (string->number "1.0"))
;;   (define f1e300 (and (string->number "1+3i") (string->number "1e300")))
;;   (define f1e-300 (and (string->number "1+3i") (string->number "1e-300")))
;;   (define wto write-test-obj)
;;   (define lto load-test-obj)
;;   (newline)
;;   (display ";testing inexact numbers; ")
;;   (newline)
;;   (SECTION 6 2)
;;   (test #f eqv? 1 f1.0)
;;   (test #f eqv? 0 f0.0)
;;   (test #t eqv? f0.0 f0.0)
;;   (cond ((= f0.0 (- f0.0))
;; 	 (test #t eqv? f0.0 (- f0.0))
;; 	 (test #t equal? f0.0 (- f0.0))))
;;   (cond ((= f0.0 (* -5 f0.0))
;; 	 (test #t eqv? f0.0 (* -5 f0.0))
;; 	 (test #t equal? f0.0 (* -5 f0.0))))
;;   (SECTION 6 5 5)
;;   (and f1e300
;;        (let ((f1e300+1e300i (make-rectangular f1e300 f1e300)))
;; 	 (test f1.0 'magnitude (/ (magnitude f1e300+1e300i)
;; 				  (* f1e300 (sqrt 2))))
;; 	 (test f.25 / f1e300+1e300i (* 4 f1e300+1e300i))))
;;   (and f1e-300
;;        (let ((f1e-300+1e-300i (make-rectangular f1e-300 f1e-300)))
;; 	 (test f1.0 'magnitude (round (/ (magnitude f1e-300+1e-300i)
;; 					 (* f1e-300 (sqrt 2)))))
;; 	 (test f.25 / f1e-300+1e-300i (* 4 f1e-300+1e-300i))))
;;   (test #t = f0.0 f0.0)
;;   (test #t = f0.0 (- f0.0))
;;   (test #t = f0.0 (* -5 f0.0))
;;   (test #t inexact? f3.9)
;;   (test #t 'max (inexact? (max f3.9 4)))
;;   (test f4.0 max f3.9 4)
;;   (test f4.0 exact->inexact 4)
;;   (test f4.0 exact->inexact 4.0)
;;   (test 4 inexact->exact 4)
;;   (test 4 inexact->exact 4.0)
;;   (test (- f4.0) round (- f4.5))
;;   (test (- f4.0) round (- f3.5))
;;   (test (- f4.0) round (- f3.9))
;;   (test f0.0 round f0.0)
;;   (test f0.0 round f.25)
;;   (test f1.0 round f0.8)
;;   (test f4.0 round f3.5)
;;   (test f4.0 round f4.5)

;;   ;;(test f1.0 expt f0.0 f0.0)
;;   ;;(test f1.0 expt f0.0 0)
;;   ;;(test f1.0 expt 0    f0.0)
;;   (test f0.0 expt f0.0 f1.0)
;;   (test f0.0 expt f0.0 1)
;;   (test f0.0 expt 0    f1.0)
;;   (test f1.0 expt -25  f0.0)
;;   (test f1.0 expt f-3.25 f0.0)
;;   (test f1.0 expt f-3.25 0)
;;   ;;(test f0.0 expt f0.0 f-3.25)

;;   (test (atan 1) atan 1 1)
;;   (set! write-test-obj (list f.25 f-3.25)) ;.25 inexact errors less likely.
;;   (set! load-test-obj (list 'define 'foo (list 'quote write-test-obj)))
;;   (test #t call-with-output-file
;; 	"tmp3"
;; 	(lambda (test-file)
;; 	  (write-char #\; test-file)
;; 	  (display #\; test-file)
;; 	  (display ";" test-file)
;; 	  (write write-test-obj test-file)
;; 	  (newline test-file)
;; 	  (write load-test-obj test-file)
;; 	  (output-port? test-file)))
;;   (check-test-file "tmp3")
;;   (set! write-test-obj wto)
;;   (set! load-test-obj lto)
;;   (let ((x (string->number "4195835.0"))
;; 	(y (string->number "3145727.0")))
;;     (test #t 'pentium-fdiv-bug (> f1.0 (- x (* (/ x y) y)))))
;;   (report-errs))

;; (define (test-inexact-printing)
;;   (let ((f0.0 (string->number "0.0"))
;; 	(f0.5 (string->number "0.5"))
;; 	(f1.0 (string->number "1.0"))
;; 	(f2.0 (string->number "2.0")))
;;     (define log2
;;       (let ((l2 (log 2)))
;; 	(lambda (x) (/ (log x) l2))))

;;     (define (slow-frexp x)
;;       (if (zero? x)
;; 	  (list f0.0 0)
;; 	  (let* ((l2 (log2 x))
;; 		 (e (floor (log2 x)))
;; 		 (e (if (= l2 e)
;; 			(inexact->exact e)
;; 			(+ (inexact->exact e) 1)))
;; 		 (f (/ x (expt 2 e))))
;; 	    (list f e))))

;;     (define float-precision
;;       (let ((mantissa-bits
;; 	     (do ((i 0 (+ i 1))
;; 		  (eps f1.0 (* f0.5 eps)))
;; 		 ((= f1.0 (+ f1.0 eps))
;; 		  i)))
;; 	    (minval
;; 	     (do ((x f1.0 (* f0.5 x)))
;; 		 ((zero? (* f0.5 x)) x))))
;; 	(lambda (x)
;; 	  (apply (lambda (f e)
;; 		   (let ((eps
;; 			  (cond ((= f1.0 f) (expt f2.0 (+ 1 (- e mantissa-bits))))
;; 				((zero? f) minval)
;; 				(else (expt f2.0 (- e mantissa-bits))))))
;; 		     (if (zero? eps)	;Happens if gradual underflow.
;; 			 minval
;; 			 eps)))
;; 		 (slow-frexp x)))))

;;     (define (float-print-test x)
;;       (define (testit number)
;; 	(eqv? number (string->number (number->string number))))
;;       (let ((eps (float-precision x))
;; 	    (all-ok? #t))
;; 	(do ((j -100 (+ j 1)))
;; 	    ((or (not all-ok?) (> j 100)) all-ok?)
;; 	  (let* ((xx (+ x (* j eps)))
;; 		 (ok? (testit xx)))
;; 	    (cond ((not ok?)
;; 		   (display "Number readback failure for ")
;; 		   (display `(+ ,x (* ,j ,eps)))
;; 		   (newline)
;; 		   (display xx)
;; 		   (newline)
;; 		   (set! all-ok? #f))
;; 		  ;;   (else (display xx) (newline))
;; 		  )))))

;;     (define (mult-float-print-test x)
;;       (let ((res #t))
;; 	(for-each
;; 	 (lambda (mult)
;; 	   (or (float-print-test (* mult x)) (set! res #f)))
;; 	 (map string->number
;; 	      '("1.0" "10.0" "100.0" "1.0e20" "1.0e50" "1.0e100"
;; 		"0.1" "0.01" "0.001" "1.0e-20" "1.0e-50" "1.0e-100")))
;; 	res))

;;     (SECTION 6 5 6)
;;     (test #t 'float-print-test (float-print-test f0.0))
;;     (test #t 'mult-float-print-test (mult-float-print-test f1.0))
;;     (test #t 'mult-float-print-test (mult-float-print-test
;; 				     (string->number "3.0")))
;;     (test #t 'mult-float-print-test (mult-float-print-test
;; 				     (string->number "7.0")))
;;     (test #t 'mult-float-print-test (mult-float-print-test
;; 				     (string->number "3.1415926535897931")))
;;     (test #t 'mult-float-print-test (mult-float-print-test
;; 				     (string->number "2.7182818284590451")))))

;; (define (test-bignum)
;;   (define tb
;;     (lambda (n1 n2)
;;       (= n1 (+ (* n2 (quotient n1 n2))
;; 	       (remainder n1 n2)))))
;;   (define b3-3 (string->number "33333333333333333333"))
;;   (define b3-2 (string->number "33333333333333333332"))
;;   (define b3-0 (string->number "33333333333333333330"))
;;   (define b2-0 (string->number "2177452800"))
;;   (newline)
;;   (display ";testing bignums; ")
;;   (newline)
;;   (SECTION 6 5 7)
;;   (test 0 modulo b3-3 3)
;;   (test 0 modulo b3-3 -3)
;;   (test 0 remainder b3-3 3)
;;   (test 0 remainder b3-3 -3)
;;   (test 2 modulo b3-2 3)
;;   (test -1 modulo b3-2 -3)
;;   (test 2 remainder b3-2 3)
;;   (test 2 remainder b3-2 -3)
;;   (test 1 modulo (- b3-2) 3)
;;   (test -2 modulo (- b3-2) -3)
;;   (test -2 remainder (- b3-2) 3)
;;   (test -2 remainder (- b3-2) -3)

;;   (test 3 modulo 3 b3-3)
;;   (test b3-0 modulo -3 b3-3)
;;   (test 3 remainder 3 b3-3)
;;   (test -3 remainder -3 b3-3)
;;   (test (- b3-0) modulo 3 (- b3-3))
;;   (test -3 modulo -3 (- b3-3))
;;   (test 3 remainder 3 (- b3-3))
;;   (test -3 remainder -3 (- b3-3))

;;   (test 0 modulo (- b2-0) 86400)
;;   (test 0 modulo b2-0 -86400)
;;   (test 0 modulo b2-0 86400)
;;   (test 0 modulo (- b2-0) -86400)
;;   (test 0 modulo  0 (- b2-0))
;;   (test #t 'remainder (tb (string->number "281474976710655325431") 65535))
;;   (test #t 'remainder (tb (string->number "281474976710655325430") 65535))

;;   (let ((n (string->number
;; 	    "30414093201713378043612608166064768844377641568960512")))
;;     (and n (exact? n)
;; 	 (do ((pow3 1 (* 3 pow3))
;; 	      (cnt 21 (+ -1 cnt)))
;; 	     ((negative? cnt)
;; 	      (zero? (modulo n pow3))))))

;;   (SECTION 6 5 8)
;;   (test "281474976710655325431" number->string
;; 	(string->number "281474976710655325431"))
;;   (report-errs))

;; (define (test-numeric-predicates)
;;   (let* ((big-ex (expt 2 150))
;; 	 (big-inex (exact->inexact big-ex)))
;;     (newline)
;;     (display ";testing bignum-inexact comparisons;")
;;     (newline)
;;     (SECTION 6 5 5)
;;     (test #f = (+ big-ex 1) big-inex (- big-ex 1))
;;     (test #f = big-inex (+ big-ex 1) (- big-ex 1))
;;     (test #t < (- (inexact->exact big-inex) 1)
;; 	  big-inex
;; 	  (+ (inexact->exact big-inex) 1))))


;; (SECTION 6 5 9)
;; (test "0" number->string 0)
;; (test "100" number->string 100)
;; (test "100" number->string 256 16)
;; (test 100 string->number "100")
;; (test 256 string->number "100" 16)
;; (test #f string->number "")
;; (test #f string->number ".")
;; (test #f string->number "d")
;; (test #f string->number "D")
;; (test #f string->number "i")
;; (test #f string->number "I")
;; (test #f string->number "3i")
;; (test #f string->number "3I")
;; (test #f string->number "33i")
;; (test #f string->number "33I")
;; (test #f string->number "3.3i")
;; (test #f string->number "3.3I")
;; (test #f string->number "-")
;; (test #f string->number "+")
;; (test #t 'string->number (or (not (string->number "80000000" 16))
;; 			     (positive? (string->number "80000000" 16))))
;; (test #t 'string->number (or (not (string->number "-80000000" 16))
;; 			     (negative? (string->number "-80000000" 16))))

