#lang racket/base

(require koyo/dispatch
         koyo/url
         koyo/cors
         koyo/static
         web-server/dispatch
         web-server/web-server
         web-server/servlet-dispatch
         (prefix-in sequencer: web-server/dispatchers/dispatch-sequencer)
         racket/list
         "models/blog-model.rkt"
         "my-blog.rkt")

;;; Dispatches
(define-values (dispatch url roles)
  (dispatch-rules+roles
   [("api" "get-posts")
    get-posts]
   [("api" "get-posts" (integer-arg))
    get-posts]
   [("api" "get-comments-by-post" (integer-arg))
    get-comments-by-post]

   [("api" "new-post")
    #:method "post"
    new-post]))


(current-cors-origin "*")

(define (stack handler)
  (wrap-cors handler))

(define dispatchers
  (list
   (dispatch/servlet (stack dispatch))
   (make-static-dispatcher "." "static")))

(define stop
  (serve
   #:dispatch (apply sequencer:make (filter-map values dispatchers))
   #:listen-ip #f
   #:port 80))

(with-handlers
  ([exn:break? (lambda (_) (stop))])
  (sync/enable-break never-evt))
