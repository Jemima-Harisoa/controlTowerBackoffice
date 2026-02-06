# Git Workflow Guide

## Overview

This document explains the Git branching strategy and workflow for the Control Tower Backoffice project.

## Branch Structure

```
develop
   ↓
feature/xxx
   ↓
develop
   ↓
release/vX   → deployed on STAGING
   ↓
main         → PROD
```

## Branches

### 1. **main** (Production)
- **Purpose**: Production-ready code
- **Protection**: Highly protected, no direct commits
- **Deployment**: Automatically deployed to PRODUCTION
- **Updates**: Only from release branches via Pull Requests

### 2. **develop** (Development)
- **Purpose**: Integration branch for features
- **Protection**: Protected, no direct commits (except hotfixes)
- **Deployment**: Can be deployed to DEV environment
- **Updates**: From feature branches and release branches

### 3. **feature/xxx** (Feature Branches)
- **Purpose**: Individual feature development
- **Naming**: `feature/description-of-feature` (e.g., `feature/user-authentication`)
- **Base**: Created from `develop`
- **Merge to**: `develop` via Pull Request

### 4. **release/vX** (Release Branches)
- **Purpose**: Prepare for production release
- **Naming**: `release/v1.0.0` (follow semantic versioning)
- **Base**: Created from `develop`
- **Deployment**: Deployed to STAGING environment
- **Merge to**: Both `main` and `develop`

---

## Workflow Steps

### Step 1: Create a Feature Branch

Start all new work by creating a feature branch from `develop`.

```bash
# Make sure you're on develop and it's up to date
git checkout develop
git pull origin develop

# Create and switch to a new feature branch
git checkout -b feature/my-new-feature

# Push the branch to remote
git push -u origin feature/my-new-feature
```

**Naming conventions:**
- `feature/user-login`
- `feature/api-integration`
- `feature/dashboard-redesign`
- `bugfix/fix-login-error`
- `hotfix/critical-security-patch`

### Step 2: Work on Your Feature

Make your changes and commit regularly:

```bash
# Stage your changes
git add .

# Commit with a meaningful message
git commit -m "Add user authentication functionality"

# Push to remote
git push origin feature/my-new-feature
```

**Commit message best practices:**
- Use present tense: "Add feature" not "Added feature"
- Be descriptive but concise
- Reference issue numbers if applicable: "Fix #123: Resolve login bug"

### Step 3: Create a Pull Request to develop

Once your feature is complete:

1. **Push your latest changes:**
   ```bash
   git push origin feature/my-new-feature
   ```

2. **Create Pull Request on GitHub:**
   - Go to your repository on GitHub
   - Click "Pull requests" → "New pull request"
   - **Base**: `develop`
   - **Compare**: `feature/my-new-feature`
   - Add a descriptive title and description
   - Request reviewers if needed
   - Click "Create pull request"

3. **Wait for review and approval**

4. **Merge the PR:**
   - Once approved, merge using "Squash and merge" or "Merge commit"
   - Delete the feature branch after merging

5. **Update your local develop:**
   ```bash
   git checkout develop
   git pull origin develop
   ```

### Step 4: Create a Release Branch

When `develop` has enough features for a release:

```bash
# Make sure develop is up to date
git checkout develop
git pull origin develop

# Create a release branch
git checkout -b release/v1.0.0

# Push to remote
git push -u origin release/v1.0.0
```

**In the release branch:**
- Fix bugs found during testing
- Update version numbers
- Update CHANGELOG
- Update documentation
- **NO new features**

```bash
# Make final adjustments
git add .
git commit -m "Bump version to v1.0.0"
git push origin release/v1.0.0
```

**Deploy to STAGING:**
- This branch is automatically or manually deployed to the STAGING environment
- Perform thorough testing in STAGING

### Step 5: Merge Release to main (Production)

Once STAGING testing is complete:

1. **Create PR from release to main:**
   - **Base**: `main`
   - **Compare**: `release/v1.0.0`
   - Add release notes
   - Get final approval

2. **Merge to main:**
   ```bash
   # After PR is approved and merged on GitHub
   git checkout main
   git pull origin main
   
   # Tag the release
   git tag -a v1.0.0 -m "Release version 1.0.0"
   git push origin v1.0.0
   ```

3. **Merge release back to develop:**
   Create another PR:
   - **Base**: `develop`
   - **Compare**: `release/v1.0.0`
   - This ensures any release fixes are in develop

4. **Clean up:**
   ```bash
   # Delete the release branch (optional, after merging)
   git branch -d release/v1.0.0
   git push origin --delete release/v1.0.0
   ```

---

## Cherry-Pick Guide

Cherry-picking allows you to apply specific commits from one branch to another.

### When to Use Cherry-Pick

- Apply a hotfix to multiple branches
- Move a commit that was made to the wrong branch
- Apply specific bug fixes from develop to a release branch

### How to Cherry-Pick

**1. Find the commit hash:**
```bash
# View commit history
git log --oneline

# Example output:
# abc1234 Fix critical bug
# def5678 Add new feature
```

**2. Switch to the target branch:**
```bash
git checkout target-branch
git pull origin target-branch
```

**3. Cherry-pick the commit:**
```bash
# Cherry-pick a single commit
git cherry-pick abc1234

# Cherry-pick multiple commits
git cherry-pick abc1234 def5678

# Cherry-pick without committing (to review first)
git cherry-pick -n abc1234
```

**4. Resolve conflicts if any:**
```bash
# If there are conflicts, resolve them manually
# Then stage the resolved files
git add .

# Continue the cherry-pick
git cherry-pick --continue

# Or abort if needed
git cherry-pick --abort
```

