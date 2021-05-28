#lang racket/base

(require web-server/servlet-env
         web-server/dispatch
         web-server/configuration/responders
         "pages/my-home.rkt"
         "pages/my-blog.rkt"
         "pages/my-songlist.rkt")


;;; Dispatches
(define-values (website-dispatch blog-url)
  (dispatch-rules
   ;; HOME
   [("") home-entry]
   ;; BLOG
   [("blog") blog-entry]
   ;; SONG LIST
   [("song-list") song-list]))


;; Setup The Servlet
(serve/servlet website-dispatch
               #:command-line? #t
               #:listen-ip #f
               #:port 80
               #:servlet-path "/"
               #:servlet-regexp #rx""
               #:extra-files-paths (list (build-path "htdocs"))
               #:ssl? #f
               #:stateless? #f
               #:log-file "my-website.log")
