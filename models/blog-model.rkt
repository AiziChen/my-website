#lang racket/base
(require racket/list
         db)

(provide blog-posts
         post? post-title post-body post-comments post-comments-count
         initialize-blog! get-new-blog-db
         blog-insert-post! post-insert-comment!
         post-updated-at post-created-at
         post-comments-created-at post-comments-updated-at)

;;; BLOG DB PATH
(define BLOG-DB-HOME (build-path (current-directory) "the-blog-data.db"))

;;; BLOG MODEL
;;; STRUCTS
(struct post (blog id))

(define (blog-posts blog-db)
  (map (lambda (id)
         (post blog-db id))
       (query-list blog-db
                   "SELECT id FROM posts ORDER BY id DESC")))
(define (blog-posts-in-page blog-db page #:each [each 10])
  (map (lambda (id)
         	 (post blog-db id))
       (query-list blog-db
                   "SELECT id FROM posts WHERE id BETWEEN ? AND ? ORDER BY id DESC"
                   (* each (- page 1))
                   (* each page))))
(define (post-title blog-db a-post)
  (query-value blog-db
               "SELECT title FROM posts WHERE id = ?"
               (post-id a-post)))
(define (post-body blog-db a-post)
  (query-value blog-db
               "SELECT body FROM posts WHERE id = ?"
               (post-id a-post)))
(define (post-created-at blog-db a-post)
  (query-value blog-db
               "SELECT created_at FROM posts WHERE id = ?"
               (post-id a-post)))
(define (post-updated-at blog-db a-post)
  (query-value blog-db
               "SELECT updated_at FROM posts WHERE id = ?"
               (post-id a-post)))
(define (post-comments blog-db a-post)
  (query-list blog-db
              "SELECT content FROM comments WHERE pid = ?"
              (post-id a-post)))
(define (post-comments-count blog-db a-post)
  (query-value blog-db
               "SELECT COUNT(*) FROM comments WHERE pid = ?"
               (post-id a-post)))
(define (post-comments-created-at blog-db a-post)
  (query-value blog-db
               "SELECT created_at FROM comments WHERE pid = ?"
               (post-id a-post)))
(define (post-comments-updated-at blog-db a-post)
  (query-value blog-db
               "SELECT updated_at FROM comments WHERE pid = ?"
               (post-id a-post)))

(define (initialize-blog!)
  (define db get-new-blog-db)
  (unless (table-exists? db "posts")
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
    (query-exec db
                (string-append "CREATE TABLE comments "
                               "(pid INTEGER, content TEXT"
                               ", created_at DATETIME DEFAULT CURRENT_TIMESTAMP"
                               ", updated_at DATETIME DEFAULT CURRENT_TIMESTAMP)"))
    (post-insert-comment!
     db (first (blog-posts db)) "First Comment"))
  (disconnect db))

;;; GET NEW BLOG DB CONNECTION
(define get-new-blog-db
  (virtual-connection
   (connection-pool
    (lambda ()
      (sqlite3-connect #:database BLOG-DB-HOME #:mode 'create)))))

;; blog-insert-post!: blog post -> void
;; Consumes a blog and a post, then adds the post at the top of the blog
(define (blog-insert-post! blog-db title body)
  (query-exec blog-db
              "INSERT INTO posts(title, body) VALUES (?, ?)"
              title body))

;; post-insert-comment!: post string -> void
;; Consumes a post and a comment string. As a side-effect,
;; adds the comment to the bottom of the post's list of comments.
(define (post-insert-comment! blog-db a-post a-comment)
  (query-exec blog-db
              "INSERT INTO comments (pid, content) VALUES (?, ?)"
              (post-id a-post)
              a-comment))
