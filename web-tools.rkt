#lang racket/base

(require web-server/http/response-structs)

(provide response/template)

(define response/template
  (lambda (template)
    (response/full
     200 #"Okay"
     (current-seconds) TEXT/HTML-MIME-TYPE
     (list)
     (list (string->bytes/utf-8 template)))))
