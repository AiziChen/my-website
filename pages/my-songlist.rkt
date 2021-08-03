#lang racket/base

(require koyo/haml
         "template.rkt")

(provide song-list)

(define (song-list req)
  (template "SONGS" "SONGS" '()))
