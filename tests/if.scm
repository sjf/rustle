(print (if #t 111 222))
;> 111
(print (if #f 333 444))
;> 444
(if #t (print 11) (print 22))
;> 11
(if #f (print 33) (print 44))
;> 44
