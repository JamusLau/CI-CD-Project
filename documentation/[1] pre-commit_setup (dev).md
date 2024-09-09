# Setup
## 1. Ensure Python is installed.
- Minimum Version: **3.6.0**
- Recommended Version: **3.8.0**

Check using `py --version`.

## 2. Ensure pip is installed.
- Minimum Version: **19.2.3**
- Recommeneded Version: **Latest**

Check using `py -m pip --version`.

Upgrade using `py -m pip install --upgrade pip`.

## 3. Install pre-commit package manager.
Install pre-commit package manager using `pip install pre-commit`.

## 4. Create a pre-commit configuration.
Create a file named `.pre-commit-config.yaml` or generate a basic one using `pre-commit sample-config`.

Basic configuration should look something like this:

```
fail_fast: false
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.6.0
    hooks:
      - id: check-merge-conflict
      - id: check-case-conflict
      - id: detect-private-key
      - id: detect-aws-credentials
      - id: trailing-whitespace
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.18.4
    hooks:
      - id: gitleaks
```

## 5. Run pre-commit install.
Install the pre-commit hooks using `pre-commit install`.

This installs the hooks and sets them up to run automatically before each commit.

## 6. Additional Stuff.
You can manually run the pre-commit checks by using `pre-commit run --all-files`.

Auto update hooks using `pre-commit autoupdate`.

# Links
- [pre-commit](https://pre-commit.com/)
- [gitleaks](https://github.com/gitleaks/gitleaks)