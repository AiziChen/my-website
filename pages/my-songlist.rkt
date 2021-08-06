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
       (:h1 "Free Music Search")
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
          (:option ([:value "YQC"]
                    [:selected ""]) "酷狗")
          (:option ([:value "migu"]) "咪咕")
          (:option ([:value "YQB"]) "酷我")
          (:option ([:value "YQA"]) "网易")
          (:option ([:value "douban"]) "豆瓣")
          (:option ([:value "5singfc"]) "5SING FC")
          (:option ([:value "wusingyc"]) "5SING YC")
          (:option ([:value "djyule"]) "DJ娱乐")))
        (.col-auto
         (:input.form-control
          ([:type "text"]
           [:method "POST"]
           [:placeholder "Singer/Song Name"]
           [:name "text"])))
        (.col-auto
         (:input.btn.btn-primary
          ([:type "submit"]
           [:value "Search"]))))))
    (template "SONGS" "SONGS" body))
  
  (define (search-handler req)
    (let* ([bindings (request-bindings/raw req)]
           [text (string-trim (bindings-ref bindings 'text))]
           [platform (string-trim (bindings-ref bindings 'music-platform))])
      (if (and (non-empty-string? text)
               (non-empty-string? platform))
          (search-result-page text platform 1 (redirect/get))
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
       ([:url (hash-ref item 'url)]
        [:name (hash-ref item 'name)]
        [:artist (hash-ref item 'artist)]
        ;[:cover (hash-ref item 'cover)]
        [:lrc (hash-ref item 'lrc)]
        ;[:time (hash-ref item 'time)]
        )
       (:h6.mb-1
        (hash-ref item 'name))
       (:small
        (hash-ref item 'artist))))))
  (define (next-page-handler req)
    (search-result-page text platform (+ page 1) req))
  (define (response-generator embed/url)
    (define body
      (haml
       (:h2 ([:style "color:green;"])
            (string-append "「" text "」" " Search Result:"))
       (:div ([:id "lrc-panel"]) "FREE MUSIC PLAYER")
       (.list-group
        ,@(let* ([jsexp (music-search text platform page)]
                 [jsexp-size (length (hash-keys jsexp))])
            (cond
              [(<= jsexp-size 0)
               (haml
                (.empty)
                (:p ([:style "color: red;"]) "server error, please try again later."))]
              [else
               (let* ([items (hash-ref jsexp 'list)]
                      [size (length items)]
                      [more (if (> size 0)
                                (string->number (hash-ref jsexp 'more))
                                0)])
                 (cond
                   [(<= size 0)
                    (haml
                     (.empty)
                     (:p ([:style "color:red;"]) "no music found."))]
                   [(> more 0)
                    (append
                     (for/list ([item items])
                       (render-item-list item))
                     (list
                      (haml
                       (:a.btn.btn-primary
                        ([:href (embed/url next-page-handler)])
                        "Next"))))]
                   [else
                    (for/list ([item items])
                      (render-item-list item))]))])))))
    (template (string-append "Search 「" text "」")
              "SONGS"
              body
              #:scripts '("/player/lyrics.min.js" "/my-songlist.js")
              #:csses '("/my-songlist.css")))
  (send/suspend/dispatch response-generator))
