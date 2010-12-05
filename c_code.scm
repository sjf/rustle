(define *code* (list))
(define (emit-code codes)
  (print "EMIT: " codes)
  (if (list? codes)
      (set! *code* (append *code* codes))
      (set! *code* (append *code* (list codes)))))

(define temp-count 0)
(define (c-tempname)
  (define var_name 
    (string-append "v_" (number->string temp-count)))
  (set! temp-count (+ temp-count 1))
  var_name)

(define (c-escape s)
  ;; todo
  (sprintf "\"~a\"" s)
)


(define (c-setup-symbol-table) 
  (emit-code "environ env;")
  (emit-code "setup_main_environment(&env);")
)

(define (c-new-obj type value)
  (define var_name (c-tempname))
  (emit-code (sprintf "object *~a = new_object(~a);" 
                      var_name type))

  (cond ((eq? type *t_string*) 
         (emit-code (sprintf 
                     "set_str_val(~a, ~a);" 
                     var_name (c-escape value))))
        ((eq? type *t_int*) 
         (emit-code (sprintf 
                     "~a->val.int_ = ~a;" 
                     var_name value))))
  var_name)


(define (c-add-to-symbol-table symbol var)
  (emit-code (sprintf "add_to_environment(&env, ~a, ~a);"
                      (c-escape symbol) var)))

(define (c-lookup-symbol-table symbol)
  (define var_name (c-tempname))
  (emit-code (sprintf "object *~a = lookup_sym(&env, ~a);" 
                      var_name (c-escape symbol)))
  var_name)
             
(define (c-assign dest src)
  (emit-code (sprintf "copy_obj(~a, ~a);" 
                      dest src)))

(define (c-call-function function args)
  (define res_name (c-tempname))
  (emit-code (sprintf "object* ~a = ~a(~a);" 
                      res_name
                      function
                      (join args ", ")))
  res_name)

  
