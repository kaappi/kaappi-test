(import (kaappi test))

(test-group "arithmetic"
  (test-equal "addition" 4 (+ 2 2))
  (test-equal "multiplication" 42 (* 6 7))
  (test-assert "positive" (> 5 0)))

(test-group "strings"
  (test-equal "append" "hello world"
              (string-append "hello" " " "world"))
  (test-equal "length" 5 (string-length "hello")))

(test-group "lists"
  (test-equal "map" '(2 4 6)
              (map (lambda (x) (* x 2)) '(1 2 3)))
  (test-assert "member" (member 3 '(1 2 3 4)))
  (test-not "not member" (member 5 '(1 2 3 4))))

(test-group "errors"
  (test-error "type error" (lambda () (+ 1 "two"))))

(test-exit)
