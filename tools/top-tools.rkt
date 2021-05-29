#lang racket/base

(require web-server/servlet)

(provide render-as-itemized-list)

(define (render-as-itemized-list l)
  `(ol ([class "list-group list-group-numbered"])
       ,@(map
          (lambda (e)
            `(li ([class "list-group-item"]) ,e))
          l)))

(define (can-parse-post? bindings)
  (and (exists-binding? 'title bindings)
       (exists-binding? 'body bindings)))

