#lang racket/base

(require koyo/http
         koyo/json
         web-server/servlet
         web-server/http/redirect
         json
         racket/format
         racket/contract
         racket/math
         "tools/top-tools.rkt"
         "tools/web-tools.rkt"
         "models/blog-model.rkt")

(provide
 get-posts
 get-post
 get-comments-by-post

 new-post)

(define (page-name) "BLOG")

;;; INITIALIZE
(initialize-blog!)


(define/contract (get-posts req [page #f])
  (->* (request?)
       (nonnegative-integer?)
       response?)
  (define posts
    (cond
      [page
       (blog-posts-in-page blog-dbc page #:each 10)]
      [else
       (blog-posts blog-dbc)]))
  (response/json
   (for/list ([post posts])
     (hasheq 'id (post-stats-id post)
             'title (post-stats-title post)
             'created_at (datetime->normal-string (post-stats-created-at post))
             'updated_at (datetime->normal-string (post-stats-updated-at post))))))

(define (get-post req post-id)
  (define post (blog-post blog-dbc post-id))
  (response/json
   (hasheq 'title (post-title post)
           'body (post-body post))))


(define (get-comments-by-post req postid)
  (response/json
   (for/list ([comment (post-comments blog-dbc postid)])
     (hasheq 'content (comment-content comment)
             'pid (comment-pid comment)
             'created_at (comment-created-at comment)
             'updated_at (comment-updated-at comment)))))


(define (new-post req)
  (let* ([json (request-post-data/raw req)]
         [jsexpr (bytes->jsexpr json)]
         [title (hash-ref jsexpr 'title #f)]
         [body (hash-ref jsexpr 'body #f)])
    (cond
      [(and title body)
       (define post (blog-insert-post! blog-dbc title body))
       (response/json (hasheq 'status "ok"
                              'id (post-id post)))]
      [else
       (response/json (hasheq 'status "error"
                              'msg "parameter isn't correct"))])))
