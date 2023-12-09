# Contributing to Openreads

Thank you for considering contributing to Openreads! Your involvement helps make this app better for everyone. Please take a moment to review this document to understand how you can contribute.

## Table of Contents
1. [About Openreads](#about-openreads)
2. [Types of Contributions](#types-of-contributions)
3. [Code Contribution](#code-contribution-guidelines)
   * [Main guidelines](#main-guidelines)
   * [Running the app](#running-the-app)
   * [Code Formatting](#code-formatting)
   * [Testing](#testing)
4. [Bug Report](#bug-report)
5. [Feature Request](#feature-request)
6. [Contact](#contact)

## About Openreads
Openreads is a free, open-source app designed to track read books with connection to Open Library. Our goal is to provide a privacy-respecting environment for users with no ads and no user tracking.

## Types of Contributions
We welcome various contributions, including code submissions, bug reports, feature requests, translations on Weblate, and participation from learners seeking issues to implement. 

## Code Contribution

### Main guidelines
1. Create a fork and a branch for your contribution.
2. Follow the Angular commits convention. Examples include:
   - `feat: add new feature`
   - `fix: resolve a bug`
   - `chore: update dependencies`
3. Ensure your commits are atomic and have clear messages.
4. Submit a pull request of the "rebase and merge" type.
5. Ensure the pull request's pipeline is passing.

### Running the app

After you have installed [Flutter](https://flutter.dev), then you can start this app by typing the following commands:

```shell
flutter pub get
flutter run
```

### Code Formatting
Ensure that your code follows the Dart formatting conventions. Use the `dart format lib` command from the root of your repo to format your code.

### Testing
Currently, there are no tests in the project, but contributions adding tests are welcome.

## Translations
Go to [Openreads on Weblate](https://hosted.weblate.org/engage/openreads/) and translate the app to the languages you know, You can also vote on other suggestions.

## Bug Report
Use the following template when submitting a bug report:
[Bug report template](.github/ISSUE_TEMPLATE/bug_report.md)

## Feature Request
Use the following template when submitting a feature request:
[Feature request template](.github/ISSUE_TEMPLATE/feature_request.md)

## Decision Making
Decisions are typically made by the project owner. The most important ones are discussed before in the Feature Request issue or in our Matrix chat when we can create polls.

## Contact
If you have any questions or need clarification, ping the maintainer in the PR or ask in the Matrix channel.

Thank you for your contributions to Openreads!
