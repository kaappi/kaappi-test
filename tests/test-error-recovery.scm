;;; Self-test: a raise inside a test must fail that test, not abort the run.
;;;
;;; This file cannot use test-exit — it deliberately provokes failures, so the
;;; summary would be non-zero and the process would exit 1.  Instead it reads
;;; the runner's counters directly, checks the deltas, and exits 0 when the
;;; framework behaved correctly.  The FAIL lines it prints are intentional.

(import (scheme base) (scheme write) (scheme process-context)
        (kaappi test) (kaappi test runner))

(define (check label ok)
  (display (if ok "  ok: " "  FAILED: "))
  (display label)
  (newline)
  (if (not ok) (exit 1)))

(display "=== intentional failures below — this file provokes them on purpose ===")
(newline)

;; --- A raise inside each assertion form -------------------------------------

(define reached-after-raises #f)
(define p0 (test-pass-count))
(define f0 (test-fail-count))

(test-group "assertions that raise"
  (test-equal       "raise in actual"    1 (car '()))
  (test-equal       "raise in expected"  (car '()) 1)
  (test-assert      "raise in assert"    (car '()))
  (test-not         "raise in not"       (car '()))
  (test-eqv         "raise in eqv"       1 (car '()))
  (test-approximate "raise in approx"    1.0 (car '()) 0.1)
  ;; Reached only if none of the six raises escaped the assertion.
  (set! reached-after-raises #t)
  (test-equal       "later test still runs" 2 2))

(define p1 (test-pass-count))
(define f1 (test-fail-count))

;; --- A raise outside any assertion ------------------------------------------

(define after-aborted-group #f)
(define g0 (test-fail-count))

(test-group "raise outside an assertion"
  (test-equal "before the raise" 1 1)
  (car '())                                  ; setup-style error
  (set! after-aborted-group 'group-continued))

(set! after-aborted-group 'run-continued)
(define g1 (test-fail-count))

;; --- Verification -----------------------------------------------------------

(newline)
(display "=== verification ===")
(newline)

(check "execution continued past a raising assertion" reached-after-raises)
(check "each raising assertion counted as one failure" (= (- f1 f0) 6))
(check "the non-raising test in that group still passed" (= (- p1 p0) 1))
(check "a raise outside an assertion counts as one failure" (= (- g1 g0) 1))
(check "the run continued after an aborted group"
       (eq? after-aborted-group 'run-continued))

(newline)
(display "error-recovery self-test passed")
(newline)
(exit 0)
