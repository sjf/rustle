(require "testing")

;(SECTION 6 6)
;(test #t eqv? '#\  #\Space)
;(test #t eqv? #\space '#\Space)
(test #t (char? #\a))
(test #t (char? #\())
(test #t (char? #\'))
(test #t (char? #\space))
(test #t (char? '#\newline))

;; (test #f char=? #\A #\B)
;; (test #f char=? #\a #\b)
;; (test #f char=? #\9 #\0)
;; (test #t char=? #\A #\A)

;; (test #t char<? #\A #\B)
;; (test #t char<? #\a #\b)
;; (test #f char<? #\9 #\0)
;; (test #f char<? #\A #\A)

;; (test #f char>? #\A #\B)
;; (test #f char>? #\a #\b)
;; (test #t char>? #\9 #\0)
;; (test #f char>? #\A #\A)

;; (test #t char<=? #\A #\B)
;; (test #t char<=? #\a #\b)
;; (test #f char<=? #\9 #\0)
;; (test #t char<=? #\A #\A)

;; (test #f char>=? #\A #\B)
;; (test #f char>=? #\a #\b)
;; (test #t char>=? #\9 #\0)
;; (test #t char>=? #\A #\A)

;; (test #f char-ci=? #\A #\B)
;; (test #f char-ci=? #\a #\B)
;; (test #f char-ci=? #\A #\b)
;; (test #f char-ci=? #\a #\b)
;; (test #f char-ci=? #\9 #\0)
;; (test #t char-ci=? #\A #\A)
;; (test #t char-ci=? #\A #\a)

;; (test #t char-ci<? #\A #\B)
;; (test #t char-ci<? #\a #\B)
;; (test #t char-ci<? #\A #\b)
;; (test #t char-ci<? #\a #\b)
;; (test #f char-ci<? #\9 #\0)
;; (test #f char-ci<? #\A #\A)
;; (test #f char-ci<? #\A #\a)

;; (test #f char-ci>? #\A #\B)
;; (test #f char-ci>? #\a #\B)
;; (test #f char-ci>? #\A #\b)
;; (test #f char-ci>? #\a #\b)
;; (test #t char-ci>? #\9 #\0)
;; (test #f char-ci>? #\A #\A)
;; (test #f char-ci>? #\A #\a)

;; (test #t char-ci<=? #\A #\B)
;; (test #t char-ci<=? #\a #\B)
;; (test #t char-ci<=? #\A #\b)
;; (test #t char-ci<=? #\a #\b)
;; (test #f char-ci<=? #\9 #\0)
;; (test #t char-ci<=? #\A #\A)
;; (test #t char-ci<=? #\A #\a)

;; (test #f char-ci>=? #\A #\B)
;; (test #f char-ci>=? #\a #\B)
;; (test #f char-ci>=? #\A #\b)
;; (test #f char-ci>=? #\a #\b)
;; (test #t char-ci>=? #\9 #\0)
;; (test #t char-ci>=? #\A #\A)
;; (test #t char-ci>=? #\A #\a)

;; (test #t char-alphabetic? #\a)
;; (test #t char-alphabetic? #\A)
;; (test #t char-alphabetic? #\z)
;; (test #t char-alphabetic? #\Z)
;; (test #f char-alphabetic? #\0)
;; (test #f char-alphabetic? #\9)
;; (test #f char-alphabetic? #\space)
;; (test #f char-alphabetic? #\;)

;; (test #f char-numeric? #\a)
;; (test #f char-numeric? #\A)
;; (test #f char-numeric? #\z)
;; (test #f char-numeric? #\Z)
;; (test #t char-numeric? #\0)
;; (test #t char-numeric? #\9)
;; (test #f char-numeric? #\space)
;; (test #f char-numeric? #\;)

;; (test #f char-whitespace? #\a)
;; (test #f char-whitespace? #\A)
;; (test #f char-whitespace? #\z)
;; (test #f char-whitespace? #\Z)
;; (test #f char-whitespace? #\0)
;; (test #f char-whitespace? #\9)
;; (test #t char-whitespace? #\space)
;; (test #f char-whitespace? #\;)

;; (test #f char-upper-case? #\0)
;; (test #f char-upper-case? #\9)
;; (test #f char-upper-case? #\space)
;; (test #f char-upper-case? #\;)

;; (test #f char-lower-case? #\0)
;; (test #f char-lower-case? #\9)
;; (test #f char-lower-case? #\space)
;; (test #f char-lower-case? #\;)

;; (test #\. integer->char (char->integer #\.))
;; (test #\A integer->char (char->integer #\A))
;; (test #\a integer->char (char->integer #\a))
;; (test #\A char-upcase #\A)
;; (test #\A char-upcase #\a)
;; (test #\a char-downcase #\A)
;; (test #\a char-downcase #\a)
