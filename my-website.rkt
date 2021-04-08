#lang racket

(require web-server/servlet-env
	 web-server/dispatch
	 web-server/configuration/responders
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
	       #:file-not-found-responder
	       (gen-file-not-found-responder
		(build-path "templates/not-found.html"))
               #:ssl? #f
               #:stateless? #f)
