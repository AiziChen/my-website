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
       (:form.row.g-2
        ([:action (embed/url search-handler)]
         [:type "POST"]
         ;[:up-target ".content"]
         ;[:up-layer "new modal"]
         )
        ;;(:label ([:for "music-platform"]) "Choose Music Platform")
        (.col-auto
         (:select.form-select
          ([:name "music-platform"])
          (:option ([:value "migu"]
                    [:selected ""]) "咪咕")
          (:option ([:value "kugou"]) "酷狗")
          (:option ([:value "YQB"]) "酷我")
          (:option ([:value "YQA"]) "网易")
          (:option ([:value "douban"]) "豆瓣")
          (:option ([:value "5singfc"]) "5SING FC")
          (:option ([:value "wusingyc"]) "5SING YC")
          (:option ([:value "djyule"]) "DJ娱乐")))
        (.col-auto
         (:input.form-control
          ([:type "text"]
           [:placeholder "Singer/Song Name"]
           [:name "text"])))
        (.col-auto
         (:input.btn.btn-primary
          ([:type "submit"]
           [:value "Search"]))))))
    (template "SONGS" "SONGS" body))
  
  (define (search-handler req)
    (let* ([bindings (request-bindings/raw req)]
           [text (bindings-ref bindings 'text)]
           [platform (bindings-ref bindings 'music-platform)])
      (if (and (non-empty-string? text)
               (non-empty-string? platform))
          (search-result-page text platform 1 req)
          (occur-error-page "Search Error"
                            "Invalid search content"
                            (lambda (req)
                              (render-song-list (redirect/get)))
                            req))))
  
  (send/suspend/dispatch response-generator))


(define (search-result-page text platform page req)
  (define (render-item-list item)
    (haml
     (.list-group-item.list-group-item-action
      (.d-flex.w-100.justify-content-between.play-div
       ([:src (hash-ref item 'url)])
       (:h6.mb-1
        (hash-ref item 'name))
       (:small
        (hash-ref item 'artist))))))
  (define (next-page-handler req)
      (search-result-page text platform (+ page 1) req))
  (define (response-generator embed/url)
    (define body
      (haml
       (:h2 ([:sytle "color:green;"])
            (string-append "「" text "」" " Search Result:"))
       (.list-group
        ,@(let* ([jsexp (music-search text platform page)]
                 [items (hash-ref jsexp 'list)]
                 [size (length items)]
                 [more (string->number (hash-ref jsexp 'more))])
            (cond
              [(< 0 size)
               (if (> more 0)
                   (append
                    (for/list ([item items])
                      (render-item-list item))
                    (list
                     (haml
                      (:a.btn.btn-primary
                       ([:href (embed/url next-page-handler)])
                       "Next"))))
                   (for/list ([item items])
                     (render-item-list item)))]
              [else
               (haml
                (.empty)
                (:p ([:style "color:red;"]) "0 music found."))])))))
    (template "Search Result" "SONGS" body #:scripts '("/my-songlist.js")))
  (send/suspend/dispatch response-generator))
