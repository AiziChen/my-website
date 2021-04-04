#lang racket

(require web-server/servlet
         web-server/servlet-env
         web-server/formlets
         web-server/templates
         xml
	 "top-tools.rkt"
 	 "web-tools.rkt"
         "model.rkt")

(provide/contract (start (request? . -> . response?)))

;;; VARS
(define top-style-sheet
  `(link ([rel "stylesheet"]
          [href "/top.css"]
          [type "text/css"])))

;;; INITIALIZE
(initialize-blog!)


(define (render-post a-blog a-post embed/url)
  (define (view-post-handler request)
    (render-post-detail-page a-blog a-post request))
  (include-template "templates/blog.post-item.html"))


;; Entry Servlet For The Server
(define (start request)
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
       [(or (empty-string? title)
	    (empty-string? body))
	(occur-error-page "Empty Blog"
			  "The blog title & body must be specifed."
			  (lambda (request)
			    (render-blog-page a-blog (redirect/get)))
			  request)]
       [else
	(blog-insert-post! a-blog title body)
	(render-blog-page a-blog (redirect/get))])))
  
  (send/suspend/dispatch response-generator))


;; Render Post Details
(define (render-post-detail-page a-blog a-post request)
  (define (response-generator embed/url)
    (response/template (include-template "templates/post-detail.html")))
  
  (define (insert-comment-handler request)
    (let* ([bindings (request-bindings request)]
           [comment (extract-binding/single 'comment bindings)])
      (cond
       [(empty-string? comment)
	(occur-error-page "Empty Comment"
			  "You should specify the comment content."
			  (lambda (request)
			    (render-post-detail-page a-blog a-post (redirect/get)))
			  request)]
       [else
	(render-confirm-add-comment-page
	      a-blog
	      comment
	      a-post
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
