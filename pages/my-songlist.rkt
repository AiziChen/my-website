#lang racket/base

(require koyo/haml
         koyo/http
         xml
         racket/string
         web-server/servlet
         web-server/http/bindings
         "template.rkt"
         "../tools/top-tools.rkt")

(provide song-list)


(define (song-list req)
  (render-song-list req))

(define (render-song-list req)
  (define (response-generator embed/url)
    (define body
      (haml
       (:h1 "My Song List")
       (:form ([:action (embed/url search-handler)]
               [:type "POST"]
               ;[:up-target ".content"]
               ;[:up-layer "new modal"]
               )
              (:input.form-control
               ([:type "text"]
                [:placeholder "Singer/Song Name"]
                [:name "text"]))
              (:input.btn.btn-primary
               ([:type "submit"]
                [:value "Search"])))))
    (template "SONGS" "SONGS" body))
  
  (define (search-handler req)
    (let ([text (bindings-ref (request-bindings/raw req) 'text)])
      (if (non-empty-string? text)
          (search-result-page text req)
          (occur-error-page "Search Error"
                            "Invalid search content"
                            (lambda (req)
                              (render-song-list (redirect/get)))
                            req))))
  
  (send/suspend/dispatch response-generator))


(define (search-result-page text req)
  (define (render-item-list item)
    (haml
     (.list-group-item.list-group-item-action
      (.d-flex.w-100.justify-content-between.play-div
       ([:src (hash-ref item 'url)])
       (:h6.mb-1
        (hash-ref item 'name))
       (:small
        (hash-ref item 'artist))))))
  (define body
    (haml
     (:h1 ([:sytle "color:red"])
          (string-append "「" text "」" " Search Result:"))
     (.list-group
      ,@(for/list ([item (music-search text "migu" 1)])
          (render-item-list item)))))
  (template "Search Result" "SONGS" body #:scripts '("/my-songlist.js")))
