# Overview
Step 2 is where steps are taken to ensure the branch's integrity. as well as linting the code again to spot out any errors that the pre-commit may have missed out.

# Branch Protection

1. Always do code reviews before committing.
2. Always do pull requests instead of direcly merging into a branch.

# Code Linting
## 1. Create a GitHub Actions workflow.

Create a workflow at `.github/workflows/cpp-linter.yml`.

Workflow code should look something like this:

```yml
name: cpp-linter

on:
  push:
    # Trigger for specific branches
    branches: [ "main" ]
  pull_request:
    types:    [ "closed" ]
    branches: [ "main" ]


jobs:
  cpp-linter:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: cpp-linter/cpp-linter-action@main
        id: linter
        continue-on-error: true
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          style: 'file'  # Use .clang-format config file
          tidy-checks: '' # Use .clang-tidy config file
          # only 'update' a single comment in a pull request's thread.
          files-changed-only: false
          thread-comments: false

      - name: Fail fast?!
        if: steps.linter.outputs.checks-failed != 0
        run: |
          echo "some linter checks failed. ${{ steps.linter.outputs.checks-failed }}"
        # for actual deployment
        # run: exit 1
```

When pushing code and actions run, it will automatically do linting of the code, and warns the user of any errors or warnings, using step summary.

![example_1](/docs/images/linter_image_eg.PNG)

# TruffleHog - Scan for Keys & Secrets
## 1. Create a GitHub Actions workflow.
Create a workflow at `.github/workflows/truffle-hog.yml`.

Workflow code should look something like this:
```yml
name: external tools

on:
  push:
    # Trigger for specific branches
    branches: [ "main" ]
  pull_request:
    types:    [ "closed" ]
    branches: [ "main" ]

# Ensures that GitHub Action workflow has permissions to write comments and update pull requests
permissions:
  contents: read
  id-token: write
  issues: write
  pull-requests: write

jobs:
  truffle-hog:
    runs-on: ubuntu-latest
    defaults:
      run:
        shell: bash
    steps:
      - name: Check code for secrets
        uses: actions/checkout@v4
        with:
          fetch-depth: 0 # this ensures no tags or branches are excluded

      - name: TruffleHog Scanning
        id: trufflehog
        uses: trufflesecurity/trufflehog@main
        with:
          extra_args: --only-verified
```
# Links & Additional Info
### cpp-linter-action
- [cpp-linter-action](https://github.com/cpp-linter/cpp-linter-action)

Additional formatting can be done to show the issues.

With file annotations:
```yaml
        with:
          file-annotations: true
          # can be false
```

With thread comments:
```yaml
        with:
          thread-comments: ${{ github.event_name == 'pull_request' && 'update' }}
          # can be true / false / update
```

With step summary:
```yaml
        with:
          step-summary: true
          # can be false
```

With format review (clang format)
```yaml
        with:
          format-review: false
          # can be true
```

With tidy review (clang tidy)
```yaml
        with:
          tidy-review: false
          # can be true
```
### TruffleHog
- [TruffleHog](https://github.com/trufflesecurity/trufflehog)

TruffleHog has an advanced usage where you can start from a certain branch and end at a certain branch.
```yml
- name: TruffleHog
  uses: trufflesecurity/trufflehog@main
  with:
    # Repository path
    path:
    # Start scanning from here (usually main branch).
    base:
    # Scan commits until here (usually dev branch).
    head: # optional
    # Extra args to be passed to the trufflehog cli.
    extra_args: --debug --only-verified
```
Or to scan an entire branch only.
```yml
- name: scan-push
  uses: trufflesecurity/trufflehog@main
  with:
    base: ""
    head: ${{ github.ref_name }}
    extra_args: --only-verified
```