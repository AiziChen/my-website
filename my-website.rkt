#lang racket

(require web-server/servlet-env
	 web-server/dispatch
	 web-server/configuration/responders
	 "my-home.rkt"
	 "my-blog.rkt")


;;; Dispatches
(define-values (website-dispatch blog-url)
  (dispatch-rules
   ;; BLOG
   [("")
    (lambda (req)
      (home-entry req))]
   [("blog")
    (lambda (req)
      (blog-entry req))]))


;; Setup The Servlet
(serve/servlet website-dispatch
               #:command-line? #t
               #:listen-ip #f
               #:port 80
               #:servlet-path "/"
	       #:servlet-regexp #rx""
               #:extra-files-paths (list (build-path "htdocs"))
	       #:file-not-found-responder
	       (gen-file-not-found-responder
		(build-path "templates/not-found.html"))
               #:ssl? #f
               #:stateless? #f
	       #:log-file "my-website.log")
