# Git & Deployment Cheatsheet 📋

Quick reference for common Git commands and deployment workflow.

---

## 🌿 Branch Workflow

```
develop → feature/xxx → develop → release/vX → main
                                    (STAGING)   (PROD)
```

---

## 🚀 Common Git Commands

### Create & Switch Branches

```bash
# Create new feature branch
git checkout develop
git pull origin develop
git checkout -b feature/my-feature
git push -u origin feature/my-feature

# Create release branch
git checkout develop
git checkout -b release/v1.0.0
git push -u origin release/v1.0.0
```

### Commit & Push

```bash
# Stage and commit
git add .
git commit -m "Your message"
git push origin branch-name

# Amend last commit (if not pushed)
git commit --amend -m "New message"
```

### Update Your Branch

```bash
# Update from remote
git pull origin branch-name

# Merge develop into feature
git checkout feature/my-feature
git merge develop
git push origin feature/my-feature

# Rebase on develop (alternative)
git checkout feature/my-feature
git rebase develop
git push origin feature/my-feature --force-with-lease
```

### Cherry-Pick

```bash
# Pick specific commit to current branch
git log --oneline              # Find commit hash
git cherry-pick abc1234        # Apply commit
git push origin branch-name    # Push changes

# Cherry-pick multiple commits
git cherry-pick abc1234 def5678

# Cherry-pick with review first
git cherry-pick -n abc1234
git status
git commit
```

### View & Compare

```bash
# View status
git status
git status -s                  # Short format

# View history
git log --oneline
git log --oneline -10          # Last 10 commits
git log --graph --oneline --all

# View changes
git diff                       # Unstaged changes
git diff --staged              # Staged changes
git diff branch1 branch2       # Compare branches
git diff commit1 commit2       # Compare commits
```

### Undo Changes

```bash
# Discard unstaged changes
git checkout -- file.txt
git restore file.txt           # Git 2.23+

# Unstage file
git reset HEAD file.txt
git restore --staged file.txt  # Git 2.23+

# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes) ⚠️
git reset --hard HEAD~1
```

### Tags

```bash
# Create annotated tag
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0

# List tags
git tag
git tag -l "v1.*"

# Delete tag
git tag -d v1.0.0
git push origin --delete v1.0.0
```

---

## 📋 Pull Request Checklist

Before creating PR:

- [ ] Branch is up to date with base branch
- [ ] Code is tested locally
- [ ] Commits have clear messages
- [ ] No merge conflicts
- [ ] No sensitive data in commits

PR Description should include:

- [ ] What: Brief description of changes
- [ ] Why: Reason for changes
- [ ] How: Technical approach
- [ ] Testing: How it was tested
- [ ] Screenshots (if UI changes)

---

## 🔄 Complete Workflow

### 1️⃣ Start Feature

```bash
git checkout develop
git pull origin develop
git checkout -b feature/user-auth
```

### 2️⃣ Work on Feature

```bash
# Make changes
git add .
git commit -m "Add login endpoint"
git push origin feature/user-auth
```

### 3️⃣ Create PR to develop

```
On GitHub:
Base: develop ← Compare: feature/user-auth
→ Create Pull Request
→ Get approval
→ Merge (Squash and merge)
```

### 4️⃣ Create Release

```bash
git checkout develop
git pull origin develop
git checkout -b release/v1.0.0
git push origin release/v1.0.0

# → Auto-deploys to STAGING
# → Test thoroughly
```

### 5️⃣ Deploy to Production

```
On GitHub:
Base: main ← Compare: release/v1.0.0
→ Create Pull Request
→ Get approval
→ Merge

Then:
```

```bash
git checkout main
git pull origin main
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0

# → Auto-deploys to PRODUCTION
```

### 6️⃣ Merge Back to develop

```
On GitHub:
Base: develop ← Compare: release/v1.0.0
→ Create Pull Request
→ Merge
```

---

## 🚀 Railway Deployment

### Initial Setup

```bash
1. Go to https://railway.app
2. Login with GitHub
3. "New Project" → "Deploy from GitHub repo"
4. Select repository
5. Add environment variables
6. Deploy!
```

### Environment Setup

**Production (main branch):**
- Branch: `main`
- URL: `https://your-app.up.railway.app`
- Auto-deploy: ON

**Staging (release/develop):**
- Branch: `develop` or `release/*`
- URL: `https://your-app-staging.up.railway.app`
- Auto-deploy: ON

### Environment Variables

```
NODE_ENV=production
PORT=3000
DATABASE_URL=postgresql://...
API_KEY=your-secret-key
```

### Monitor Deployment

```
Railway Dashboard → Deployments → View Logs
```

---

## 🆘 Troubleshooting

### Merge Conflicts

```bash
# Pull latest changes
git pull origin develop

# Resolve conflicts in files:
# 1. Open file
# 2. Remove <<<<<<, ======, >>>>>> markers
# 3. Keep correct code

git add resolved-file.txt
git commit -m "Resolve merge conflicts"
git push
```

### Committed to Wrong Branch

```bash
# Not pushed yet
git reset --soft HEAD~1
git stash
git checkout correct-branch
git stash pop
git add .
git commit -m "Correct message"

# Already pushed - use cherry-pick
git checkout correct-branch
git cherry-pick <commit-hash>
```

### Forgot to Pull Before Committing

```bash
# Pull with rebase
git pull --rebase origin branch-name

# Or pull and merge
git pull origin branch-name
# Resolve conflicts if any
git push origin branch-name
```

---

## 💡 Pro Tips

### Commit Messages

✅ Good:
```
Add user authentication
Fix login bug for mobile users
Update API documentation
```

❌ Bad:
```
Updates
Fixed stuff
WIP
```

### Keep PRs Small

- ✅ 1 feature per PR
- ✅ Max 300-400 lines changed
- ❌ Multiple features in one PR
- ❌ 1000+ lines changed

### Clean History

```bash
# Squash multiple commits before PR
git rebase -i HEAD~3

# Mark commits as 'squash' or 'fixup'
# Rewrite commit message
```

---

## 🔗 Quick Links

- [Full Git Workflow](WORKFLOW.md)
- [Deployment Guide](DEPLOYMENT.md)
- [Railway Docs](https://docs.railway.app/)
- [Git Docs](https://git-scm.com/doc)

---

## 📞 Need Help?

1. Check [WORKFLOW.md](WORKFLOW.md)
2. Check [DEPLOYMENT.md](DEPLOYMENT.md)
3. Ask team lead
4. Create issue on GitHub

---

**Print this and keep it handy! 📌**
