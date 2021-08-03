#lang racket/base

(require gregor
         web-server/http/response-structs
         racket/string
         racket/format)


(provide
 response/template valid-string?
 nav nav-name nav-link nav-active? set-nav-active?!
 datetime->normal-string)


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


(define (datetime->normal-string dt)
  (~a (->year dt)
      "-"
      (->month dt)
      "-"
      (->day dt)
      " "
      (->hours dt)
      ":"
      (->minutes dt)
      ":"
      (->seconds dt)))
