(define *src* (list))
(define *blocks* (list))

(define (emit-code codes)
  (debug-log "EMIT: " codes)
  (if (not (list? codes))
      (set! codes (list codes)))
  (set! (car *blocks*) 
        (append (car *blocks*) codes)))

(define (c-new-block) 
  (set! *blocks* (cons (list) *blocks*)))
(define (c-end-block)
  (set! *src* (append *src* (car *blocks*)))
  (set! *blocks* (cdr *blocks*)))

(define _var-count 0)
(define (c-varname prefix)
  (set! _var-count (inc _var-count))
  (string-append prefix "_" (number->string _var-count)))

(define _proc-count 0)
(define (c-procname)
  (set! _proc-count (inc _proc-count))
  (string-append "proc_" (number->string _proc-count)))
  
(define (c-param-name arg)
  (set! _var-count (inc _var-count))
  (string-append 
   (c-ident arg) "_" (number->string _var-count)))
               
(define (c-param-names args)
  (map (lambda (x) (cons x (c-param-name x)))
       args))

(define (c-param-decl arg)
  (string-append "object* " (cdr arg)))

(define (c-escape s)
  ;; todo
  (sprintf "\"~a\"" s)
)

(define (c-ident s)
  ;; todo rm characters that cannot occur in idents
  (to-str s)
)


(define (c-param-list lst) (join lst ", "))

(define (c-gen-true) "(&true_object)")
(define (c-gen-false)"(&false_object)")
(define (c-gen-none) "(&none_object)")

(define (c-new-obj type value)
  (cond ((eq? T_TRUE value) (c-gen-true))
        ((eq? T_FALSE value) (c-gen-false))
        ((eq? T_NONE value) (c-gen-none))
        (else
         (define var_name (c-varname "v"))
         (emit-code (sprintf "object *~a = new_object(~a);" 
                             var_name type))
         (case type
           ((T_INT) 
            (emit-code (sprintf 
                        "~a->val.int_ = ~a;" 
                        var_name value)))
           ((T_SYMBOL)
            (emit-code (sprintf
                        "obj_set_sym_val(~a, ~a);"
                        var_name (c-escape value))))
           ((T_STRING) 
            (emit-code (sprintf 
                        "obj_set_str_val(~a, ~a);" 
                        var_name (c-escape value))))
           ((T_PAIR)
             (emit-code (sprintf 
                         "obj_set_pair_val(~a, ~a, ~a);"
                         var_name
                         (car value)
                         (cadr value))))
           (else (fatal-error "New object: unsupported type:" type)))
         var_name)))


(define (c-add-to-symbol-table symbol var)
  (emit-code (sprintf "add_to_environment(env, ~a, ~a);"
                      (c-escape symbol) var)))

(define (c-lookup-symbol-table symbol)
  (define var_name (c-varname "v"))
  (emit-code (sprintf "object *~a = lookup_sym(env, ~a);" 
                      var_name (c-escape symbol)))
  var_name)
             
(define (c-assign dest src)
  (emit-code (sprintf "copy_object(~a, ~a);" 
                      dest src)))
(define (c-dereference x)
  (string-append "*(" x ")"))

(define (c-call-function function args)
  (define res_name (c-varname "v"))
  (define sep ", ")
  (if (null? args) (set! sep ""))
  (emit-code (sprintf 
              "object *~a = call_procedure(~a, ~a~a ~a);"
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
  (define var_name (c-varname "v"))
  (emit-code (sprintf 
              "object *~a = new_proc_object(&~a, ~a, env);" 
              var_name proc_name (length args)))
  
  (define param-names (c-param-names args))
  (define params (map c-param-decl param-names))
  ;; start writing the function body definition
  (c-new-block)
  ;; todo also emit a function prototype somewhere
  (define param-list 
    (c-param-list
     (cons "environ *parent_env" params)))
  (emit-code (sprintf "object* ~a(~a) {"
                      proc_name param-list))
  (emit-code "environ *env = new_environment(parent_env);")
  
  (map (lambda (param)
         ;; objects must be copied into the new namespace
         (emit-code (sprintf "add_to_environment(env, ~a, new_object_from(~a));" 
                             (c-escape (car param))
                             (cdr param))))
       param-names)
  var_name)

(define (c-end-procedure result)
  (emit-code (sprintf "return ~a;" result))
  (emit-code "}")
  (c-end-block))

(define (c-if test)
  (define res_name (c-varname "if_res"))
  (emit-code (sprintf "object *~a;" res_name))
  (emit-code (sprintf "if (~a->type != T_FALSE) {" test))
  res_name)
(define (c-else res_name block_result)
  (emit-code (sprintf "~a = ~a;" res_name block_result))
  (emit-code "} else {"))
(define (c-endif res_name block_result)
  (emit-code (sprintf "~a = ~a;" res_name block_result))
  (emit-code "}"))

(define *c_start* 
"#include <runtime.h>
#include <builtin.h>
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


(define (c-compile filename)
  (define exec_filename (replace_ext! filename ""))
  (process-execute 
   "gcc"
   (list "-g" 
         "-Werror" 
         "-Wshadow" 
         "-std=c99" 
         "-Wall" 
         "-Wno-unused-variable" 
         "-Wno-error=unused-but-set-variable"
         "builtin.c" 
         "runtime.c"
         "base.c" 
         "-D_GNU_SOURCE" 
         ;"-v"
         "-I."  filename 
         "-o" exec_filename)))
