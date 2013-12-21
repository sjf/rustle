(require "testing")
;(SECTION 6 3)
(test '(a b c d e) '(a . (b . (c . (d . (e . ()))))))
(test '(a b c . d) '(a . (b . (c . d))))

(define x (list 'a 'b 'c))
(define y x)
(test '(a b c) y)
;(test #t (list? y))

;(set-cdr! x 4)
;(test '(a . 4) 'set-cdr! x)
;(test #t eqv? x y)
;(test #f (list? y))
;(let ((x (list 'a))) (set-cdr! x x) (test #f 'list? (list? x)))

(test #t (pair? '(a . b)))
(test #t (pair? '(a . 1)))
(test #t (pair? '(a b c)))
(test #f (pair? '()))
;(test #f (pair? '#(a b)))

(test '(a) (cons 'a '()))
(test '((a) b c d) (cons '(a) '(b c d)))
(test '("a" b c) (cons "a" '(b c)))
(test '(a . 3) (cons 'a 3))
(test '((a b) . c) (cons '(a b) 'c))

(test 'a (car '(a b c)))
(test '(a) (car '((a) b c d)))
(test 1 (car '(1 . 2)))

(test '(b c d) (cdr '((a) b c d)))
(test 2 (cdr '(1 . 2)))

;(define (f) (list 'not-a-constant-list))
;(define (g) '(constant-list))
;(set-car! (f) 3)                       ==>  unspecified
;(set-car! (g) 3)                       ==>  error

(test #t (null? '()))

        ;; (list? '(a b c))               ==>  #t
        ;; (list? '())                    ==>  #t
        ;; (list? '(a . b))               ==>  #f
        ;; (let ((x (list 'a)))
        ;;   (set-cdr! x x)
        ;;   (list? x))                   ==>  #f

(test '(a 7 c) (list 'a (+ 3 4) 'c))
(test '() (list))

;; (test 3 (length '(a b c)))
;; (test 3 (length '(a (b) (c d e))))
;; (test 0 (length '()))

;; (test '(x y) (append '(x) '(y)))
;; (test '(a b c d) (append '(a) '(b c d)))
;; (test '(a (b) (c)) (append '(a (b)) '((c))))
;; (test '() (append))
;; (test '(a b c . d) (append '(a b) '(c . d)))
;; (test 'a (append '() 'a))

;; (test '(c b a) (reverse '(a b c)))
;; (test '((e (f)) d (b c) a) (reverse '(a (b c) d (e (f)))))

;; (test 'c (list-ref '(a b c d) 2))

;; (test '(a b c) (memq 'a '(a b c)))
;; (test '(b c) (memq 'b '(a b c)))
;; (test '#f (memq 'a '(b c d)))
;; (test '#f (memq (list 'a) '(b (a) c)))
;; (test '((a) c) (member (list 'a) '(b (a) c)))
;; (test '(101 102) (memv 101 '(100 101 102)))

;; (define e '((a 1) (b 2) (c 3)))
;; (test '(a 1) (assq 'a e))
;; (test '(b 2) (assq 'b e))
;; (test #f (assq 'd e))
;; (test #f (assq (list 'a) '(((a)) ((b)) ((c)))))
;; (test '((a)) (assoc (list 'a) '(((a)) ((b)) ((c)))))
;; (test '(5 7) (assv 5 '((2 3) (5 7) (11 13))))
