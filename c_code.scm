(define *src* (list))
(define *blocks* (list))

(define (emit-code src . rest)
  (define codes (string-join (cons src rest) ""))
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
(define (c-escape-char c)
  (define escaped (cond ((eq? #\' c) "\\'")
                        ((eq? #\return c) "\\r")
                        ((eq? #\newline c) "\\n")
                        (else c)))
  (sprintf "'~a'" escaped))

(define (c-ident s)
  ;; todo rm characters that cannot occur in idents
  (to-str s))

(define (c-param-list lst) (string-join lst ", "))

(define (c-gen-true)  "(&true_object)")
(define (c-gen-false) "(&false_object)")
(define (c-gen-none)  "(&none_object)")

(define (c-new-obj type value)
  (cond ((eq? T_TRUE  type) "(&true_object)")
        ((eq? T_FALSE type) "(&false_object)")
        ((eq? T_NONE  type) "(&none_object)")
        ((eq? T_NULL  type) "(&null_object)")
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
           ((T_CHAR)
            (emit-code (sprintf
                        "~a->val.chr = ~a;"
                        var_name (c-escape-char value))))
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
                      (c-escape symbol) var))
  var)

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
  (define env-name (c-varname "env"))
  (define result (c-varname "v"))
  (emit-code (sprintf "object *~a;" result))
  ;; Set up argument list
  (define arg-list (c-varname "args"))
  (emit-code (sprintf "object **~a = malloc(sizeof(object *) * ~a);" arg-list (length args)))
  (emit-code (sprintf "bzero(~a, sizeof(object *) * ~a);" arg-list (length args)))
  (let loop ((args args)
             (n 0))
    (cond ((not (null? args))
           (emit-code (sprintf "~a[~a] = ~a;" arg-list n (car args)))
           (loop (cdr args) (inc n)))))
  (emit-code (sprintf "~a = call_proc(~a, env, ~a, ~a);"
                      result function arg-list (length args)))
  result)

(define (c-main)
  (c-new-block)
  (emit-code "void run_main(){")
  (emit-code "environ *env = setup_main_environment();"))

(define (c-end-main)
  (emit-code "}")
  (c-end-block))

(define (c-new-procedure args optional)
  (define proc_name (c-procname))
  (define result_var (c-varname "v"))
  (define has_optionals (if optional "1" "0"))
  (emit-code (sprintf
              "object *~a = new_proc_object(&~a, ~a, ~a, env);"
              result_var proc_name (length args) has_optionals))
  ;; start writing the function body definition in a new block
  (c-new-block)
  (emit-code (sprintf "object* ~a(environ *env, object **args, int arglen) {" proc_name))
  ;; Add arguments to the function's environment
  (let loop ((n 0)
             (args args))
    (cond ((not (null? args))
           (emit-code (sprintf
                       "add_to_environment(env, \"~a\", args[~a]);" (car args) n))
           (loop (inc n) (cdr args)))))
  ;; Construct a list containing the optional arguments
  (cond (optional
          (define optional-list (c-varname (symbol->string optional)))
          (emit-code (sprintf "object *~a = &null_object;" optional-list))
          (emit-code (sprintf "for (int i = arglen - 1; i >= ~a; i--) {" (length args)))
          (emit-code (sprintf "  ~a = __cons(args[i], ~a);" optional-list optional-list))
          (emit-code (sprintf "}"))
          (emit-code (sprintf "add_to_environment(env, \"~a\", ~a);" optional optional-list))))
  result_var)

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
#include <base.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <search.h>
#include <errno.h>

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

  (display (string-join *src* "\n") port)

  (display *c_end* port)
  (close-output-port port))

(define (c-compile filename)
  (define exec_filename (replace-ext filename ""))
  (let ((exec "gcc")
        (args (list "-g"
                    "-Werror"
                    "-Wshadow"
                    "-std=c99"
                    "-Wall"
                    "-Wno-unused-variable"
                    "-Wno-error=unused-but-set-variable"
                    "-D_GNU_SOURCE"
                    ;"-v"
                    "-I."
                    filename
                    "-L." "-lruntime"
                    "-o" exec_filename)))
    (debug-log "Calling:\n" (string-join (cons exec args) " "))
    (process-execute exec args)))
