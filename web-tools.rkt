#lang racket/base

(require web-server/http/response-structs
         "top-tools.rkt")

(provide response/template
         valid-string?)

(define response/template
  (lambda (template)
    (response/full
     200 #"Okay"
     (current-seconds) TEXT/HTML-MIME-TYPE
     (list)
     (list (string->bytes/utf-8 template)))))

(define (valid-string? s)
  (not (or (null? s)
           (empty-string? s))))