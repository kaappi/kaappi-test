(define-library (kaappi test)
  (import (scheme base)
          (kaappi test runner))
  (export test-begin test-end test-group
          test-assert test-equal test-eqv test-approximate
          test-error test-not
          test-exit
          test-verbose!)
  (begin

    (define-syntax test-group
      (syntax-rules ()
        ((_ name body ...)
         (begin
           (test-begin name)
           body ...
           (test-end)))))

    (define (test-verbose! v) (%set-verbose! v))))
