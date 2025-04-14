#lang info

(define license 'BSD-3-Clause)
(define collection "struct-define")
(define deps
  '("base"
    ["review" #:version "0.2"]))
(define review-exts
  '((struct-define/review should-review-syntax? review-syntax)))
