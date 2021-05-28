#lang racket/base

(require koyo/haml
         "template.rkt"
         "../tools/web-tools.rkt")

(provide song-list)

(define (song-list req)
  (template "歌单"
            (list (nav "主页" "/" #f)
                  (nav "歌单" "/song-list" #t)
                  (nav "博客" "/blog" #f))
            '()))