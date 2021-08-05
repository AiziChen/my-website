#lang racket/base

(require koyo/haml
         koyo/preload
         xml
         web-server/servlet
         racket/format
         racket/contract
         "../tools/web-tools.rkt")

(provide
 template
 occur-error-page)


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


(define (template title active-item content #:scripts [scripts '()])
  (define page
    (haml
     (:html
      (:head
       (:meta ([:charset "UTF-8"]))
       (:meta ([:http-equiv "X-UA-Compatible"]
               [:content "IE=edge"]))
       (:meta ([:name "viewport"]
               [:content "width=device-width, initial-scale=1.0"]))
       (:title title)
       (:link ([:rel "stylesheet"]
               [:type "text/css"]
               [:href "/bootstrap/bootstrap.min.css"]))
       (:link ([:rel "stylesheet"]
               [:type "text/css"]
               [:href "/unpoly/unpoly.min.css"]))
       (:llink ([:ref "stylesheet"]
                [:type "text/css"]
                [:href "/unpoly/unpoly-bootstrap5.min.css"]))
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
       (:script ([:type "text/javascript"]
                 [:src "/player/howler.min.js"]))
       #;
       (:script ([:type "text/javascript"]
                 [:src "/unpoly/unpoly-bootstrap5.min.js"]))
       ,@(for/list ([s scripts])
           (haml
            (:script ([:type "text/javascript"]
                      [:src s]))))))))
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


;;; Error Ocurred Page
(define (occur-error-page title message p request)
  (define (response-generator embed/url)
    (define body
      (haml
       (:h1 ([:style "color:red;"]) title)
       (:div
        (:p message))
       (:hr)
       (:div
        (:a.btn.btn-link ([:href (embed/url back-handler)]) "Close"))))
    (template "Error" "ERROR" body))
  
  (define (back-handler req) (p req))
  
  (send/suspend/dispatch response-generator))
