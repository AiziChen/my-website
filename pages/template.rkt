#lang racket/base

(require koyo/haml
         koyo/preload
         xml
         web-server/servlet
         racket/format
         racket/contract
         "../tools/web-tools.rkt")

(provide template)


(struct nav (name link))
(define *navs*
  (list
   (nav "HOME" "/")
   (nav "SONGS" "/song-list")
   (nav "BLOG" "/blog")))


(define/contract (nav-bar active-item)
  (-> string? xexpr?)
  (define (active? item)
    (if (eqv? (nav-name item) active-item)
        "active" ""))
  
  (define list-items
    (for/list ([nav *navs*])
      (haml
       (:li.nav-item
        (:a ([:class (~a "nav-link " (active? nav))]
             [:data-bs-toggle "tooltip"]
             [:title (nav-name nav)]
             [:href (nav-link nav)])
            (nav-name nav))))))
  
  (haml (:ul.nav.nav-pills.top-nav ,@list-items)))


(define (template title active-item content)
  (define page
    (haml
     (:html
      (:head
       (:title title)
       (:link ([:rel "stylesheet"]
               [:type "text/css"]
               [:href "/bootstrap/bootstrap.min.css"]))
       (:link ([:rel "stylesheet"]
               [:type "text/css"]
               [:href "/unpoly/unpoly.min.css"]))
       (:link ([:rel "stylesheet"]
               [:type "text/css"]
               [:href "/top.css"])))
      (:body
       (nav-bar active-item)
       (:div.content ,@content)
       (:script ([:type "text/javascript"]
                 [:src "/bootstrap/bootstrap.min.js"]))
       (:script ([:type "text/javascript"]
                 [:src "/unpoly/unpoly.min.js"]))
       #;
       (:script ([:type "text/javascript"]
                 [:src "/unpoly/unpoly-bootstrap3.min.js"]))))))
  (response
   200
   #"OK"
   (current-seconds)
   #"text/html; charset=utf-8"
   (make-preload-headers)
   (lambda (out)
     (parameterize ([current-output-port out])
       (displayln "<!doctype html>")
       (write-xml/content (xexpr->xml page))))))
