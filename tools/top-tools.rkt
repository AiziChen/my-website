#lang racket/base

(require web-server/servlet
         koyo/haml)

(provide render-as-itemized-list)

(define (render-as-itemized-list l)
  (haml
   (:ol.list-group.list-group-numbered
    ,@(map (lambda (e) (haml (:li.list-group-item e))) l))))

(define (can-parse-post? bindings)
  (and (exists-binding? 'title bindings)
       (exists-binding? 'body bindings)))

