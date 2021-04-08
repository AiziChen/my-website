#lang racket

(require web-server/servlet-env
	 web-server/dispatch
	 "my-blog.rkt")


;;; Dispatches
(define-values (website-dispatch blog-url)
  (dispatch-rules
   ;; BLOG
   [("") (lambda (req)
	   (blog-entry req))]))


;; Setup The Servlet
(serve/servlet website-dispatch
               #:launch-browser? #f
               #:listen-ip #f
               #:port 80
               #:quit? #f
               #:servlet-path "/"
               #:extra-files-paths (list (build-path "htdocs"))
               #:command-line? #t
               #:ssl? #f
               #:stateless? #f)
