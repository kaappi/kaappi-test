(define-library (kaappi test runner)
  (import (scheme base) (scheme write))
  (export test-begin test-end
          test-assert test-equal test-eqv test-approximate
          test-error test-not
          test-pass-count test-fail-count test-skip-count
          test-exit
          %set-verbose! %verbose?)
  (begin

    (define %pass 0)
    (define %fail 0)
    (define %skip 0)
    (define %verbose #t)
    (define %depth 0)

    (define (%set-verbose! v) (set! %verbose v))
    (define (%verbose?) %verbose)

    (define (test-pass-count) %pass)
    (define (test-fail-count) %fail)
    (define (test-skip-count) %skip)

    (define (indent)
      (let loop ((i 0))
        (when (< i (* %depth 2))
          (write-char #\space)
          (loop (+ i 1)))))

    (define (report-pass name)
      (set! %pass (+ %pass 1))
      (when %verbose
        (indent) (display "  ok: ") (display name) (newline)))

    (define (report-fail name expected actual)
      (set! %fail (+ %fail 1))
      (indent) (display "  FAIL: ") (display name) (newline)
      (indent) (display "    expected: ") (write expected) (newline)
      (indent) (display "    actual:   ") (write actual) (newline))

    (define (report-fail-msg name msg)
      (set! %fail (+ %fail 1))
      (indent) (display "  FAIL: ") (display name)
      (display " — ") (display msg) (newline))

    (define (test-begin name)
      (indent) (display name) (newline)
      (set! %depth (+ %depth 1)))

    (define (test-end)
      (set! %depth (max 0 (- %depth 1))))

    (define (max a b) (if (> a b) a b))

    (define (test-assert name expr)
      (if expr (report-pass name)
          (report-fail name #t expr)))

    (define (test-equal name expected actual)
      (if (equal? expected actual)
          (report-pass name)
          (report-fail name expected actual)))

    (define (test-eqv name expected actual)
      (if (eqv? expected actual)
          (report-pass name)
          (report-fail name expected actual)))

    (define (test-approximate name expected actual tolerance)
      (if (< (abs (- expected actual)) tolerance)
          (report-pass name)
          (report-fail name expected actual)))

    (define (abs x) (if (< x 0) (- x) x))

    (define (test-not name expr)
      (if (not expr) (report-pass name)
          (report-fail name #f expr)))

    (define (test-error name thunk)
      (guard (exn
              (#t (report-pass name)))
        (thunk)
        (report-fail-msg name "expected error but none raised")))

    (define (test-exit)
      (newline)
      (display (+ %pass %fail %skip))
      (display " tests: ")
      (display %pass) (display " passed")
      (when (> %fail 0)
        (display ", ") (display %fail) (display " failed"))
      (when (> %skip 0)
        (display ", ") (display %skip) (display " skipped"))
      (newline)
      (when (> %fail 0) (exit 1)))))
