(declare (uses posix))

(define (fatal_error s . args)
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

(define (to-str x)
  (sprintf "~a" x))        

(define (single lst)
  (eq? 1 (length lst)))

(define (join lst sep)
  (define strs (map to-str lst))
  (let loop ((strs strs)
             (res ""))
    (cond 
     ((null? strs) res)
     ((single strs) (string-append res (car strs)))
     (else (loop (cdr strs)
                 (string-append (string-append res (car strs)) sep))))))
     
(define (replace_ext filename ext)
  (define ind (string-index filename "."))
  (if (eq? ind -1)
      (string-append filename ext)
      (string-append (substring filename 0 ind) ext)))

(define (member? lst x)
  (not (eq? (member lst x) #f)))

;; some constants
(define *expression* (quote expression))
(define *t_var*      (quote var))

(define *t_int*      0)
(define *t_string*   1)


(define (type-of l) (car l))
(define (value-of l) (caddr l))

(define (c_escape s)
  ;; todo
  (sprintf "\"~a\"" s))

(define (gen-new-obj name type value)
  (emit-code (sprintf "object *~a = new_object(~a);" name type))
  (cond ((eq? type *t_string*) 
         (emit-code (sprintf "set_str_val(~a, ~a);" 
                             name (c_escape value))))
        ((eq? type *t_int*)
         (emit-code (sprintf "~a->val.int_ = ~a;" name value)))))

(define (gen-int-const value)     
  (define name (gen-tempname))
  (gen-new-obj name *t_int* value)
  (list *expression* *t_var* name))

(define (gen-string-const value)  
  (define name (gen-tempname))
  (gen-new-obj name *t_string* value)
  (list *expression* *t_var* name))

(define *code* (list))
(define (emit-code codes)
  (print "EMIT: " codes)
  (if (list? codes)
      (set! *code* (append *code* codes))
      (set! *code* (append *code* (list codes)))))

(define (special? form)
  (and (list? form) 
       (member? form (quote (lambda let define set! quote if and or begin)))))

(define temp-count 0)
(define (gen-tempname)
  (define name (string-append "v_" (number->string temp-count)))
  (set! temp-count (+ temp-count 1))
  name)
    
(define (gen-true-false form)
     (print "Passing.." form))

(define (gen-symbol symbol)
  (define var_name 
    (cond ((eq? symbol (quote +)) "add")
          ((eq? symbol (quote -)) "sub")
          ((eq? symbol (quote *)) "mul")
          ((eq? symbol (quote /)) "divv")
          ((eq? symbol (quote display)) "display")
          (else (gen-tempname))))
  ;(emit-code (sprintf "// obj *~a = lookup(~a);" var_name symbol))
  ;; for now      
  ;;(emit-code (sprintf "int ~a = 0;" name))
  (list *expression* *t_var* var_name)
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
        ((symbol? x) "symbol")
        ((list? x)   "list")
        ((eq? #t x)  "#t")
        ((eq? #f x)  "#f")
        ((char? x)   "char")))

(define (gen-fun-call lst)
  (if (null? lst)
      (fatal-error "Cannot call empty list"))
  (define func (car lst))
  (if (not (eq? *expression* (type-of func)))
      (fatal-error "Cannot call " (write func)))
  (define args (map value-of (cdr lst)))
  (define res_name (gen-tempname))
  (emit-code (sprintf "int ~a = ~a(~a);" 
                      res_name
                      (value-of func)
                      (join args ", ")))
  (list *expression* *t_var* res_name))

(define (generate form)
  (print "Generating: " form " " (type form))
  (cond ((integer? form) (gen-int-const form))
        ((string? form)  (gen-string-const form))
        ((symbol? form)  (gen-symbol form))
        ((eq? #t form)   (gen-true-false form))
        ((eq? #f form)   (gen-true-false form))
        ((special? form) (print "special form " form))
        ((list? form)    (gen-fun-call (map generate form)))
        (else (print "Passing.. " form)))
)

(define (setup-sym-table) 
  (list)
)

(define (generate-code src)
  (emit-code (setup-sym-table))
  ;; add setup code for main namespace
  (map generate src)
  )

(define *c_start* 
"#include <stdio.h>
#include <builtin.c>

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
   (list "-I."  filename "-o" exec_filename)))

(define (main) 
  (print "hello world")
  (if (< (length (argv)) 2 )
      (fatal_error "Usage ./compiler file.scm"))
  (define filename (cadr (argv)))
  (define c_src (replace_ext filename ".c"))

  ;; Parse the file
  (define src (read_all filename))
  (print src)
  ;; Generate code
  (define code (generate-code src))
  (write_c_file c_src *code*)
  ;; Call gcc
  (compile c_src)
  )
      
(main)

