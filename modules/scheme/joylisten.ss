;; [ Copyright (C) 2008 Dave Griffiths : GPLv2 see LICENCE ]

#lang scheme/base
(require scheme/class)
(require fluxus-015/fluxus)

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; joystick input listener

(provide joylisten%)

(define joylisten%
  (class object%
    
    (field
     (buttons (make-buttons 16 '()))
     (axes (make-axes 16 '()))
     (button-state (make-buttons 16 '())))
    
    (define (list-set l n v)
      (cond
        ((null? l) '())
        ((zero? n) (cons v (cdr l)))
        (else (cons (car l) (list-set (cdr l) (- n 1) v)))))
    
    (define/public (make-axes n l)
      (if (zero? n)
          l
          (make-axes (- n 1) (cons (make-vector 2 0) l))))
    
    (define/public (make-buttons n l)
      (if (zero? n)
          l
          (make-buttons (- n 1) (cons 0 l))))
    
    (define/public (get-button n)
      (list-ref buttons n))
    
    (define (button-changed n)
      (list-ref button-state n))
    
    (define/public (get-axis n)
      (list-ref axes n))
    
    (define (set-button! n s)
      (set! buttons (list-set buttons n s)))
    
    (define/public (update)
      (define (drain path value)       ; drains all osc events for a message and 
        (if (osc-msg path)             ; only reports the last one which is ok for
            (drain path (osc 0))       ; this sort of control
            value))
      
      (define (do-axes n)
        (let ((value (drain (string-append "/oscjoy.0.axis." (number->string n)) #f)))
          (cond
            ((number? value)
             ; do some mangling of values here,
             ; firstly, make 0=x 1=y and secondly,
             ; change the range from 0 to 1 to -1 to 1
             (vector-set! (get-axis (inexact->exact (truncate (/ n 2))))
                          (- 1 (modulo n 2)) (* 2 (- value 0.5))))))
        (if (zero? n)
            0
            (do-axes (- n 1))))
      
      (define (do-buttons n)
        (let ((value (drain (string-append "/oscjoy.0.button." (number->string n)) #f)))
          (cond 
            ((number? value)
             ; have we changed?
             (if (not (eq? (get-button n) value))
                 (set! button-state (list-set button-state n #t))
                 (set! button-state (list-set button-state n #f)))
             (set-button! n value))))
        (if (zero? n)
            0
            (do-buttons (- n 1))))
      
      ;(display (osc-peek)) (newline)
      
      (do-axes 16)
      (do-buttons 16))
    
    (super-new)))