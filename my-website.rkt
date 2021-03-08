#lang racket

(require web-server/servlet
         web-server/servlet-env
         web-server/formlets
         "model.rkt")

(provide/contract (start (request? . -> . response?)))


(define main-style-sheet
  `(link ([rel "stylesheet"]
          [href "/main.css"]
          [type "text/css"])))


(define (render-as-itemized-list l)
  `(ul ,@(map (lambda (e) `(li ,e)) l)))


(define (render-post a-blog a-post embed/url)
  (define (view-post-handler request)
    (render-post-detail-page a-blog a-post request))
  `(div ([class "post"])
        (a ([method "post"]
            [href ,(embed/url view-post-handler)])
           ,(post-title a-post))
        (p ,(post-body a-post))
        (div ,(number->string (length (post-comments a-post)))
             " comment(s)")))

(define (render-posts a-blog embed/url)
  `(div ([class "posts"])
        ,@(map (lambda (a-post)
                 (render-post a-blog a-post embed/url))
               (blog-posts a-blog))))


;; Entry Servlet For The Server
(define (start request)
  (render-blog-page
   (initialize-blog! (build-path (current-directory) "the-blog-data.db"))
   request))


(define (can-parse-post? bindings)
  (and (exists-binding? 'title bindings)
       (exists-binding? 'body bindings)))


;; Render Blog Page
(define (render-blog-page a-blog request)
  (define (response-generator embed/url)
    (response/xexpr
     `(html (head (title "My Blog") ,main-style-sheet)
            (body (h1 "My Blog")
                  ,(render-posts a-blog embed/url)
                  (br)
                  (h4 "New Post Here:")
                  (form ([action ,(embed/url insert-post-handler)]
                         [method "post"])
                        ,@(formlet-display new-post-formlet)
                        (input ([type "submit"] [value "Submit"])))))))
  
  (define new-post-formlet
    (formlet
     (#%# ,((to-string
             (required
              (text-input
               #:attributes '([class "form-text"]
                              [placeholder "title"]))))
            . => . title)
          ,((to-string
             (required
              (text-input
               #:attributes '([class "form-text"]
                              [placeholder "content"]))))
            . => . body))
     (values title body)))
  
  (define (insert-post-handler request)
    (define-values (title body)
      (formlet-process new-post-formlet request))
    (blog-insert-post! a-blog title body)
    (render-blog-page a-blog (redirect/get)))
  
  (send/suspend/dispatch response-generator))


;; Render Post Details
(define (render-post-detail-page a-blog a-post request)
  (define (response-generator embed/url)
    (response/xexpr
     `(html (head (title "Post Details") ,main-style-sheet)
            (body
             (h1 "Post Details")
             (h2 ,(post-title a-post))
             (p ,(post-body a-post))
             ,(render-as-itemized-list (post-comments a-post))
             (form ([method "post"]
                    [action ,(embed/url insert-comment-handler)])
                   ,@(formlet-display new-comment-formlet)
                   (input ([type "submit"] [value "Submit"])))
             (br)
             (a ([href ,(embed/url goback-handler)])
                "Back")))))
  
  (define new-comment-formlet
    (formlet
     (#%# ,(input-string . => . comment))
     (values comment)))
  
  (define (insert-comment-handler request)
    (render-confirm-add-comment-page
     a-blog
     (formlet-process new-comment-formlet request)
     a-post
     request))
  
  (define (goback-handler request)
    (render-blog-page a-blog (redirect/get)))
  
  (send/suspend/dispatch response-generator))


;; Blog Comment Add Confirm
(define (render-confirm-add-comment-page a-blog a-comment a-post request)
  (define (response-generator embed/url)
    (response/xexpr
     `(html (head (title "Add a Comment") ,main-style-sheet)
            (body
             (h1 "Add a Comment")
             "The comment: " (div (p ,a-comment))
             "will be added to "
             (div ,(post-title a-post))
             (p (a ([method "post"]
                    [href ,(embed/url yes-handler)])
                   "Yes, add the comment."))
             (p (a ([method "post"]
                    [href ,(embed/url cancel-handler)])
                   "No, I changed my mind."))))))
  
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
	       #:ssl? #f)
