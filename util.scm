(define (fatal-error s . args)
  (print "Error: " s)
  (if (not (null? args))
      (apply print args))
  (exit 1))

(define (read_all filename)
  (let loop ((port (open-input-file filename))
             (src (list)))
    (define x (read port))
    (if (eof-object? x)
        (reverse src)
        (loop port (cons x src)))))

(define (single lst)
  (eq? 1 (length lst)))
     
(define (replace_ext filename ext)
  (define ind (string-index filename "."))
  (if (eq? ind -1)
      (string-append filename ext)
      (string-append (substring filename 0 ind) ext)))

(define (member? lst x)
  (not (eq? (member lst x) #f)))

(define (last lst)
  (car (reverse lst)))

(define (repeat what times)
  (let loop ((res (list))
             (n times))
    (if (<= n 0)
        res
        (loop (cons what res) (- n 1)))))
