#lang racket/base

(require koyo/haml
         "template.rkt"
         "../tools/web-tools.rkt")

(provide song-list)

(define navs
  (list (nav "HOME" "/" #f)
        (nav "SONGS" "/song-list" #t)
        (nav "BLOG" "/blog" #f)))

(define (song-list req)
  (template "SONGS"
            navs
            '()))