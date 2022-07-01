#lang racket/base

(require net/http-easy
         koyo/http
         koyo/json
         (prefix-in servlet: web-server/servlet)
         web-server/http/redirect
         json
         racket/format
         racket/contract)

(provide
 lllnet-report-course-study-progress)

(define (lllnet-report-course-study-progress req)
  (let* ([json (servlet:request-post-data/raw req)]
         [jsexpr (bytes->jsexpr json)]
         [grade-id (hash-ref jsexpr 'gradeId #f)]
         [course-id (hash-ref jsexpr 'courseId #f)]
         [courseware-id (hash-ref jsexpr 'coursewareId #f)]
         [user-id (hash-ref jsexpr 'userId #f)]
         [uname-sn (hash-ref jsexpr 'unameSN #f)]
         [org-name (hash-ref jsexpr 'orgName #f)])
    (cond
      [(and grade-id course-id courseware-id user-id uname-sn org-name)
       (define res
         (post "http://media.lllnet.cn/media/reportCourseStudyProgress"
               #:form `((courseId . ,course-id)
                        (gradeId . ,grade-id)
                        (coursewareId . ,courseware-id)
                        (userId . ,user-id)
                        (unameSN . ,uname-sn)
                        (orgName . ,org-name))))
       (if (= (response-status-code res) 200)
           (response/json (response-json res))
           (response/json (hasheq 'status "error")))]
      [else
       (response/json (hasheq 'status "error"
                              'msg "parameter isn't correct"))])))
