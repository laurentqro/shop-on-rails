# Git Hooks

This directory contains git hooks for the project.

## Installation

To install the git hooks, run:

```bash
ln -sf ../../bin/git-hooks/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

Or simply run this one-liner from the project root:

```bash
ln -sf ../../bin/git-hooks/pre-commit .git/hooks/pre-commit && chmod +x .git/hooks/pre-commit
```

## Available Hooks

### pre-commit

Runs RuboCop on all staged Ruby files before allowing a commit.

- **What it does:** Automatically checks code style on staged files
- **When it runs:** Before each `git commit`
- **How to bypass:** Use `git commit --no-verify` (not recommended)
- **Auto-fix issues:** Run `bundle exec rubocop -a` to auto-correct some issues

## Why Git Hooks?

Git hooks help maintain code quality by:
- Catching style issues before they reach the repository
- Enforcing consistent code standards across the team
- Reducing code review friction
- Preventing broken code from being committed
