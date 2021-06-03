#lang racket/base

(require web-server/servlet-env
         web-server/dispatch
         "models/blog-model.rkt"
         "pages/my-home.rkt"
         "pages/my-blog.rkt"
         "pages/my-songlist.rkt")


;;; Dispatches
(define-values (website-dispatch blog-url)
  (dispatch-rules
   ;; HOME
   [("") home-entry]
   ;; BLOG
   [("blog") (blog-entry blog-dbc)]
   ;; NEW BLOG POST
   [("blog" "post" "new") (new-blog-post blog-dbc)]
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
