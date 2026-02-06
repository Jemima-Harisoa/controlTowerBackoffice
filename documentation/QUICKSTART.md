# Quick Start Guide 🚀

Welcome to the Control Tower Backoffice project! This guide will help you get started quickly.

## 📚 Documentation Index

All the documentation you need is right here:

| Document | Purpose | When to Use |
|----------|---------|-------------|
| [README.md](README.md) | Project overview and quick links | Start here! |
| [WORKFLOW.md](WORKFLOW.md) | Complete Git workflow guide | When working with Git |
| [DEPLOYMENT.md](DEPLOYMENT.md) | Deployment instructions | When deploying to staging/production |
| [CHEATSHEET.md](CHEATSHEET.md) | Quick command reference | Keep this handy for daily use |
| [CONTRIBUTING.md](CONTRIBUTING.md) | How to contribute | Before making your first PR |

## ⚡ 5-Minute Setup

### 1. Clone and Setup (1 min)

```bash
# Clone the repository
git clone https://github.com/Jemima-Harisoa/controlTowerBackoffice.git
cd controlTowerBackoffice

# Install dependencies (if applicable)
npm install  # or yarn install, or pip install -r requirements.txt
```

### 2. Configure Environment (2 min)

```bash
# Copy environment template
cp .env.example .env

# Edit .env and add your values
# Use your favorite editor (nano, vim, vscode, etc.)
nano .env
```

### 3. Start Development (2 min)

```bash
# Start the development server
npm run dev  # or your specific command

# Open your browser
# Visit http://localhost:3000 (or your configured port)
```

## 🔄 Daily Workflow

### Morning Routine ☕

```bash
# Update develop branch
git checkout develop
git pull origin develop

# Create your feature branch
git checkout -b feature/what-you-are-working-on
```

### During Work 💻

```bash
# Make changes to your code
# ...

# Check what changed
git status
git diff

# Stage and commit
git add .
git commit -m "Describe what you did"

# Push to remote
git push origin feature/what-you-are-working-on
```

### End of Day 🌙

```bash
# Make sure everything is committed and pushed
git status
git push origin feature/what-you-are-working-on
```

### When Feature is Complete ✅

```bash
# Push final changes
git push origin feature/what-you-are-working-on

# Go to GitHub and create a Pull Request
# Base: develop ← Compare: feature/what-you-are-working-on
```

## 🎯 Common Tasks

### Task: Start a New Feature

```bash
git checkout develop
git pull origin develop
git checkout -b feature/my-feature
# ... work on your feature ...
git add .
git commit -m "Add my feature"
git push origin feature/my-feature
# Create PR on GitHub: feature/my-feature → develop
```

### Task: Update Your Branch with Latest develop

```bash
git checkout develop
git pull origin develop
git checkout feature/my-feature
git merge develop
# Resolve conflicts if any
git push origin feature/my-feature
```

### Task: Fix a Bug

```bash
git checkout develop
git pull origin develop
git checkout -b bugfix/fix-description
# ... fix the bug ...
git add .
git commit -m "Fix: description of bug fix"
git push origin bugfix/fix-description
# Create PR on GitHub: bugfix/fix-description → develop
```

### Task: Deploy to Staging

```bash
# Create release branch
git checkout develop
git pull origin develop
git checkout -b release/v1.0.0
git push origin release/v1.0.0

# Railway automatically deploys release/v1.0.0 to STAGING
# Test on staging URL: https://your-app-staging.up.railway.app
```

### Task: Deploy to Production

```bash
# After testing on STAGING
# Create PR on GitHub: release/v1.0.0 → main
# Get approval and merge

# Tag the release
git checkout main
git pull origin main
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0

# Merge back to develop
# Create PR on GitHub: release/v1.0.0 → develop
# Merge it
```

## 🆘 Help! Something Went Wrong

### "I committed to the wrong branch!"

```bash
# If not pushed yet
git reset --soft HEAD~1
git stash
git checkout correct-branch
git stash pop
git add .
git commit -m "Your message"
git push

# If already pushed
git checkout correct-branch
git cherry-pick <commit-hash>
git push
```

### "I have merge conflicts!"

```bash
# Pull the latest changes
git pull origin develop

# Open files with conflicts
# Look for <<<<<<< HEAD, =======, >>>>>>> markers
# Edit the file to resolve conflicts
# Remove the markers

# After resolving
git add resolved-file.txt
git commit -m "Resolve merge conflicts"
git push
```

### "I need to undo my last commit"

```bash
# Undo but keep changes (safest)
git reset --soft HEAD~1
# Your changes are now unstaged

# Undo and discard changes (DANGEROUS)
git reset --hard HEAD~1
# Your changes are GONE!
```

### "My branch is behind develop"

