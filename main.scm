(declare (uses posix))
(require 'string)
(require 'util)
(require 'c_code)
(require 'preprocessor)

(require 'srfi-69)

;; some constants
(define *expression* (quote expression))
(define *procedure*  (quote procedure))
(define *t_var*      (quote var))

;; these must match the constants in builtin.c
(define T_NONE     (quote T_NONE))
(define T_TRUE     (quote T_TRUE))
(define T_FALSE    (quote T_FALSE))
(define T_NULL     (quote T_NULL))
(define T_INT      (quote T_INT))
(define T_SYMBOL   (quote T_SYMBOL))
(define T_CHAR     (quote T_CHAR))
(define T_STRING   (quote T_STRING))
(define T_PAIR     (quote T_PAIR))

;(define (ir-new-expression value))
;(define (ir-new-procedure address result))
(define (ir-new type value . rest)
  ;; Simple intermediate representation
  ;; Has a type, which should be expression or procedure
  ;; And a value, which is the C variable name or address
  ;; of the value.
  (list 'IR type value rest))
(define (ir-type-of l) (cadr l))
(define (ir-value-of l) (caddr l))

;; Primitive values
(define (gen-true)
  (ir-new *expression* (c-gen-true) #t))

(define (gen-false)
  (ir-new *expression* (c-gen-false) #f))

(define (gen-int-const value)
  (ir-new *expression* (c-new-obj T_INT value)))

(define (gen-symbol-const value)
  (ir-new *expression* (c-new-obj T_SYMBOL value)))

(define (gen-char-const value)
  (ir-new *expression* (c-new-obj T_CHAR value)))

(define (gen-string-const value)
  (ir-new *expression* (c-new-obj T_STRING value)))

(define (gen-null-const)
  (ir-new *expression* (c-new-obj T_NULL 'unused)))

;; Data constants
(define (gen-pair-const value)
  (define a (gen-quote (car value)))
  (define b (gen-quote (cdr value)))
  (ir-new *expression*
        (c-new-obj T_PAIR (list (ir-value-of a)
                                (ir-value-of b)))))

(define (gen-vector-cons value)
  (todo))

(define (gen-quote form)
  (debug-log "Generating Data: " form  (type-of form))
  (cond  ((eq? #t form)   (gen-true))
        ((eq? #f form)   (gen-false))
        ((null? form)    (gen-null-const))
        ((symbol? form)  (gen-symbol-const form))
        ((char? form)    (gen-char-const form))
        ((string? form)  (gen-string-const form))
        ((integer? form) (gen-int-const form))
        ((pair? form)    (gen-pair-const form))
        (else (fatal-error "gen-quote unimplemented:" form))))

(define (var-name expr) ;;todo replace with ir-var-name/ir-value
  (caddr expr))

(define (special? form)
  (and (list? form)
       (not (null? form))
       (member? (car form)
                (quote (lambda let define set! quote if and or begin)))))

(define (gen-symbol symbol)
  (ir-new *expression* (c-lookup-symbol-table symbol)))

(define (type-of x)
  (cond ((string? x) "string")
        ((number? x) "number")
        ((symbol? x) "symbol")
        ((eq? #t x)  "#t")
        ((eq? #f x)  "#f")
        ((char? x)   "char")
        ((null? x)   "empty-list")
        ((special? x) "special-form")
        ((pair? x)   "pair")))

(define (gen-fun-call form env)
  (if (null? form)
      (fatal-error "Cannot call empty list"))
  (define lst (map (lambda (f) (generate f env)) form))
  (debug-log "Calling: " (car lst))
  ;(if (not (eq? *procedure* (ir-type-of func)))
  ;    (fatal-error "Cannot call" func))
  (define func (ir-value-of (car lst)))
  (define args (map ir-value-of (cdr lst)))
  (define res_name (c-call-function func args))
  (ir-new *expression* res_name))

(define (check-args= args expected-len function)
  (if (not (eq? expected-len (length args)))
      (fatal-error (sprintf
                    "'~a' expected ~a arguments, got ~a"
                    function expected-len (length args)))))
(define (check-args<= args min-len function)
  (if (< (length args) min-len)
      (fatal-error (sprintf
                    "'~a' expected at least ~a arguments, got ~a"
                    function min-len (length args)))))

(define (check-type arg type-pred function . mesg)
  (if (not (type-pred arg))
      (fatal-error (sprintf
                    "'~a' passed unexpected type, recieved '~a': ~a ~a"
                    function (type-of arg) arg (string-join mesg " ")))))

(define (gen-special form env)
  (define val (car form))
  (define args (cdr form))
  (cond ((eq? val (quote set!))
         (check-args= args 2 "set!")
         (check-type (car args) symbol? "set!"
                     "Only the form (set! symbol expr) is supported")
         (letrec ((symbol (car args))
                  (dest   (gen-symbol symbol))
                  (value  (generate (cadr args) env)))
           (env-insert! symbol dest env)
           (env-display env)
           (c-assign (var-name dest) (var-name value))
           ;; Return value of set! is undefined
           (ir-new *expression* (c-gen-none) #f)))

        ((eq? val (quote define))
         (check-args= args 2 "define")
         (check-type (car args) symbol? "define")
         (let ((name (car args))
               (value (generate (cadr args) env)))
           (env-insert! name value env)
           (c-add-to-symbol-table name (var-name value))))

        ((eq? val (quote lambda))
         (check-args<= args 2 "lambda")
         (define formals (car args))
         (define body (cdr args))
         (check-type formals
                     (lambda (x) (or (symbol? x)
                                     (list? x)
                                     (pair? x))) "lambda")
         (define (parse-args formals)
           (cond ((symbol? formals)
                    (list (list formals) #f))
                 ((list? formals)
                  (list formals #f))
                 (else
                  (let loop ((formals formals)
                             (args (list)))
                    (cond
                     ((pair? (cdr formals))
                      (loop (cdr formals) (cons (car formals) args)))
                     ((pair? formals)
                      (list (reverse (cons (car formals) args)) (cdr formals))))))))
         (let ((proc (c-new-procedure
                      (car (parse-args formals))
                      (cadr (parse-args formals))))
               (res  (last (map (lambda (form)
                                  (generate form env)) body))))
           ; Return value will be available in res
           (c-end-procedure (ir-value-of res))
           (ir-new *procedure* proc formals)))

        ((eq? val (quote if))
         (check-args= args 3 "if")
         (define pred (car args))
         (define true_expr (cadr args))
         (define false_expr (caddr args))
         (define res (c-if (ir-value-of (generate pred env))))
         (c-else res (ir-value-of (generate true_expr env)))
         (c-endif res (ir-value-of (generate false_expr env)))
         (ir-new *expression* res))
        ((eq? val (quote quote))
         (check-args= args 1 "quote")
         (gen-quote (car args)))
        (else (fatal-error "Unsupported special form: " val))))

(define (generate form env)
  (debug-log "Generating: " form (type-of form))
  (cond ((eq? #t form)   (gen-true))
        ((eq? #f form)   (gen-false))
        ((symbol? form)  (gen-symbol form))
        ((integer? form) (gen-int-const form))
        ((char? form)    (gen-char-const form))
        ((string? form)  (gen-string-const form))
        ((special? form) (gen-special form env))
        ((list? form)    (gen-fun-call form env))
        (else            (fatal-error "Unimplemented generate:" form (type-of form)))))

;; Functions for manipulating the namespace hashtables
;; env datastructure: list of hashtables, one for each nested
;; namespace.
;; hashtable entries are symbol -> IR list
(define (env-new-ns env)
  (cons (make-hash-table) env))
(define (env-lookup symbol env)
  (cond ((null? env) #f))
  (let ((res (hash-table-ref/default (car env) symbol #f)))
    (if res res
        (env-lookup symbol (cdr env)))))
(define (env-insert! symbol value env)
  (hash-table-set! (car env) symbol value))

(define (env-display env)
  (define (display-ns ns depth)
    (define (display-entry pair)
      (printf "~a~a ==> ~a~%" (make-string depth)
              (car pair) (cdr pair)))
    (let ((alist (hash-table->alist ns)))
      (define (cmp a b) (string> (symbol->string (car a))
                                 (symbol->string (car b))))
      (sort! alist cmp)
      (map display-entry alist)))
  (print " **** ENV **** ")
  (let loop ((i 0)
             (env env))
    (cond ((not (null? env))
           (display-ns (car env) i)
           (loop (+ i 1) (cdr env))))))

(define (generate-code src)
  (c-main)
  ;; add setup code for main namespace
  (define env (env-new-ns '()))
  (map (lambda (form) (generate form env))  src)
  (c-end-main)
  (env-display env)
  #t)

(define (main)
  (debug-log "Rustle Scheme to C Compiler 0.0")
  (if (< (length (argv)) 2 )
      (fatal-error "Usage ./compiler file.scm"))
  (define filename (cadr (argv)))
  (define c_src (replace-ext filename ".c"))

  ;; Parse the file
  (define src (read-scm-file filename))
  (set! src (preprocessor src))

  ;; Generate code
  (generate-code src)
  (c-write-src-file c_src)
  ;; Call gcc
  (c-compile c_src))

;(trace main)
(main)
