We love pull requests. Here's a quick guide:

1. Fork the repo.

2. Run the tests. We only take pull requests with passing tests, and it's great
to know that you have a clean slate: `bundle exec rspec`

3. Please add a test for your change. Only refactoring and documentation changes require no new tests. If you are adding functionality or fixing a bug, we need a test! We use [Rspec](http://rspec.info/) in this project. If you're not familiar with Minitest and are comfortable with Rspec, please ask a contributor/collaborator to review your PR.

4. We care about code coverage and use `SimpleCov` to analyze the code and generate
test coverage reports.

5. Push to your fork and submit a pull request.

### Github Flow for contributors and collaborators

For those of you with commit access, please check out Scott Chacon's blog post about [github flow](http://scottchacon.com/2011/08/31/github-flow.html)

> * Anything in the master branch is deployable
> * To work on something new, create a descriptively named branch off of master (ie: new-oauth2-scopes)
> * Commit to that branch locally and regularly push your work to the same named branch on the server
> * When you need feedback or help, or you think the branch is ready for merging, open a pull request
> * After someone else has reviewed and signed off on the feature, you can merge it into master

If you're reviewing a PR, you should ask youserlf:
> * Does it work as described? A PR should have a great description.
> * Is it understandable?
> * Is it well implemented?
> * Is it well tested?
> * Is it well documented?
> * Is it following the structure of the project?
