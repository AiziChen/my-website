#lang racket/base

(require koyo/http
         koyo/json
         web-server/servlet
         web-server/http/redirect
         json
         racket/format
         "tools/top-tools.rkt"
         "tools/web-tools.rkt"
         "models/blog-model.rkt")

(provide
 get-posts
 get-comments-by-post

 new-post)

(define (page-name) "BLOG")

;;; INITIALIZE
(initialize-blog!)


(define (get-posts req [page #f])
  (define posts
    (cond
      [page
       (blog-posts-in-page blog-dbc page #:each 10)]
      [else
       (blog-posts blog-dbc)]))
  (response/json
   (for/list ([post posts])
     (hasheq 'id (post-id post)
             'title (post-title post)
             'body (post-body post)
             'created_at (datetime->normal-string (post-created-at post))
             'updated_at (datetime->normal-string (post-updated-at post))))))


(define (get-comments-by-post req postid)
  (response/json
   (for/list ([comment (post-comments blog-dbc postid)])
     (hasheq 'content (comment-content comment)))))


(define (new-post req)
  (let* ([json (request-post-data/raw req)]
         [jsexpr (bytes->jsexpr json)]
         [title (hash-ref jsexpr 'title #f)]
         [body (hash-ref jsexpr 'body #f)])
    (cond
      [(and title body)
       (blog-insert-post! blog-dbc title body)
       (response/json (hasheq 'status "ok"))]
      [else
       (response/json (hasheq 'status "error"
                              'msg "parameter isn't correct"))])))
