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

All of these except `test-error` are syntax, so the expression under test is
evaluated by the framework rather than at the call site. That is what lets a
raise become a reported failure instead of aborting the run — see
[Output format](#output-format). They are used exactly like procedures, but
cannot be passed as values. `test-error` takes an explicit thunk.

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

A test whose expression raises fails with the condition shown, and the run
continues with the next test:
```
  FAIL: test name
    expected: 42
    raised:   type error in 'car': expected pair, got ()
```

A raise from inside a group but outside any assertion ends that group rather
than the whole run:
```
  FAIL: <group aborted>
    raised:   type error in 'car': expected pair, got ()
    note:     remaining tests in this group did not run
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
