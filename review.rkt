#lang racket/base

(require review/ext
         syntax/parse/pre)

#|review: ignore|#

(provide
 should-review-syntax?
 review-syntax)

(define struct-definers
  (make-hasheq))

(define (track-definer! id-stx struct-id-stx)
  (hash-set! struct-definers (syntax->datum id-stx) struct-id-stx))

(define (definer-id? id-stx)
  (hash-has-key? struct-definers (syntax->datum id-stx)))

(define (definer-ref id-stx)
  (hash-ref struct-definers (syntax->datum id-stx)))

(define (should-review-syntax? stx)
  (syntax-parse stx
    [({~datum define-struct-define} . _rest) #t]
    [({~datum struct-define} . _rest) #t]
    [(id _e) #:when (definer-id? #'id) #t]
    [_ #f]))

(define-syntax-class define-struct-define-use
  #:datum-literals (define-struct-define)
  (pattern (define-struct-define definer-id:id struct-id:id)
           #:do [(track-definer! #'definer-id #'struct-id)]))

(define-syntax-class definer-use
  (pattern (id e:expression)
           #:when (definer-id? #'id)
           #:do [(track-struct-usage (definer-ref #'id))]))

(define-syntax-class struct-define-use
  #:datum-literals (struct-define)
  (pattern (struct-define struct-id:id e:expression)
           #:do [(track-struct-usage #'struct-id)]))

(define (review-syntax stx)
  (syntax-parse stx
    [D:define-struct-define-use #'D]
    [d:struct-define-use #'d]
    [u:definer-use #'u]
    [_ (track-error stx "expected a struct-define form")]))
