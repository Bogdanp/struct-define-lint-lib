#lang racket/base

(require review/ext
         syntax/parse/pre)

#|review: ignore|#

(provide
 should-review-syntax?
 review-syntax)

(define (should-review-syntax? stx)
  (syntax-case stx (struct-define)
    [(struct-define . _rest) #t]
    [_ #f]))

(define-syntax-class struct-define-use
  #:datum-literals (struct-define)
  (pattern (struct-define struct-id:id e:expression)
           #:do [(track-struct-usage #'struct-id)]))

(define (review-syntax stx)
  (syntax-parse stx
    [d:struct-define-use #'d]
    [_ (track-error stx "expected a deta schema or type definition")]))
