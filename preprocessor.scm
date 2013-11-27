(require 'util)
(define (preprocessor src) 
  (join (map preprocess src)))

(define (preprocess form)
  ;; TODO this only allows preprocessor directives at the top level
  (cond ((eq? (car form) 'require)
         (if (not (= (length form) 2))
             (fatal-error "require directive expected one argument, recieved:"
                          form))
         (expand-require (cadr form)))
         (else
          (list form))))
(define (expand-require name)
  (cond ((not (eq? (get-extension name) "scm"))
         (set! name (string-append name ".scm"))))
  ;; TODO handle errors more gracefully
  (read-scm-file name))
  
  
      
