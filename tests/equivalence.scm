(require "testing")
;(SECTION 6 1)
(test #f (not #t))
(test #f (not 3))
(test #f (not (list 3)))
(test #t (not #f))
(test #f (not '()))
(test #f (not (list)))
(test #f (not 'nil))

(test #t (boolean? #f))
(test #f (boolean? 0))
(test #f (boolean? '()))

;(SECTION 6 2)
(test #t (eqv? 'a 'a))
(test #f (eqv? 'a 'b))
(test #t (eqv? 2 2))
(test #t (eqv? '() '()))
(test #t (eqv? '10000 '10000))
(test #f (eqv? (cons 1 2)(cons 1 2)))
(test #f (eqv? (lambda () 1) (lambda () 2)))
(test #f (eqv? #f 'nil))
(define p (lambda (x) x))
(test #t (eqv? p p))

;; Unspecified by the standard
(test #f (eqv? "" ""))
;(test #f (eqv? '#() '#()))
(test #f (eqv? (lambda (x) x)
               (lambda (x) x)))
(test #f (eqv? (lambda (x) x)
               (lambda (y) y)))

;; (define gen-counter
;;  (lambda ()
;;    (let ((n 0))
;;       (lambda () (set! n (+ n 1)) n))))
;; (let ((g (gen-counter))) (test #t eqv? g g))
;; (test #f eqv? (gen-counter) (gen-counter))
;; (letrec ((f (lambda () (if (eqv? f g) 'f 'both)))
;; 	 (g (lambda () (if (eqv? f g) 'g 'both))))
;;   (test #f eqv? f g))

;; The next set of examples shows the use of eqv? with procedures that have local state. Gen-counter must return a distinct procedure every time, since each procedure has its own internal counter. Gen-loser, however, returns equivalent procedures each time, since the local state does not affect the value or side effects of the procedures.

;; (define gen-counter
;;   (lambda ()
;;     (let ((n 0))
;;       (lambda () (set! n (+ n 1)) n))))
;; (let ((g (gen-counter)))
;;   (eqv? g g))                          ==>  #t
;; (eqv? (gen-counter) (gen-counter))
;;                                        ==>  #f
;; (define gen-loser
;;   (lambda ()
;;     (let ((n 0))
;;       (lambda () (set! n (+ n 1)) 27))))
;; (let ((g (gen-loser)))
;;   (eqv? g g))                          ==>  #t
;; (eqv? (gen-loser) (gen-loser))
;;                                        ==>  unspecified
;; (letrec ((f (lambda () (if (eqv? f g) 'both 'f)))
;;          (g (lambda () (if (eqv? f g) 'both 'g)))
;;   (eqv? f g))                        
;; )
;;                ==>  unspecified
;; (letrec ((f (lambda () (if (eqv? f g) 'f 'both)))
;;          (g (lambda () (if (eqv? f g) 'g 'both)))
;;   (eqv? f g))
;; )
;;                ==>  #f
;; (eqv? '(a) '(a))                       ==>  unspecified
;; (eqv? "a" "a")                         ==>  unspecified
;; (eqv? '(b) (cdr '(a b)))               ==>  unspecified
;; (let ((x '(a)))
;;   (eqv? x x))                          ==>  #t


(test #t (eq? 'a 'a))
(test #f (eq? (list 'a) (list 'a)))
(test #t (eq? '() '()))
(test #t (eq? car car))
(define x '(a))
(test #t (eq? x x))
;(define x '#()) 
;(test #t (eq? x x)))
(define x (lambda (x) x))
(test #t (eq? x x))

(define test-eq?-eqv?-agreement
  (lambda (obj1 obj2)
    (if (not (eq? (eq? obj1 obj2) 
                  (eqv? obj1 obj2)))
        ((lambda ()
	   (display "ERR eqv? and eq? disagree about ")
	   (display obj1)
	   (display #\space)
	   (print obj2)))
        #f)))

(test-eq?-eqv?-agreement '#f '#f)
(test-eq?-eqv?-agreement '#t '#t)
(test-eq?-eqv?-agreement '#t '#f)
(test-eq?-eqv?-agreement '(a) '(a))
(test-eq?-eqv?-agreement '(a) '(b))
(test-eq?-eqv?-agreement car car)
(test-eq?-eqv?-agreement car cdr)
(test-eq?-eqv?-agreement (list 'a) (list 'a))
(test-eq?-eqv?-agreement (list 'a) (list 'b))
;(test-eq?-eqv?-agreement '#(a) '#(a))
;(test-eq?-eqv?-agreement '#(a) '#(b))
(test-eq?-eqv?-agreement "abc" "abc")
(test-eq?-eqv?-agreement "abc" "abz")

(test #t (equal? 'a 'a))
(test #t (equal? '(a) '(a)))
(test #t (equal? '(a (b) c) '(a (b) c)))
(test #t (equal? "abc" "abc"))
(test #t (equal? 2 2))
;(test #t (equal? (make-vector 5 'a) (make-vector 5 'a)))
