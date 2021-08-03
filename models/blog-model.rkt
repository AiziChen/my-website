#lang racket/base
(require deta
         threading
         gregor
         db
         racket/sequence
         racket/string
         racket/contract)

(provide
 (schema-out post)
 (schema-out comment)
 initialize-blog!
 blog-dbc
 blog-posts
 blog-posts-in-page
 post-comments
 blog-insert-post!
 post-insert-comment!)

;;; POST MODEL
(define-schema post
  ([id id/f #:primary-key #:auto-increment]
   [title string/f #:contract non-empty-string? #:wrapper string-titlecase]
   [body string/f #:contract non-empty-string?]
   [[created-at (now)] datetime/f]
   [[updated-at (now)] datetime/f]))

;;; COMMENT MODEL
(define-schema comment
  ([pid id/f]
   [content string/f #:contract non-empty-string?]
   [[created-at (now)] datetime/f]
   [[updated-at (now)] datetime/f]))


(define (blog-posts blog-db)
  (sequence->list
   (in-entities blog-db
                (~> (from post #:as p)
                    (order-by ([p.id #:desc]))))))

(define (blog-posts-in-page blog-db page #:each [each 10])
  (sequence->list
   (in-entities blog-db
                (~> (from post #:as p)
                    (select _ (between p.id
                                       ,(* each (- page 1))
                                       ,(* each page)))))))

(define (post-comments blog-db post-id)
  (sequence->list
   (in-entities blog-db
                (~> (from comment #:as c)
                    (where (= c.pid ,post-id))))))

(define (initialize-blog!)
  (define db blog-dbc)
  (unless (table-exists? db "posts")
    (create-table! db 'post)
    #;
    (query-exec db
                (string-append
                 "CREATE TABLE posts "
                 "(id INTEGER PRIMARY KEY, title TEXT, body TEXT"
                 ", created_at DATETIME DEFAULT CURRENT_TIMESTAMP"
                 ", updated_at DATETIME DEFAULT CURRENT_TIMESTAMP)"))
    (blog-insert-post!
     db "First Post" "This is my first post.")
    (blog-insert-post!
     db "Second Post" "This is my second post"))
  (unless (table-exists? db "comments")
    (create-table! db 'comment)
    #;
    (query-exec db
                (string-append "CREATE TABLE comments "
                               "(pid INTEGER, content TEXT"
                               ", created_at DATETIME DEFAULT CURRENT_TIMESTAMP"
                               ", updated_at DATETIME DEFAULT CURRENT_TIMESTAMP)"))
    (post-insert-comment!
     db (post-id (car (blog-posts db))) "First Comment"))
  (disconnect db))

;;; GET NEW BLOG DB CONNECTION
(define blog-dbc
  (virtual-connection
   (connection-pool
    (lambda ()
      (postgresql-connect #:database "my-blog"
                          #:user "coq"
                          #:password "quanyec")))))

;; blog-insert-post!: blog post -> void
;; Consumes a blog and a post, then adds the post at the top of the blog
(define (blog-insert-post! blog-db title body)
  (insert-one! blog-db
               (make-post #:title title
                          #:body body)))

;; post-insert-comment!: post string -> void
;; Consumes a post and a comment string. As a side-effect,
;; adds the comment to the bottom of the post's list of comments.
(define (post-insert-comment! blog-db post-id a-comment)
  (insert-one! blog-db
               (make-comment #:pid post-id
                             #:content a-comment)))