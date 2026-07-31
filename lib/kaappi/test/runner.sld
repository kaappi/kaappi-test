(define-library (kaappi test runner)
  (import (scheme base) (scheme write))
  (export test-begin test-end
          %test-assert %test-equal %test-eqv %test-approximate %test-not
          %test-group-body
          test-error
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

    ;; --- Raised conditions ---
    ;;
    ;; Test expressions arrive as thunks so that an error raised while producing
    ;; a value fails that one test and lets the run continue.  When the
    ;; assertions were plain procedures the expression was evaluated at the call
    ;; site instead, so a raise escaped test-group entirely: every later test in
    ;; the group was skipped without being counted, while the summary still
    ;; reported "N tests: N passed" and only the exit code hinted otherwise.

    (define %raised-tag (list 'raised))

    ;; Run thunk, returning either its value or the raised condition wrapped in
    ;; %raised-tag.  The tag is a fresh private pair, so no value a thunk can
    ;; return is mistaken for it.
    (define (attempt thunk)
      (guard (e (#t (cons %raised-tag e)))
        (thunk)))

    (define (raised? r) (and (pair? r) (eq? (car r) %raised-tag)))
    (define (raised-condition r) (cdr r))

    (define (write-condition e)
      (if (error-object? e)
          (begin
            (display (error-object-message e))
            (let ((irritants (error-object-irritants e)))
              (if (pair? irritants)
                  (begin (display " ") (write irritants)))))
          (write e)))

    ;; %no-expected marks an assertion with no meaningful expected value
    ;; (test-assert, test-not), so the report omits that line.
    (define %no-expected (list 'no-expected))

    (define (report-raised name expected e)
      (set! %fail (+ %fail 1))
      (indent) (display "  FAIL: ") (display name) (newline)
      (if (not (eq? expected %no-expected))
          (begin (indent) (display "    expected: ") (write expected) (newline)))
      (indent) (display "    raised:   ") (write-condition e) (newline))

    (define (test-begin name)
      (indent) (display name) (newline)
      (set! %depth (+ %depth 1)))

    (define (test-end)
      (set! %depth (max 0 (- %depth 1))))

    (define (max a b) (if (> a b) a b))

    ;; Each assertion takes thunks, not values — see the note above.  The
    ;; expected side is thunked too: it is often a computed value, and a raise
    ;; there is a bug in the test that should be reported, not one that takes
    ;; the rest of the group down with it.

    (define (%test-assert name expr-thunk)
      (let ((r (attempt expr-thunk)))
        (cond
          ((raised? r) (report-raised name %no-expected (raised-condition r)))
          (r           (report-pass name))
          (else        (report-fail name #t r)))))

    (define (%test-not name expr-thunk)
      (let ((r (attempt expr-thunk)))
        (cond
          ((raised? r)  (report-raised name %no-expected (raised-condition r)))
          ((not r)      (report-pass name))
          (else         (report-fail name #f r)))))

    ;; Shared shape for the comparing assertions: evaluate expected, then
    ;; actual, reporting whichever raises; otherwise compare with same?.
    (define (compare-test name expected-thunk actual-thunk same?)
      (let ((e (attempt expected-thunk)))
        (if (raised? e)
            (report-raised name %no-expected (raised-condition e))
            (let ((a (attempt actual-thunk)))
              (cond
                ((raised? a)  (report-raised name e (raised-condition a)))
                ((same? e a)  (report-pass name))
                (else         (report-fail name e a)))))))

    (define (%test-equal name expected-thunk actual-thunk)
      (compare-test name expected-thunk actual-thunk equal?))

    (define (%test-eqv name expected-thunk actual-thunk)
      (compare-test name expected-thunk actual-thunk eqv?))

    (define (%test-approximate name expected-thunk actual-thunk tolerance-thunk)
      (let ((t (attempt tolerance-thunk)))
        (if (raised? t)
            (report-raised name %no-expected (raised-condition t))
            (compare-test name expected-thunk actual-thunk
                          (lambda (e a) (< (abs (- e a)) t))))))

    (define (abs x) (if (< x 0) (- x) x))

    ;; Backstop for a raise that happens inside a group but outside any
    ;; assertion — setup code in a `let`, a bare expression between tests.
    ;; Without it such a raise still aborts the whole run.  The group is
    ;; counted as one failure so the summary and exit code both show it.
    (define (%test-group-body name thunk)
      (let ((r (attempt thunk)))
        (if (raised? r)
            (begin
              (set! %fail (+ %fail 1))
              (indent) (display "  FAIL: <group aborted>") (newline)
              (indent) (display "    raised:   ")
              (write-condition (raised-condition r)) (newline)
              (indent) (display "    note:     ")
              (display "remaining tests in this group did not run") (newline)))))

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
