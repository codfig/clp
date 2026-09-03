#lang racket

(define (somar l)
  (if (null? l)
      0
      (+ (car l) (somar (cdr l)))))
