#lang racket/base

(require web-server/http/response-structs
         racket/string)


(provide
 response/template valid-string?
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

(struct nav (name link [active? #:mutable]))