**5. Push the changes:**
```bash
git push origin target-branch
```

### Cherry-Pick Example Scenarios

**Scenario 1: Hotfix to Production**
```bash
# Create hotfix branch from main
git checkout main
git pull origin main
git checkout -b hotfix/critical-fix

# Make the fix and commit
git add .
git commit -m "Fix critical security issue"

# Merge to main via PR, then cherry-pick to develop
git checkout develop
git pull origin develop
git cherry-pick <hotfix-commit-hash>
git push origin develop
```

**Scenario 2: Move Commit to Correct Branch**
```bash
# You committed to develop instead of your feature branch
# Get the commit hash
git log --oneline -1  # abc1234

# Switch to the correct branch
git checkout feature/my-feature

# Cherry-pick the commit
git cherry-pick abc1234

# Remove from develop (if not pushed yet)
git checkout develop
git reset --hard HEAD~1
```

---

## Pull Request Best Practices

### Creating a Good PR

1. **Write a clear title:**
   - ✅ "Add user authentication with OAuth2"
   - ❌ "Updates"

2. **Provide detailed description:**
   ```markdown
   ## What
   Implements user authentication using OAuth2
   
   ## Why
   Users need to securely log in to the application
   
   ## How
   - Added OAuth2 library
   - Created login/logout endpoints
   - Integrated with existing user model
   
   ## Testing
   - Tested login flow
   - Tested logout flow
   - Added unit tests
   
   ## Screenshots
   [If applicable]
   ```

3. **Keep PRs small:**
   - Easier to review
   - Faster to merge
   - Less likely to have conflicts

4. **Link to issues:**
   - "Closes #123"
   - "Fixes #456"
   - "Related to #789"

### Reviewing PRs

**As a reviewer:**
- Check code quality
- Verify tests exist
- Look for security issues
- Ensure documentation is updated
- Test locally if needed

**Commands for reviewing:**
```bash
# Fetch the PR branch
git fetch origin pull/123/head:pr-123
git checkout pr-123

# Test the changes
npm install  # or your build command
npm test     # or your test command

# Return to your branch
git checkout develop
```

### Merging Strategies

**Merge Commit (default):**
- Preserves all commits
- Creates a merge commit
- Best for: feature branches with meaningful history

**Squash and Merge:**
- Combines all commits into one
- Cleaner history
- Best for: many small commits that should be one logical change

**Rebase and Merge:**
- Replays commits on top of base branch
- Linear history
- Best for: when you want to maintain individual commits but have a linear history

---

## Quick Reference

### Common Commands

```bash
# Create and switch to a new branch
git checkout -b branch-name

# Switch to an existing branch
git checkout branch-name

# Update current branch from remote
git pull origin branch-name

# Stage changes
git add .                    # Stage all changes
git add file1.txt file2.txt  # Stage specific files

# Commit changes
git commit -m "Message"

# Push changes
git push origin branch-name

# View status
git status

# View commit history
git log --oneline
git log --graph --oneline --all

# View changes
git diff                     # Unstaged changes
git diff --staged            # Staged changes

# Undo changes
git checkout -- file.txt     # Discard changes in working directory
git reset HEAD file.txt      # Unstage file
git reset --hard HEAD~1      # Undo last commit (DANGEROUS)

# Cherry-pick
git cherry-pick <commit-hash>

# Create tag
git tag -a v1.0.0 -m "Version 1.0.0"
git push origin v1.0.0
```

### Workflow Cheatsheet

```bash
# 1. Start new feature
git checkout develop
git pull origin develop
git checkout -b feature/my-feature

# 2. Work and commit
git add .
git commit -m "Add feature"
git push origin feature/my-feature

# 3. Create PR to develop (on GitHub)
# 4. After merge, update develop
git checkout develop
git pull origin develop

# 5. Create release (when ready)
git checkout -b release/v1.0.0
git push origin release/v1.0.0
# Deploy to STAGING

# 6. Merge to main (via PR on GitHub)
# 7. Tag release
git checkout main
git pull origin main
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0

# 8. Merge release back to develop (via PR)
```

---

## Troubleshooting

### Merge Conflicts

When you encounter merge conflicts:

```bash
# Pull the latest changes
git pull origin develop

# Conflicts will be marked in files like:
<<<<<<< HEAD
Your changes
=======
Their changes
>>>>>>> develop

# 1. Open the file and resolve conflicts
# 2. Remove conflict markers
# 3. Keep the correct code
# 4. Stage the resolved file
git add resolved-file.txt

# 5. Complete the merge
git commit -m "Resolve merge conflicts"
git push origin your-branch
```

### Accidentally Committed to Wrong Branch

```bash
# If not pushed yet
git reset --soft HEAD~1  # Undo commit, keep changes
git stash               # Stash changes
git checkout correct-branch
git stash pop           # Apply changes
git add .
git commit -m "Correct commit message"

# If already pushed
# Use cherry-pick (see Cherry-Pick section)
```

### Need to Update Feature Branch with Latest develop

```bash
# Option 1: Merge (preserves history)
git checkout feature/my-feature
git merge develop
git push origin feature/my-feature

# Option 2: Rebase (cleaner history)
git checkout feature/my-feature
git rebase develop
# Resolve conflicts if any
git push origin feature/my-feature --force-with-lease
```

---

## Additional Resources

- [Git Official Documentation](https://git-scm.com/doc)
- [GitHub Flow Guide](https://guides.github.com/introduction/flow/)
- [Semantic Versioning](https://semver.org/)
- [Conventional Commits](https://www.conventionalcommits.org/)

---

## Questions?

If you have questions about this workflow, please:
1. Check this documentation first
2. Ask your team lead
3. Create an issue in the repository
