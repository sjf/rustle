(define *src* (list))
(define *blocks* (list))

(define (emit-code codes)
  (print "EMIT: " codes)
  (if (list? codes)
      (set! (car *blocks*) 
            (append (car *blocks*) codes))
      (set! (car *blocks*) 
            (append (car *blocks*) (list codes)))))

(define (c-new-block) 
  (set! *blocks* (cons (list) *blocks*)))
(define (c-end-block)
  (set! *src* (append *src* (car *blocks*)))
  (set! *blocks* (cdr *blocks*)))

(define _temp-count 0)
(define (c-tempname)
  (define var_name 
    (string-append "v_" (number->string _temp-count)))
  (set! _temp-count (+ _temp-count 1))
  var_name)

(define _proc-count 0)
(define (c-procname)
  (define proc_name 
    (string-append "proc_" (number->string _proc-count)))
  (set! _proc-count (+ _proc-count 1))
  proc_name)
  
(define (c-param-name arg)
  (define param_name
    (string-append 
     "object * " (c-ident arg) "_" (number->string _temp-count)))
  (set! _temp-count (+ _temp-count 1))
  param_name)
                   

(define (c-escape s)
  ;; todo
  (sprintf "\"~a\"" s)
)

(define (c-ident s)
  ;; todo rm characters that cannot occur in idents
  (to-str s)
)

(define (c-params lst) (join lst ", "))

(define (c-new-obj type value)
  (define var_name (c-tempname))
  (emit-code (sprintf "object *~a = new_object(~a);" 
                      var_name type))

  (cond ((eq? type *t_string*) 
         (emit-code (sprintf 
                     "obj_set_str_val(~a, ~a);" 
                     var_name (c-escape value))))
        ((eq? type *t_int*) 
         (emit-code (sprintf 
                     "~a->val.int_ = ~a;" 
                     var_name value))))
  var_name)


(define (c-add-to-symbol-table symbol var)
  (emit-code (sprintf "add_to_environment(env, ~a, ~a);"
                      (c-escape symbol) var)))

(define (c-lookup-symbol-table symbol)
  (define var_name (c-tempname))
  (emit-code (sprintf "object *~a = lookup_sym(env, ~a);" 
                      var_name (c-escape symbol)))
  var_name)
             
(define (c-assign dest src)
  (emit-code (sprintf "copy_obj(~a, ~a);" 
                      dest src)))

(define (c-call-function function args)
  (define res_name (c-tempname))
  (define sep ", ")
  (if (null? args) (set! sep ""))
  (emit-code (sprintf 
              "object* ~a = call_procedure(~a, ~a~a ~a);"
              ;(emit-code (sprintf "object* ~a = ~a(~a);" 
              res_name
              function
              (length args)
              sep
              (join args ", ")))
  res_name)

(define (c-main)
  (c-new-block)
  (emit-code "void run_main(){")
  (emit-code "environ *env = setup_main_environment();"))
  
(define (c-end-main)
  (emit-code "}")
  (c-end-block))

(define (c-new-procedure args)
  (define proc_name (c-procname))
  (define var_name (c-tempname))
  (emit-code (sprintf 
              "object* ~a = new_proc_object(&~a, ~a, env);" 
              var_name proc_name (length args)))
  (c-new-block)
  ;; todo also emit a function definition somewhere
  (define params
    (c-params
     (cons "environ *parent_env"
           (map c-param-name args))))
  (emit-code (sprintf "object * ~a(~a) {"
                      proc_name params))
  (emit-code "environ* env = new_environment(parent_env);")
  var_name)

(define (c-end-procedure result)
  (emit-code (sprintf "return ~a;" result))
  (emit-code "}")
  (c-end-block))

(define *c_start* 
"#include <runtime.c>
void run_main();

int main(int argc, char** argv) {
  run_main();
  return 0;
}
")
(define *c_end* "\n")

(define (c-write-src-file filename)
  (cond ((not (null? *blocks*))
         (print *blocks*)
         (fatal-error "There is an unterminated block")))
  (define port (open-output-file filename))
  (display *c_start* port)
  
  (display (join *src* "\n") port) 

  (display *c_end* port)
  (close-output-port port))

