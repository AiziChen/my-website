#lang racket/base
(require racket/list
         db)

(provide blog? blog-posts
         post? post-title post-body post-comments
         initialize-blog!
         blog-insert-post! post-insert-comment!)

(struct blog (db))

(struct post (blog id))

(define (blog-posts a-blog)
  (map (lambda (id)
         (post a-blog id))
       (query-list (blog-db a-blog)
                   "SELECT id FROM posts")))
(define (post-title a-post)
  (query-value (blog-db (post-blog a-post))
               "SELECT title FROM posts WHERE id = ?"
               (post-id a-post)))
(define (post-body a-post)
  (query-value (blog-db (post-blog a-post))
               "SELECT body FROM posts WHERE id = ?"
               (post-id a-post)))
(define (post-comments a-post)
  (query-list (blog-db (post-blog a-post))
               "SELECT content FROM comments WHERE pid = ?"
               (post-id a-post)))

(define (initialize-blog! home)
  (define db (sqlite3-connect #:database home #:mode 'create))
  (define the-blog (blog db))
  (unless (table-exists? db "posts")
    (query-exec db
                (string-append
                 "CREATE TABLE posts "
                 "(id INTEGER PRIMARY KEY, title TEXT, body TEXT)"))
    (blog-insert-post!
     the-blog "First Post" "This is my first post.")
    (blog-insert-post!
     the-blog "Second Post" "This is my second post"))
  (unless (table-exists? db "comments")
    (query-exec db
                (string-append "CREATE TABLE comments "
                               "(pid INTEGER, content TEXT)"))
    (post-insert-comment!
     the-blog (first (blog-posts the-blog)) "First Comment"))
  the-blog)

;; blog-insert-post!: blog post -> void
;; Consumes a blog and a post, then adds the post at the top of the blog
(define (blog-insert-post! a-blog title body)
  (query-exec (blog-db a-blog)
              "INSERT INTO posts(title, body) VALUES (?, ?)"
              title body))

;; post-insert-comment!: post string -> void
;; Consumes a post and a comment string. As a side-effect,
;; adds the comment to the bottom of the post's list of comments.
(define (post-insert-comment! a-blog a-post a-comment)
  (query-exec (blog-db a-blog)
              "INSERT INTO comments (pid, content) VALUES (?, ?)"
              (post-id a-post)
              a-comment))
