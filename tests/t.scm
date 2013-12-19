(require "testing")
(test #t (boolean? #t))
(test #t (boolean? #f))
(test #f (boolean? 42))

(define x 42)
(test 42 x)
(set! x 13)
(test 13 x)

(define mesg "hello")
(test "hello" mesg)
(set! mesg "world")
(test "world" mesg)

(define f (lambda (x) x))
(test 999 (f 999))
(define g (lambda (a b c) 
            (cons a (cons b (cons c (quote ()))))))
(test (quote (1 2 3)) (g 1 2 3))
(define g (lambda (x) (set! x 333) x))
(test 333 (g 1))

(define x 42)
(define h (lambda () (set! x 56) x))
(test 42 x)
(test 56 (h))
(test 56 x)

(test 111 (if #t (+ 110 1) (+ 221 1)))
(test 444 (if #f (+ 332 1) (+ 443 1)))

(define p (cons "a" "b"))
(test (quote ("a" . "b")) p)
(test #t (pair? p))
(test #f (pair? 0))

;; R4RS SECTION 2 1
;; test that all symbol characters are supported.
(test (quote (+ - ... !.. $.+ %.- &.! *.: /:. :+. <-. =. >. ?. ~. _. ^.))
      (quote (+ - ... !.. $.+ %.- &.! *.: /:. :+. <-. =. >. ?. ~. _. ^.)))

(test (cons (string->symbol "a") (string->symbol "b")) 
      (quote (a . b)))
;(test (list) (quote ()))
;(test (cons 1 (cons 3 (cons 3 (list)))) (quote (1 2 3)))
(test (cons 1 (cons 2 3)) (quote (1 2 . 3)))

;(define g (lambda () (define h (lambda () 42))))
;(define h1 (g))
;(test 42 (h1))

;; Funargs problem
(define g (lambda () (define var 0) 
                  (define h (lambda () (set! var (+ 1 var)) var)) h))
(define h1 (g))
(test 1 (h1))
(test 2 (h1))
(define h2 (g))
(test 1 (h2))
(test 3 (h1))

;; Function calls with optional arguments
(test #t              ((lambda () #t)))
(test 1               ((lambda (z) z) 1))
(test (quote (2 . 3)) ((lambda (x1 x2) (cons x1 x2)) 2 3))
(test 4               ((lambda (x . rest) x) 4))
(test (quote (5 . 6)) ((lambda (x1 x2 . rest) (cons x1 x2)) 5 6))
;(test (quote (7 8 (9 10))) ((lambda (x1 x2 . rest) (list x1 x2 rest)) 7 8 9 10))






