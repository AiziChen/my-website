#lang racket

(require web-server/servlet
         web-server/servlet-env
         web-server/formlets
         web-server/templates
         xml
         "model.rkt"
         "web-tools.rkt")

(provide/contract (start (request? . -> . response?)))

;;; VARS
(define top-style-sheet
  `(link ([rel "stylesheet"]
          [href "/top.css"]
          [type "text/css"])))

;;; INITIALIZE
(initialize-blog!)


(define (render-as-itemized-list l)
  `(ul ,@(map (lambda (e) `(li ,e)) l)))


(define (render-post a-blog a-post embed/url)
  (define (view-post-handler request)
    (render-post-detail-page a-blog a-post request))
  (include-template "templates/blog.post-item.html"))


;; Entry Servlet For The Server
(define (start request)
  (render-blog-page get-new-blog-db request))

#;
(define (can-parse-post? bindings)
  (and (exists-binding? 'title bindings)
       (exists-binding? 'body bindings)))


;; Render Blog Page
(define (render-blog-page a-blog request)
  (define (response-generator embed/url)
    (response/template (include-template "templates/blog.html")))
  
  (define (insert-post-handler request)
    (let* ([bindings (request-bindings request)]
           [title (extract-binding/single 'title bindings)]
           [body (extract-binding/single 'body bindings)])
      (blog-insert-post! a-blog title body)
      (render-blog-page a-blog (redirect/get))))
  
  (send/suspend/dispatch response-generator))


;; Render Post Details
(define (render-post-detail-page a-blog a-post request)
  (define (response-generator embed/url)
    (response/template (include-template "templates/post-detail.html")))
  
  (define (insert-comment-handler request)
    (let* ([bindings (request-bindings request)]
           [comment (extract-binding/single 'comment bindings)])
      (render-confirm-add-comment-page
       a-blog
       comment
       a-post
       request)))
  
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


;; Setup The Servlet
(serve/servlet start
               #:launch-browser? #f
               #:listen-ip #f
               #:port 80
               #:quit? #f
               #:servlet-path "/"
               #:extra-files-paths (list (build-path "htdocs"))
               #:command-line? #t
	       #:ssl? #f
	       #:stateless? #f)
