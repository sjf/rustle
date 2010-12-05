(define (string-empty? s)
  (eq? (string-length s) 0))

(define (string-at s i)
  (substring s i (+ i 1)))

(define (string-slice1 s start)
  (substring s start (string-length s)))

(define (string-index s c)
  (let loop ((pos 0))
    (cond ((>= pos (string-length s)) -1)
          ((equal? c (string-at s pos)) pos)
          (else (loop (+ pos 1))))))

(define (join lst sep)
  (define strs (map to-str lst))
  (let loop ((strs strs)
             (res ""))
    (cond 
     ((null? strs) res)
     ((single strs) (string-append res (car strs)))
     (else (loop (cdr strs)
                 (string-append (string-append res (car strs)) sep))))))

(define (to-str x)
  (sprintf "~a" x))        

