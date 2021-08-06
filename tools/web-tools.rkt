#lang racket/base

(require gregor
         web-server/http/response-structs
         racket/string
         racket/format)


(provide
 response/template valid-string?
 datetime->normal-string)


(define response/template
  (lambda (template)
    (response/full
     200 #"Okay"
     (current-seconds) TEXT/HTML-MIME-TYPE
     (list)
     (list (string->bytes/utf-8 template)))))


(define (valid-string? s)
  (and (string? s)
       (non-empty-string? (string-trim s))))


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
