#lang racket/base

(require web-server/servlet
         koyo/haml
         (prefix-in he: net/http-easy)
         net/uri-codec
         racket/string
         racket/math
         racket/contract)

(provide
 render-as-itemized-list
 music-search)


(define (render-as-itemized-list l)
  (haml
   (:ol.list-group.list-group-numbered
    ,@(map (lambda (e) (haml (:li.list-group-item e))) l))))


(define (can-parse-post? bindings)
  (and (exists-binding? 'title bindings)
       (exists-binding? 'body bindings)))


(define *music-search-api* "http://43.128.26.51:5000/api/music/search")
(define/contract (music-search text type page)
  (-> non-empty-string? non-empty-string? positive-integer?
      (or/c #f (listof hash?)))
  (define rs
    (he:response-json
     (he:post *music-search-api*
              #:json (hasheq 'text (uri-encode text)
                             'type type
                             'page page))))
  (if (eqv? (hash-ref rs 'code) 200)
      (hash-ref
       (hash-ref rs 'data)
       'list)
      #f))
