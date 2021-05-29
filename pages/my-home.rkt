#lang racket/base

(require koyo/haml
         "template.rkt"
         "../tools/web-tools.rkt")

(provide home-entry)


(define (home-entry req)
  (render-home-page req))


(define (render-home-page req)
  (template "Home"
            (list (nav "HOME" "/" #t)
                  (nav "SONGS" "/song-list" #f)
                  (nav "BLOG" "/blog" #f))
            (haml
             (:pre "生理学、编程、自由、平等")
             (:div "[爱，是什么]")
             (:div "[程序项目]")
             (:div "[生理学研究]")
             (:div "[机器与生命]")
             (:div "[好物推荐]")
             (:div "[Quanye的世界观]")
             (:div "[正确教育]")
             (:div "Powered by Quanye Chen"))))
