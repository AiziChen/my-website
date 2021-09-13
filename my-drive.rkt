#lang racket/base

(require koyo/json
         racket/path)


(provide
 show-drive-list)

(define *drive-path* "drive/")

(define (get-drive-list)
  (parameterize ([current-directory (build-path "static" *drive-path*)])
    (define file-lst
      (filter (lambda (f) (file-exists? f))
              (directory-list (current-directory))))
    (for/list ([f file-lst])
      (hasheq 'name (path->string (file-name-from-path f))
              'ext (bytes->string/locale (path-get-extension f))
              'path *drive-path*
              'size (file-size f)
              'modify-time (file-or-directory-modify-seconds f)))))

(define (show-drive-list req)
  (define lst (get-drive-list))
  (response/json
   (hasheq 'status 1
           'files (get-drive-list))))

