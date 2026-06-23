# kaappi-test

Test framework for [Kaappi Scheme](https://github.com/kaappi/kaappi).

Pure Scheme — no C dependencies, no build step. SRFI-64 inspired API.

## Install

```bash
thottam install kaappi-test
```

## Quick start

```scheme
(import (kaappi test))

(test-group "arithmetic"
  (test-equal "2+2" 4 (+ 2 2))
  (test-assert "positive" (> 5 0)))

(test-group "errors"
  (test-error "type error" (lambda () (+ 1 "two"))))

(test-exit)
```

Output:

```
arithmetic
  ok: 2+2
  ok: positive
errors
  ok: type error

3 tests: 3 passed
```

## API

### Test groups

```scheme
(test-group "name" body ...)   ; group tests with a header
(test-begin "name")            ; manual group start
(test-end)                     ; manual group end
```

### Assertions

```scheme
(test-assert "name" expr)                    ; pass if expr is truthy
(test-equal "name" expected actual)          ; pass if (equal? expected actual)
(test-eqv "name" expected actual)            ; pass if (eqv? expected actual)
(test-approximate "name" expected actual tol); pass if within tolerance
(test-not "name" expr)                       ; pass if expr is #f
(test-error "name" thunk)                    ; pass if thunk raises an error
```

### Reporting

```scheme
(test-exit)            ; print summary, exit 1 if any failures
(test-verbose! #f)     ; suppress individual pass messages
```

## Output format

Pass:
```
  ok: test name
```

Failure:
```
  FAIL: test name
    expected: 42
    actual:   43
```

Summary:
```
19 tests: 19 passed
```

Or on failure:
```
5 tests: 3 passed, 2 failed
```

## License

MIT
