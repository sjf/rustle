;;; Logging
(define (type-name x)
  (cond ((eq? #t x)  "#t")
        ((eq? #f x)  "#f")
        ((symbol? x) "symbol")
        ((char? x)   "char")
        ((string? x) "string")
        ((number? x) "number")
        ((null? x)   "empty-list")
        ((special? x) "special-form")
        ((pair? x)   "pair")))

(define (fatal-error mesg . args)
  (print-call-chain (current-error-port))
  (print-stderr (format "EE Error: ~a ~a~%" mesg 
                        (string-join args " ")))
  (exit 1))

(define (debug-log mesg . args)
  (print-stderr (sprintf "II ~a ~a~%" mesg 
                         (string-join args " "))))

(define (todo)
  (print-call-chain (current-error-port))
  (print-stderr (sprintf "EE TODO Error")))

(define (qq a)
  (sprintf "\"~a\"" a))

;;; IO Functions 
(define (read-scm-file filename)
  (let loop ((port (open-input-file filename))
             (src (list)))
    (define x (read port))
    (if (eof-object? x)
        (reverse src)
        (loop port (cons x src)))))

(define (get-extension filename)
  (define ind (string-index-right filename #\.))
  (if (eq? ind #f) filename
      (substring filename (+ ind 1))))

(define (replace-ext filename ext)
  (define ind (string-index-right filename #\.))
  (if (eq? ind #f)
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

(define (car-or-null lst)
  (if (null? lst) lst
      (car lst)))

;;; Some missing scheme functions
(define (repeat what times)
  (let loop ((res (list))
             (n times))
    (if (<= n 0)
        res
        (loop (cons what res) (- n 1)))))

(define (inc x) 
  (+ x 1))
