#lang racket/base

(require koyo/haml
         gregor
         web-server/servlet
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
(define ((blog-entry blog-db) request)
  (render-blog-page blog-db request))


;; Render Blog Page
(define (render-blog-page blog-db request)
  (define (render-post blog-db a-post embed/url)
    (define (view-post-handler request)
      (render-post-detail-page blog-db a-post request))
    (haml
     (:a.post.list-group-item.list-group-item-action
      ([:href (embed/url view-post-handler)])
      (.post-link
       (post-title a-post))
      (.post-comment-sum
       (let ([len (post-comments blog-db (post-id a-post))])
         (datetime->normal-string (post-created-at a-post)))))))
  
  (define (response-generator embed/url)
    (template "Blog" navs
              (haml
               (:br)
               (:a.btn.btn-primary ([:href "/blog/post/new"]
                                    [:up-modal ".content"])
                                   "New")
               (.posts.list-group
                ,@(for/list ([a-post (blog-posts blog-db)])
                    (render-post blog-db a-post embed/url))))))
  
  (send/suspend/dispatch response-generator))


;; Render Post Details
(define (render-post-detail-page blog-db a-post request)
  (define (response-generator embed/url)
    (template "Blog" navs
              (haml
               (:h2 (post-title a-post))
               (:hr)
               (:p.content (post-body a-post))
               (:br)
               (:hr)
               (:h4 "Comments")
               (render-as-itemized-list (map comment-content (post-comments blog-db (post-id a-post))))
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
         #;
         (render-confirm-add-comment-page blog-db
                                          comment
                                          a-post
                                          request)
         (post-insert-comment! blog-db (post-id a-post a-comment))
         (render-post-detail-page blog-db a-post (redirect/get))]
        [else
         (occur-error-page "Empty Comment"
                           "You should specify the comment content."
                           (lambda (request)
                             (render-post-detail-page blog-db a-post (redirect/get)))
                           request)])))
  
  (define (goback-handler request)
    (render-blog-page blog-db (redirect/get)))
  
  (send/suspend/dispatch response-generator))


;; Blog Comment Add Confirm
#;
(define (render-confirm-add-comment-page blog-db a-comment a-post request)
  (define (response-generator embed/url)
    (template "Add Comment" navs
              (haml
               (:h1 "Add a Comment")
               (:p "The Comment"
                   (:div (:p a-comment)))
               "will added to"
               (:h4 (post-title a-post))
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
    (post-insert-comment! blog-db (post-id a-post) a-comment)
    (render-post-detail-page blog-db a-post (redirect/get)))
  
  (define (cancel-handler request)
    (render-post-detail-page blog-db a-post (redirect/get)))
  
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



(define ((new-blog-post blog-db) req)
  (define (response-generator embed/url)
    (template "New Post"
              navs
              (haml
               (:h2 "New Post")
               (:form.row
                ([:action (embed/url insert-post-handler)] [:method "post"])
                (:label.form-label
                 "Title"(:br)
                 (:input.form-control ([:type "text"] [:placeholder "Title"] [:name "title"])))
                (:br)
                (:label.form-label
                 "Content"(:br)
                 (:textarea.form-control ([:type "text"] [:placeholder "Content"] [:name "body"])))
                (:br)
                (:label
                 (:input.btn.btn-primary ([:type "submit"] [:value "Submit"])))))))
  (define (insert-post-handler req)
    (let* ([bindings (request-bindings req)]
           [title (extract-binding/single 'title bindings)]
           [body (extract-binding/single 'body bindings)])
      (cond
        [(and (valid-string? title)
              (valid-string? body))
         (blog-insert-post! blog-db title body)
         (render-blog-page blog-db (redirect/get))]
        [else
         (occur-error-page "Empty Blog"
                           "The blog title & body must be specifed."
                           (lambda (req)
                             (render-blog-page blog-db (redirect/get)))
                           req)])))
  (send/suspend/dispatch response-generator))
