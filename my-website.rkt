#lang racket

(require web-server/servlet
         web-server/servlet-env)

(define main-style-sheet
  `(link ([rel "stylesheet"]
          [href "/main.css"]
          [type "text/css"])))

(struct blog (posts) #:mutable)
(struct post (title body [comments #:mutable]))

(define BLOG
  (blog
   (list (post "Second Post!" "This is another post!" (list))
         (post "First Post!" "Hey, this is my first post!" (list)))))

(define (blog-insert-post! a-blog a-post)
  (set-blog-posts! a-blog (cons a-post (blog-posts a-blog))))
(define (post-insert-comment! a-post a-comment)
  (set-post-comments! a-post (cons a-comment (post-comments a-post))))

(define (render-as-itemized-list l)
  `(ul ,@(map (lambda (e) `(li ,e)) l)))

(define (render-post a-post embed/url)
  (define (view-post-handler request)
    (render-post-detail-page a-post request))
  `(div ([class "post"])
        (a ([method "post"]
            [href ,(embed/url view-post-handler)])
           ,(post-title a-post))
        (p ,(post-body a-post))
        (div ,(number->string (length (post-comments a-post)))
             " comment(s)")))

(define (render-posts embed/url)
  `(div ([class "posts"]) ,@(map (lambda (a-post)
                                   (render-post a-post embed/url))
                                 (blog-posts BLOG))))

;; Entry Servlet For The Server
(define (start request)
  (render-blog-page request))

(define (can-parse-post? bindings)
  (and (exists-binding? 'title bindings)
       (exists-binding? 'body bindings)))

(define (parse-post bindings)
  (post (extract-binding/single 'title bindings)
        (extract-binding/single 'body bindings)
        (list)))

(define (render-blog-page request)
  (define (response-generator embed/url)
    (response/xexpr
     `(html (head (title "My Blog") ,main-style-sheet)
            (body (h1 "My Blog")
                  ,(render-posts embed/url)
                  (br)
                  (h4 "New Post Here:")
                  (form ([action ,(embed/url insert-post-handler)]
                         [method "post"])
                        (input ([name "title"] [placeholder "title"]))(br)
                        (input ([name "body"] [placeholder "content"]))(br)
                        (input ([type "submit"] [value "Submit"])))))))
  (define (insert-post-handler request)
    (blog-insert-post! BLOG (parse-post (request-bindings request)))
    (render-blog-page request))
  (send/suspend/dispatch response-generator))

(define (render-post-detail-page a-post request)
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
                   (input ([name "comment"]))
                   (input ([type "submit"] [value "Submit"])))
             (br)
             (a ([href ,(embed/url goback-handler)])
                "Back")))))
  (define (insert-comment-handler request)
    (render-confirm-add-comment-page (parse-comment (request-bindings request))
                                     a-post
                                     request))
  (define (goback-handler request)
    (render-blog-page request))
  (send/suspend/dispatch response-generator))

(define (render-confirm-add-comment-page a-comment a-post request)
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
                    [href ,(embed/url no-handler)])
                   "No, I changed my mind."))))))
  (define (yes-handler request)
    (post-insert-comment! a-post a-comment)
    (render-post-detail-page a-post request))
  (define (no-handler request)
    (render-post-detail-page a-post request))
  (send/suspend/dispatch response-generator))

(define (parse-comment binding)
  (extract-binding/single 'comment binding))

;; entry the servlet
(serve/servlet start
               #:listen-ip #f
               #:extra-files-paths (list (build-path "htdocs")))