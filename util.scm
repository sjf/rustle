;;; Logging
(define (fatal-error s . args)
  (print "Error: " s)
  (if (not (null? args))
      (apply print args))
  (exit 1))

(define (debug-log s . args)
  (print-stderr (sprintf "II ~a~a~%" s (join args ""))))

;;; IO Functions 
(define (read_all filename)
  (let loop ((port (open-input-file filename))
             (src (list)))
    (define x (read port))
    (if (eof-object? x)
        (reverse src)
        (loop port (cons x src)))))

(define (replace_ext! filename ext)
  (define ind (string-index filename "."))
  (if (eq? ind -1)
      (string-append filename ext)
      (string-append (substring filename 0 ind) ext)))

(define (print-stderr s)
  (format (current-error-port) "~a" s))

;;; List Functions
(define (member? lst x)
  (not (eq? (member lst x) #f)))

(define (last lst)
  (car (reverse lst)))

(define (single? lst)
  (eq? 1 (length lst)))

;;; Some missing scheme functions
(define (repeat what times)
  (let loop ((res (list))
             (n times))
    (if (<= n 0)
        res
        (loop (cons what res) (- n 1)))))

(define (inc! x) 
  (set! x (+ x 1)))
