#lang racket/base

(require koyo/dispatch
         koyo/url
         koyo/cors
;         web-server/servlet-env
         web-server/dispatch
         web-server/web-server
         web-server/servlet-dispatch
         (prefix-in sequencer: web-server/dispatchers/dispatch-sequencer)
         racket/list
         "models/blog-model.rkt"
         "my-blog.rkt")

(current-cors-origin "*")

;;; Dispatches
(define-values (website-dispatch blog-url req-roles)
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


(define (stack handler)
  (wrap-cors handler))

(define dispatchers
  (list
   (dispatch/servlet (stack website-dispatch))))

(define stop
  (serve
   #:dispatch (apply sequencer:make (filter-map values dispatchers))
   #:listen-ip #f
   #:port 80))

(with-handlers
  ([exn:break? (lambda (_) (stop))])
  (sync/enable-break never-evt))
