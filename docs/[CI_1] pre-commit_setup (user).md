# Overview
Step 1 is a check using a tool on the developer side to check the code before they are even committed.

pre-commit is used to run simple hooks to check your code before they are committed to a branch / a pull request.

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

## 4. Run pre-commit install.
Install the pre-commit hooks using `pre-commit install`.

This installs the hooks and sets them up to run automatically before each commit.