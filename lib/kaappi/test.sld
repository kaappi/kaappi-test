(define-library (kaappi test)
  (import (scheme base)
          (kaappi test runner))
  (export test-begin test-end test-group
          test-assert test-equal test-eqv test-approximate
          test-error test-not
          test-exit
          test-verbose!)
  (begin

    ;; The assertions are syntax, not procedures, so that the expression under
    ;; test reaches the runner as a thunk.  A procedure would have its arguments
    ;; evaluated at the call site, and a raise there escapes test-group: the rest
    ;; of the group is skipped without being counted, while the summary still
    ;; claims every test passed and only the exit code disagrees.  Thunking lets
    ;; the runner turn that raise into an ordinary failure and carry on.
    ;;
    ;; The calling shape is unchanged, so existing suites need no edits.

    (define-syntax test-assert
      (syntax-rules ()
        ((_ name expr) (%test-assert name (lambda () expr)))))

    (define-syntax test-not
      (syntax-rules ()
        ((_ name expr) (%test-not name (lambda () expr)))))

    (define-syntax test-equal
      (syntax-rules ()
        ((_ name expected actual)
         (%test-equal name (lambda () expected) (lambda () actual)))))

    (define-syntax test-eqv
      (syntax-rules ()
        ((_ name expected actual)
         (%test-eqv name (lambda () expected) (lambda () actual)))))

    (define-syntax test-approximate
      (syntax-rules ()
        ((_ name expected actual tolerance)
         (%test-approximate name
                            (lambda () expected)
                            (lambda () actual)
                            (lambda () tolerance)))))

    ;; test-error keeps taking an explicit thunk — that is its documented shape.
    ;; Reading its argument as an expression instead would silently turn every
    ;; existing (test-error "x" (lambda () ...)) into a test whose expression
    ;; merely builds a lambda and never raises, so it would start failing.

    (define-syntax test-group
      (syntax-rules ()
        ((_ name body ...)
         (begin
           (test-begin name)
           ;; %test-group-body catches a raise from outside any assertion, so a
           ;; failure in group setup ends that group rather than the whole run.
           ;; test-end still runs, keeping the indentation depth correct.
           (%test-group-body name (lambda () body ...))
           (test-end)))))

    (define (test-verbose! v) (%set-verbose! v))))
