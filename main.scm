(declare (uses posix))
(require 'string)
(require 'util)
(require 'c_code)

;; some constants
(define *expression* (quote expression))
(define *procedure*  (quote procedure))
(define *t_var*      (quote var))

;; these must match the constants in builtin.c
(define T_INT      (quote T_INT))
(define T_STRING   (quote T_STRING))
(define T_SYMBOL   (quote T_SYMBOL))
(define T_NONE     (quote T_NONE))
(define T_TRUE     (quote T_TRUE))
(define T_FALSE    (quote T_FALSE))
(define T_PAIR     (quote T_PAIR))
(define T_NULL     (quote T_NULL))

;(define (ir-new-expression value))
;(define (ir-new-procedure address result))
(define (ir-new type value . const_value)
  ;; Simple intermediate representation
  ;; Has a type, which should be expression or procedure
  ;; And a value, which is the C variable name or address
  ;; of the value.
  ;; Optional const_value for constants, will be used later for 
  ;; optimisation
  (list 'IR type value (car-or-null const_value)))
(define (ir-type-of l) (cadr l))
(define (ir-value-of l) (caddr l))

;; Primitive values
(define (gen-int-const value)
  (ir-new *expression* (c-new-obj T_INT value)))

(define (gen-string-const value)  
  (ir-new *expression* (c-new-obj T_STRING value)))

(define (gen-symbol-const value)
  (ir-new *expression* (c-new-obj T_SYMBOL value)))

(define (gen-null-const)
  (ir-new *expression* (c-new-obj T_NULL 'unused)))

;; Data constants
(define (gen-pair-const value)
  (define a (gen-define (car value)))
  (define b (gen-define (cdr value)))
  (ir-new *expression* 
        (c-new-obj T_PAIR (list (ir-value-of a)
                                (ir-value-of b)))))

(define (gen-vector-cons value)
  (todo))

(define (gen-define form)
  (debug-log "Generating Data: " form  (type-of form))
  (cond ((integer? form) (gen-int-const form))
        ((string? form)  (gen-string-const form))
        ((symbol? form)  (gen-symbol-const form))
        ((eq? #t form)   (gen-true))
        ((eq? #f form)   (gen-false))
        ((null? form)    (gen-null-const))
        ((pair? form)    (gen-pair-const form))
        (else (fatal-error "gen-define unimplemented:" form))))

;;

(define (var-name expr)
  (caddr expr))

(define (special? form)
  (and (list? form)
       (not (null? form))
       (member? (car form) 
                (quote (lambda let define set! quote if and or begin)))))
    
(define (gen-symbol symbol)
  (ir-new *expression* (c-lookup-symbol-table symbol)))
             
; special forms:
; lambda
; let, let*, letrec
; define
; set!
; quote, quasiquote
; if, cond
; and or
; begin
; let, do loops
; 

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

(define (gen-fun-call form)
  (define lst (map generate form))
  (if (null? lst)
      (fatal-error "Cannot call empty list"))
  (define func (car lst))
  ;(if (not (eq? *procedure* (ir-type-of func)))
  ;    (fatal-error "Cannot call" func))
  (define args (map ir-value-of (cdr lst)))
  (define res_name 
    (c-call-function (ir-value-of func) args))  
  (ir-new *expression* res_name))

(define (check-args= args expected-len function)
  (if (not (eq? expected-len (length args)))
      (fatal-error (sprintf 
                    "Expected ~a arguments, got ~a: ~a" 
                    expected-len (length args) function))))
(define (check-args<= args min-len function)
  (if (< (length args) min-len)
      (fatal-error (sprintf 
                    "Expected at least ~a arguments, got ~a: ~a" 
                    min-len (length args) function))))

(define (check-type arg type-pred function)
  (if (not (type-pred arg))
      (fatal-error (sprintf "Unexpected type got ~a: ~a"
                            (type-of arg) function))))
(define (gen-true)
  (ir-new *expression* (c-gen-true) #t))
(define (gen-false)
  (ir-new *expression* (c-gen-false) #f))


(define (gen-special form) 
  (define val (car form))
  (define args (cdr form))
  (cond ((eq? val (quote set!))
         ;; some compile time checking for special forms
         (check-args= args 2 "set!")
         (check-type (car args) symbol? "set!")
         (define value_name (var-name (generate (cadr args))))
         (define sym_name (var-name (gen-symbol (car args))))
         (c-assign sym_name value_name)
         (ir-new *expression* (c-gen-none) #f))
         
        ((eq? val (quote define)) 
         (check-args= args 2 "define")
         (check-type (car args) symbol? "define")
         (define var_name (var-name (generate (cadr args))))
         (define sym_name (car args))
         (c-add-to-symbol-table sym_name var_name))
         
        ((eq? val (quote lambda))
         (check-args<= args 2 "lambda")
         (define formals (car args))
         (define body (cdr args))         
         (check-type formals 
                     (lambda (x) (or (list? x)
                                     (symbol? x))) "lambda")
         (debug-log "Generating lambda: " body)      
         (define proc (c-new-procedure formals))
         (define res (last (map generate body)))
         ; Return value will be available in res
         (c-end-procedure (ir-value-of res))
         (ir-new *procedure* proc))

        ((eq? val (quote if))
         (check-args= args 3 "if")
         (define pred (car args))
         (define true_expr (cadr args))
         (define false_expr (caddr args))
         (define res (c-if (ir-value-of (generate pred))))
         (c-else res (ir-value-of (generate true_expr)))
         (c-endif res (ir-value-of (generate false_expr)))
         (ir-new *expression* res))
        ((eq? val (quote quote))
         (check-args= args 1 "quote")
         (gen-define (car args)))
        (else (fatal-error "Unsupported special form: " val))))
  

(define (generate form)
  (debug-log "Generating: " form " " (type-of form))
  (cond ((integer? form) (gen-int-const form))
        ((string? form)  (gen-string-const form))
        ((symbol? form)  (gen-symbol form))
        ((eq? #t form)   (gen-true))
        ((eq? #f form)   (gen-false))
        ;; todo generate empty list
        ((special? form) (gen-special form))
        ((list? form)    (gen-fun-call form))
        (else (debug-log "Passing.. " form)))
)

(define (generate-code src)
  (c-main)
  ;; add setup code for main namespace
  (map generate src)
  (c-end-main)
  #t)

(define (main) 
  (debug-log "Rustle Scheme to C Compiler 0.0")
  (if (< (length (argv)) 2 )
      (fatal-error "Usage ./compiler file.scm"))
  (define filename (cadr (argv)))
  (define c_src (replace_ext! filename ".c"))

  ;; Parse the file
  (define src (read_all filename))
  ;(set! src (transform-==> src))

  ;; Generate code
  (generate-code src)
  (c-write-src-file c_src)
  ;; Call gcc
  (c-compile c_src)
  )
;(trace main)      
(main)
