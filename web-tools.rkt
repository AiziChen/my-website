#lang racket/base

(require web-server/http/response-structs
	 racket/string
         web-server/templates
         "top-tools.rkt")


(provide
 ;; lib
 response/template valid-string?
 ;;vars
 top-style-sheet bootstrap-style-sheet bootstrap-js
 top-nav-bar
 nav nav-name nav-link nav-active? set-nav-active?!)


(define response/template
  (lambda (template)
    (response/full
     200 #"Okay"
     (current-seconds) TEXT/HTML-MIME-TYPE
     (list)
     (list (string->bytes/utf-8 template)))))


(define (valid-string? s)
  (non-empty-string? s))


;;; VARS
(define top-style-sheet
  `(link ([rel "stylesheet"]
          [href "/top.css"]
          [type "text/css"])))
(define bootstrap-style-sheet
  `(link ([rel "stylesheet"]
          [href "/bootstrap/bootstrap.min.css"]
          [type "text/css"])))
(define bootstrap-js
  `(script ([type "text/javascript"]
            [src "/bootstrap/bootstrap.min.js"]
            [crossorigin "anonymouse"])))


(struct nav (name link [active? #:mutable]))


(define (top-nav-bar navs)
  (include-template "templates/top-nav-bar.html"))
