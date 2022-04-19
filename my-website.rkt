#lang racket/base

(require koyo/dispatch
         koyo/url
         koyo/cors
         koyo/static
         web-server/dispatch
         web-server/web-server
         web-server/servlet-dispatch
         web-server/http/json
         (prefix-in sequencer: web-server/dispatchers/dispatch-sequencer)
         racket/list
         "models/blog-model.rkt"
         "my-blog.rkt"
         "my-drive.rkt")

;;; Dispatches
(define-values (dispatch url roles)
  (dispatch-rules+roles
   [("") (lambda (_) (response/jsexpr "server is on."))]
   [("api" "get-posts")
    get-posts]
   [("api" "get-posts" (integer-arg))
    get-posts]
   [("api" "get-post" (integer-arg))
    get-post]
   [("api" "get-comments-by-post" (integer-arg))
    get-comments-by-post]

   [("api" "new-post")
    #:method "post"
    new-post]

   [("api" "get-drive-list")
    show-drive-list]))


(current-cors-origin "*")

(define (stack handler)
  (wrap-cors handler))

(define dispatchers
  (list
   (dispatch/servlet (stack dispatch))
   (make-static-dispatcher "static")))

(define stop
  (serve
   #:dispatch (apply sequencer:make (filter-map values dispatchers))
   #:listen-ip #f
   #:port 8081))

(with-handlers
  ([exn:break? (lambda (_) (stop))])
  (sync/enable-break never-evt))