```bash
git checkout develop
git pull origin develop
git checkout my-branch
git merge develop
git push origin my-branch
```

## 🔑 Essential Git Commands

```bash
# View changes
git status                    # What changed
git diff                      # See unstaged changes
git log --oneline            # View commit history

# Branching
git branch                   # List branches
git checkout -b new-branch   # Create and switch to branch
git checkout branch-name     # Switch to existing branch

# Committing
git add .                    # Stage all changes
git add file.txt            # Stage specific file
git commit -m "Message"     # Commit with message

# Syncing
git pull origin branch      # Get latest changes
git push origin branch      # Push your changes
git fetch origin           # Fetch without merging

# Undoing
git checkout -- file.txt   # Discard changes in file
git reset HEAD file.txt    # Unstage file
git revert <commit>       # Create new commit that undoes
```

## 🌐 Deployment Quick Reference

### Railway Setup (One-Time)

1. Sign up at https://railway.app with GitHub
2. Create "New Project" → "Deploy from GitHub repo"
3. Select this repository
4. Add environment variables from `.env.example`
5. Configure:
   - **Production**: Deploy from `main` branch
   - **Staging**: Deploy from `develop` or `release/*` branches
6. Done! Railway auto-deploys on push

### Check Deployment Status

```bash
# Production
https://your-app.up.railway.app

# Staging
https://your-app-staging.up.railway.app
```

### View Logs

1. Go to Railway dashboard
2. Select your project
3. Click "Deployments"
4. Click on active deployment
5. View logs in real-time

## 📖 Learn More

### Recommended Reading Order

1. **Day 1**: [README.md](README.md) + [CHEATSHEET.md](CHEATSHEET.md)
2. **Week 1**: [WORKFLOW.md](WORKFLOW.md) + [CONTRIBUTING.md](CONTRIBUTING.md)
3. **When deploying**: [DEPLOYMENT.md](DEPLOYMENT.md)

### Video Tutorials (External)

- [Git & GitHub for Beginners](https://www.youtube.com/watch?v=RGOj5yH7evk)
- [Git Branching Strategies](https://www.youtube.com/watch?v=gW6dFpTMk8s)
- [Railway Deployment Tutorial](https://www.youtube.com/results?search_query=railway+deployment)

### Interactive Learning

- [Learn Git Branching](https://learngitbranching.js.org/) - Interactive visual tool
- [GitHub Learning Lab](https://lab.github.com/)
- [Git Exercises](https://gitexercises.fracz.com/)

## 💡 Pro Tips

1. **Commit often** - Small, frequent commits are better than large ones
2. **Pull before you push** - Always pull latest changes before pushing
3. **Write clear commit messages** - Your future self will thank you
4. **Test locally** - Don't push broken code
5. **Use branches** - Never commit directly to develop or main
6. **Ask for help** - Don't struggle alone, ask your team!

## 🎓 For Broke Students

### Free Tools & Resources

- **Railway**: $5/month free credit (enough for small projects)
- **GitHub Education Pack**: Free credits for various services
  - https://education.github.com/pack
- **Free domains**: Freenom, .tk domains
- **Free SSL**: Let's Encrypt (automatic with Railway)
- **Free database**: Railway PostgreSQL (500MB free)

### Cost-Saving Tips

1. Use Railway's free tier (monitor usage)
2. Put staging to sleep when not testing
3. Use SQLite for development
4. Share resources between projects
5. Apply for GitHub Student Developer Pack

## ✅ Checklist for Success

### Before You Start Coding

- [ ] Repository cloned
- [ ] Dependencies installed
- [ ] `.env` file configured
- [ ] Development server running
- [ ] You understand the workflow

### Before Creating a PR

- [ ] Code tested locally
- [ ] Branch up to date with develop
- [ ] Commits have clear messages
- [ ] No console errors
- [ ] No merge conflicts

### Before Deploying to Production

- [ ] Tested on STAGING
- [ ] All tests pass
- [ ] Team approved
- [ ] Documentation updated
- [ ] Database migrations ready (if any)

## 🎉 You're Ready!

You now have everything you need to start contributing! Don't worry if it seems like a lot - you'll get comfortable with the workflow quickly.

### Next Steps

1. ✅ Make sure your environment is set up
2. 📖 Read [WORKFLOW.md](WORKFLOW.md) sections 1-3
3. 🔍 Look for issues labeled `good first issue`
4. 💬 Introduce yourself to the team
5. 🚀 Start coding!

### Remember

- **There are no stupid questions** - ask when you're unsure
- **Everyone makes mistakes** - it's part of learning
- **Git is your friend** - you can almost always undo things
- **Have fun!** - Coding should be enjoyable

---

**Need help?** Check the docs, ask your team, or create an issue!

**Happy coding! 🎊**
