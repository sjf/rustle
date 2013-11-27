;; String functions

(define (string-empty? s)
  (eq? (string-length s) 0))

(define (string-at s i)
  (substring s i (+ i 1)))

;; Slice to the end of the string
(define (string-slice1 s start)
  (substring s start (string-length s)))

;; Index of character c in string s
;; Provided by chicken
;; (define (string-index s c)
;;   (let loop ((pos 0))
;;     (cond ((>= pos (string-length s)) -1)
;;           ((equal? c (string-at s pos)) pos)
;;           (else (loop (+ pos 1))))))

;; (define (string-rindex s c) 
;;   (let loop ((pos (- (string-length s) 1)))
;;     (cond ((< 0 pos) -1)
;;           ((equal? c (string-at s pos) pos))
;;           (else (loop (- pos 1))))))
    
(define (string-join lst sep)
  (define strs (map to-str lst))
  (let loop ((strs strs)
             (res ""))
    (cond 
     ((null? strs) res)
     ((single? strs) (string-append res (car strs)))
     (else (loop (cdr strs)
                 (string-append 
                  (string-append res (car strs)) sep))))))

(define (to-str x)
  (sprintf "~a" x))        

