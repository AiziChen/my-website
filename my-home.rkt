#lang racket

(require web-server/servlet
         web-server/templates
         xml
         "top-tools.rkt"
         "web-tools.rkt"
         "model.rkt")

(provide home-entry)


(define (home-entry req)
  (render-home-page req))


(define (render-home-page req)
  (let ([navs (list
	       (nav "主页" "/" #t)
	       (nav "歌单" "/song-list" #f)
	       (nav "博客" "/blog" #f))])
    (response/template (include-template "templates/home.html"))))
