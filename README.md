# campus-app

A campus events app built with **Flutter** (frontend) and **Serverpod**
(backend) on **PostgreSQL**.

| Path         | Description                                                       |
| ------------ | ----------------------------------------------------------------- |
| `campus_quiz/` | The Dart pub workspace: the app, the generated client and the backend. See [campus_quiz/README.md](campus_quiz/README.md) for the setup, the API and the tests. |
| `.github/workflows/` | The continuous integration.                                  |

## Continuous integration

| Workflow         | What it does                                                            |
| ---------------- | ----------------------------------------------------------------------- |
| `analyze.yml`    | `dart analyze` for the server and `flutter analyze` for the app.          |
| `format.yml`     | Checks the formatting of the server and the app.                          |
| `tests.yml`      | Runs the server tests and the app tests.                                 |
| `auto-merge.yml` | Runs the three checks on a `feat/**` or `fix/**` branch and merges it into `main` when they all pass. |

### Shipping a change without a pull request

Push the branch and the CI takes it from there:

```sh
git push origin feat/my-change
```

The `Auto merge` workflow runs the analyze, format and test checks on the
branch. When they pass, the branch is merged into `main` with a merge commit.
When a check fails, nothing is merged and the workflow turns red.

A branch can also be merged by hand from the Actions tab with the `Auto merge`
workflow, which asks for the branch to merge.

Two things to know about the merge:

- It is made with the workflow's own token. GitHub does not start another run
  of the workflows for a push made with that token, so `main` does not get a
  second set of checks. The checks that ran on the branch cover the same
  commits.
- The workflow needs write access to `main`. If `main` is protected, allow the
  workflow to push to it in the repository settings, otherwise the merge is
  refused.

Pull requests still work: the same checks run on a pull request and on every
push to `main`.
