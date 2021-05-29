#lang racket/base

(require koyo/haml
         koyo/preload
         xml
         web-server/servlet
         racket/format
         "../tools/web-tools.rkt")

(provide template)

(define (template title navs content)
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
       (:ul.nav.nav-pills.top-nav
        ,@(for/list ([nav navs])
            (haml
             (:li.nav-item
              (:a ([:class (~a "nav-link " (when (nav-active? nav) "active"))]
                   [:data-bs-toggle "tooltip"]
                   [:title (nav-name nav)]
                   [:href (nav-link nav)])
                  (nav-name nav))))))
       (:div.content ,@content)
       (:script ([:type "text/javascript"]
                 [:src "/bootstrap/bootstrap.min.js"]))
       (:script ([:type "text/javascript"]
                 [:src "/unpoly/unpoly.min.js"]))
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