# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/).

## [Unreleased]

### Fixed
- A raise inside a test now fails that test and the run continues. Previously
  the assertions were procedures, so the expression was evaluated at the call
  site and an error escaped `test-group` entirely: every later test in the group
  was skipped without being counted, while the summary still reported
  `N tests: N passed` and only the exit code disagreed. The failure now shows
  the raised condition.
- A raise from inside a group but outside any assertion — setup code in a `let`,
  a bare expression between tests — ends that group instead of the whole run,
  and is counted as a failure.

### Changed
- `test-assert`, `test-equal`, `test-eqv`, `test-approximate` and `test-not` are
  now syntax rather than procedures, so they can thunk the expression under
  test. The calling shape is unchanged and existing suites need no edits, but
  they can no longer be passed as values. `test-error` still takes an explicit
  thunk, as documented.

## [0.1.0] - 2026-07-26

### Added
- Test framework — `test-begin`/`test-end`/`test-group`, assertions
  `test-assert`/`test-equal`/`test-eqv`/`test-approximate`/`test-error`/`test-not`,
  `test-exit`, and `test-verbose!`
- Pure Scheme implementation, no C dependencies or build step
- CI workflow for automated testing
