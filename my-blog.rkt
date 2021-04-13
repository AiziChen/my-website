#lang racket

(require web-server/servlet
         web-server/templates
         xml
         "top-tools.rkt"
         "web-tools.rkt"
         "model.rkt")

(provide blog-entry)

;;; INITIALIZE
(initialize-blog!)


(define (render-post a-blog a-post embed/url)
  (define (view-post-handler request)
    (render-post-detail-page a-blog a-post request))
  (include-template "templates/blog.post-item.html"))


(define navs
  (list
   (nav "主页" "/" #f)
   (nav "歌单" "/song-list" #f)
   (nav "博客" "/blog" #t)))


;; Entry Servlet For The Server
(define (blog-entry request)
  (render-blog-page get-new-blog-db request))


;; Render Blog Page
(define (render-blog-page a-blog request)
  (define (response-generator embed/url)
    (response/template (include-template "templates/blog.html")))
  
  (define (insert-post-handler request)
    (let* ([bindings (request-bindings request)]
           [title (extract-binding/single 'title bindings)]
           [body (extract-binding/single 'body bindings)])
      (cond
        [(and (valid-string? title)
              (valid-string? body))
         (blog-insert-post! a-blog title body)
         (render-blog-page a-blog (redirect/get))]
        [else
         (occur-error-page "Empty Blog"
                           "The blog title & body must be specifed."
                           (lambda (request)
                             (render-blog-page a-blog (redirect/get)))
                           request)])))
  
  (send/suspend/dispatch response-generator))


;; Render Post Details
(define (render-post-detail-page a-blog a-post request)
  (define (response-generator embed/url)
    (response/template (include-template "templates/post-detail.html")))
  
  (define (insert-comment-handler request)
    (let* ([bindings (request-bindings request)]
           [comment (extract-binding/single 'comment bindings)])
      (cond
        [(valid-string? comment)
         (render-confirm-add-comment-page a-blog
					  comment
					  a-post
					  request)]
        [else
         (occur-error-page "Empty Comment"
                           "You should specify the comment content."
                           (lambda (request)
                             (render-post-detail-page a-blog a-post (redirect/get)))
                           request)])))
  
  (define (goback-handler request)
    (render-blog-page a-blog (redirect/get)))
  
  (send/suspend/dispatch response-generator))


;; Blog Comment Add Confirm
(define (render-confirm-add-comment-page a-blog a-comment a-post request)
  (define (response-generator embed/url)
    (response/template (include-template "templates/confirm-add-comment.html")))
  
  (define (yes-handler request)
    (post-insert-comment! a-blog a-post a-comment)
    (render-post-detail-page a-blog a-post (redirect/get)))
  
  (define (cancel-handler request)
    (render-post-detail-page a-blog a-post (redirect/get)))
  
  (send/suspend/dispatch response-generator))

;;; Error Ocurred Page
(define (occur-error-page title message p request)
  (define (response-generator embed/url)
    (response/template (include-template "templates/error.html")))
  
  (define (back-handler request) (p request))
  
  (send/suspend/dispatch response-generator))

