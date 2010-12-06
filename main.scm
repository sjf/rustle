(declare (uses posix))
(require 'string)
(require 'util)
(require 'c_code)
(require 'testing)

;; some constants
(define *expression* (quote expression))
(define *t_var*      (quote var))

;; these must match the constants in builtin.c
(define *t_int*      (quote T_INT))
(define *t_string*   (quote T_STR))


(define (type-of l) (car l))
(define (value-of l) (caddr l))

(define (gen-int-const value)     
  (list *expression* *t_var* 
        (c-new-obj *t_int* value)))

(define (gen-string-const value)  
  (list *expression* *t_var* 
        (c-new-obj *t_string* value)))

(define (var-name expr)
  (caddr expr))

(define (special? form)
  (and (list? form) 
       (member? (car form) 
                (quote (lambda let define set! quote if and or begin)))))

    
(define (gen-true-false form)
     (print "Passing.." form))

(define (gen-symbol symbol)
  (cond ((eq? symbol (quote +)) (list *expression* *t_var* "add"))
        ((eq? symbol (quote -)) (list *expression* *t_var* "sub"))
        ((eq? symbol (quote *)) (list *expression* *t_var* "mul"))
        ((eq? symbol (quote /)) (list *expression* *t_var* "divv"))
        ;((eq? symbol (quote display)) (list *expression* *t_var* "display"))
        (else (define var_name (c-lookup-symbol-table symbol))
              (list *expression* *t_var* var_name)))
  )
             
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

(define (type x)
  (cond ((string? x) "string")
        ((number? x) "number")
        ((special? x) "special-form")
        ((symbol? x) "symbol")
        ((list? x)   "list")
        ((eq? #t x)  "#t")
        ((eq? #f x)  "#f")
        ((char? x)   "char")))

(define (gen-fun-call form)
  (define lst (map generate form))
  (if (null? lst)
      (fatal-error "Cannot call empty list"))
  (define func (car lst))
  (if (not (eq? *expression* (type-of func)))
      (fatal-error "Cannot call " (write func)))
  (define args (map value-of (cdr lst)))
  (define res_name 
    (c-call-function (value-of func) args))  
  (list *expression* *t_var* res_name))

(define (check-args args expected-len function)
  (if (not (eq? expected-len (length args)))
      (fatal-error (sprintf 
                    "Expected ~a arguments, got ~a: ~a" 
                    expected-len (length args) function))))

(define (check-type arg type-pred function)
  (if (not (type-pred arg))
      (fatal-error (sprintf "Unexpected type got ~a: ~a"
                            (type-of arg) function))))


(define (gen-special form) 
  (define val (car form))
  (define args (cdr form))
  (cond ((eq? val (quote set!))
         (check-args args 2 "set!")
         (check-type (car args) symbol? "set!")
         (define value_name (var-name (generate (cadr args))))
         (define sym_name (var-name (gen-symbol (car args))))
         (c-assign sym_name value_name))
         
        ((eq? val (quote define)) 
         (check-args args 2 "define")
         (check-type (car args) symbol? "define")
         (define var_name (var-name (generate (cadr args))))
         (define sym_name (car args))
         (c-add-to-symbol-table sym_name var_name))
         
        (else (display "Unsupported")))
)

(define (generate form)
  (print "Generating: " form " " (type form))
  (cond ((integer? form) (gen-int-const form))
        ((string? form)  (gen-string-const form))
        ((symbol? form)  (gen-symbol form))
        ((eq? #t form)   (gen-true-false form))
        ((eq? #f form)   (gen-true-false form))
        ((special? form) (gen-special form))
        ((list? form)    (gen-fun-call form))
        (else (print "Passing.. " form)))
)

(define (generate-code src)
  (c-setup-symbol-table)
  ;; add setup code for main namespace
  (map generate src)
  )

(define *c_start* 
"#include <runtime.c>
void run_main();

int main(int argc, char** argv) {
  run_main();
  return 0;
}
void run_main(){
")

(define *c_end* "\n}\n")

(define (write_c_file filename code)
  (define port (open-output-file filename))
  (display *c_start* port)
  (display (join code "\n") port)
  (display *c_end* port)
  (close-output-port port))

(define (compile filename)
  (define exec_filename (replace_ext filename ""))
  (process-execute 
   "/usr/bin/gcc-4.3"
   ;(list "-I." "builtin.o" filename "-o" exec_filename)))
   (list "-Wshadow" "-std=c99" "-Wall" 
         "-I."  filename "-o" exec_filename)))

(define (main) 
  (print "hello world")
  (if (< (length (argv)) 2 )
      (fatal_error "Usage ./compiler file.scm"))
  (define filename (cadr (argv)))
  (define c_src (replace_ext filename ".c"))

  ;; Parse the file
  (define src (read_all filename))
  (set! src (transform-==> src))

  ;; Generate code
  (define code (generate-code src))
  (write_c_file c_src *code*)
  ;; Call gcc
  (compile c_src)
  )
      
(main)

