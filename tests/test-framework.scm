(import (kaappi test))

(test-group "test-assert"
  (test-assert "true is true" #t)
  (test-assert "42 is truthy" 42)
  (test-assert "string is truthy" "hello")
  (test-assert "empty list is truthy" '()))

(test-group "test-equal"
  (test-equal "numbers" 42 42)
  (test-equal "strings" "hello" "hello")
  (test-equal "lists" '(1 2 3) '(1 2 3))
  (test-equal "nested" '(("a" . 1)) '(("a" . 1)))
  (test-equal "boolean" #t #t))

(test-group "test-eqv"
  (test-eqv "integers" 42 42)
  (test-eqv "chars" #\a #\a))

(test-group "test-approximate"
  (test-approximate "pi" 3.14159 3.14 0.01)
  (test-approximate "exact" 1.0 1.0 0.001))

(test-group "test-not"
  (test-not "false is not" #f)
  (test-not "null predicate" (null? '(1))))

(test-group "test-error"
  (test-error "division by zero" (lambda () (/ 1 0)))
  (test-error "car of non-pair" (lambda () (car 42))))

(test-group "nested groups"
  (test-group "inner"
    (test-equal "inner test" 1 1))
  (test-equal "outer test" 2 2))

(test-exit)
