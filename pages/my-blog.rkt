#lang racket/base

(require web-server/servlet
         koyo/haml
         "template.rkt"
         "../tools/top-tools.rkt"
         "../tools/web-tools.rkt"
         "../models/blog-model.rkt")

(provide blog-entry
         new-blog-post)

;;; INITIALIZE
(initialize-blog!)


(define navs
  (list
   (nav "HOME" "/" #f)
   (nav "SONGS" "/song-list" #f)
   (nav "BLOG" "/blog" #t)))


;; Entry Servlet For The Server
(define (blog-entry request)
  (render-blog-page get-new-blog-db request))

;; Render Blog Page
(define (render-blog-page a-blog request)
  (define (render-post a-blog a-post embed/url)
    (define (view-post-handler request)
      (render-post-detail-page a-blog a-post request))
    (haml
     (:a.post.list-group-item.list-group-item-action
      ([:href (embed/url view-post-handler)])
      (.post-link
       (post-title a-blog a-post))
      (.post-comment-sum
       (let ([len (post-comments-count a-blog a-post)])
         (post-created-at a-blog a-post))))))
  
  (define (response-generator embed/url)
    (template "BLOG" navs
              (haml
               (:br)
               (:a.btn.btn-primary ([:href "/blog/post/new"]
                                    [:up-modal ".content"])
                                   "New")
               (.posts.list-group
                ,@(for/list ([a-post (blog-posts a-blog)])
                    (render-post a-blog a-post embed/url))))))
  
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
    (template "Blog" navs
              (haml
               (:h2 (post-title a-blog a-post))
               (:hr)
               (:p.content (post-body a-blog a-post))
               (:br)
               (:hr)
               (:h4 "Comments")
               (render-as-itemized-list (post-comments a-blog a-post))
               (:hr)
               (:h4 "New Comment Here:")
               (:form ([:action (embed/url insert-comment-handler)]
                       [:method "post"]
                       [:up-modal ".content"])
                      (:textarea ([:name "comment"]
                                  [:type "text"]
                                  [:placeholder "comment"]
                                  [:class "form-control"]
                                  [:cols "33"]
                                  [:rows "3"]))
                      (:br)
                      (:input.btn.btn-primary
                       ([:type "submit"]
                        [:value "Submit"])))
               (:hr)
               (:div
                (:a.btn.btn-primary
                 ([:href (embed/url goback-handler)])
                 "Back")))))
  
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
    (template "Add Comment" navs
              (haml
               (:h1 "Add a Comment")
               (:p "The Comment"
                   (:div (:p a-comment)))
               "will added to"
               (:h4 (post-title a-blog a-post))
               (:hr)
               (:p
                (:a.btn.btn-link
                 ([:href (embed/url yes-handler)])
                 "Yes, add the comment."))
               (:p
                (:a.btn.btn-link
                 ([:href (embed/url cancel-handler)])
                 "No, I changed my mind.")))))
  
  (define (yes-handler request)
    (post-insert-comment! a-blog a-post a-comment)
    (render-post-detail-page a-blog a-post (redirect/get)))
  
  (define (cancel-handler request)
    (render-post-detail-page a-blog a-post (redirect/get)))
  
  (send/suspend/dispatch response-generator))

;;; Error Ocurred Page
(define (occur-error-page title message p request)
  (define (response-generator embed/url)
    (template "Error" navs
              (haml
               (:h1 ([:style "color:red;"]) title)
               (:div
                (:p message))
               (:hr)
               (:div
                (:a.btn.btn-link ([:href (embed/url back-handler)])
                                 "Close")))))
  
  (define (back-handler request) (p request))
  
  (send/suspend/dispatch response-generator))



(define (new-blog-post req)
  (template "New Post"
            navs
            (haml
             (:h2 "New Post")
             (:form ([:actioin "/blog/post/new"] [:method "post"])
                    (:label
                     "Title"(:br)
                     (:input ([:type "text"] [:placeholder "Title"])))
                    (:br)
                    (:label
                     "Content"(:br)
                     (:textarea ([:type "text"] [:placeholder "Content"])))
                    (:br)
                    (:label
                     (:input ([:type "submit"] [:value "Submit"])))))))