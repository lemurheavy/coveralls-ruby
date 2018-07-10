# Changelog

## HEAD Unreleased
### Latest update: 2018-07-09

### Bug

- [PR #3](https://github.com/Coveralls-Community/coveralls-ruby/pull/3) Remove .bundle folder info from SimpleCov reports [@vbrazo](https://github.com/vbrazo)
- [PR #2](https://github.com/Coveralls-Community/coveralls-ruby/pull/2) Fix relative path of filenames when root path has multiple matches. [@rromanchuk](https://github.com/rromanchuk)

### Chores

- [PR #1](https://github.com/Coveralls-Community/coveralls-ruby/pull/1) Drop 1.8 support, and move some work over from main coveralls [@Ch4s3](https://github.com/Ch4s3)

### Documentation

- [PR #5](https://github.com/Coveralls-Community/coveralls-ruby/pull/5) Add changelog [@vbrazo](https://github.com/vbrazo)

## 0.7.0 (September 18, 2013)

[Full Changelog](https://github.com/lemurheavy/coveralls-ruby/compare/v0.6.4...v0.7.0)

Added:
* output silencing (Thanks @elizabrock)
* ruby warning fixes (Thanks @steveklabnik and @Nucc)

## 0.6.4 (April 2, 2013)

[Full Changelog](https://github.com/lemurheavy/coveralls-ruby/compare/v0.6.3...v0.6.4)

Enhancements:

* Support [Jenkins CI](http://jenkins-ci.org/)
* Support VCR versions <= 2
* Add SimpleCov filter 'vendor' by default.