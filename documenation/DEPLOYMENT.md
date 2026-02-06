# Deployment Guide for Broke Students 🎓💰

## Overview

This guide helps you deploy your Control Tower Backoffice application on the cheapest hosting platform suitable for students on a tight budget.

---

## Hosting Platform Comparison

### 1. Railway 🚂
**Best for: Node.js, Python, Go applications with databases**

**Pricing:**
- ✅ **FREE tier**: $5 credit/month (500 hours of usage)
- After free tier: $0.000231/GB-hour RAM + $0.000463/vCPU-hour
- Estimated cost: **$5-10/month** for small projects

**Pros:**
- Easy deployment from GitHub
- Automatic HTTPS
- Built-in databases (PostgreSQL, MySQL, MongoDB, Redis)
- Environment variables management
- Automatic deployments on push
- Generous free tier for students

**Cons:**
- Limited free tier (usage-based)
- Can get expensive with high traffic
- Less control than VPS

**Official Website:** https://railway.app

---

### 2. Googiehost 🌐
**Note:** Googiehost appears to be a budget shared hosting provider.

**Pricing:**
- Shared hosting: ~$1-3/month
- Basic VPS: ~$3-5/month

**Pros:**
- Very cheap
- Traditional cPanel hosting
- Good for PHP/MySQL applications

**Cons:**
- Limited for modern frameworks
- Shared resources
- Less suitable for Node.js/Python backends
- May have restrictions on long-running processes
- Limited scalability

---

### 3. Ultahost 🌍
**Budget hosting provider**

**Pricing:**
- Shared hosting: ~$2-4/month
- VPS starting: ~$5-7/month

**Pros:**
- Affordable pricing
- cPanel access
- SSL certificates included
- Good for WordPress/PHP sites

**Cons:**
- Shared resources on cheap plans
- Limited support for modern frameworks
- May not support Node.js well on shared plans

---

## 🏆 RECOMMENDED: Railway (Best for This Project)

**Why Railway wins for broke students:**
1. **$5 FREE credit every month** - enough for small projects
2. **Zero setup complexity** - deploy in minutes
3. **Automatic deployments** from GitHub
4. **Free databases included** (PostgreSQL, MySQL, etc.)
5. **HTTPS automatically configured**
6. **Perfect for Node.js, Python, Go** backends
7. **Easy environment management** (STAGING/PROD)

**Alternative Free/Cheap Options:**
- **Render.com**: Free tier for static sites + $7/month for web services
- **Fly.io**: Free tier included (3 shared VMs, 3GB storage)
- **Heroku**: Free tier discontinued, but eco plan at $5/month
- **Vercel**: Free for frontend (Next.js, React, etc.)
- **Netlify**: Free for static sites

---

## Deployment on Railway (Step-by-Step)

### Prerequisites

Before deploying, ensure your project has:

1. **A `package.json` file** (for Node.js) or equivalent for your stack
2. **Environment variables documented** (create `.env.example`)
3. **A start command** defined in `package.json`
4. **Database migrations** (if using a database)

### Step 1: Prepare Your Repository

**1.1. Create `.env.example` file:**

```bash
# Create example env file
cat > .env.example << 'EOF'
# Application
NODE_ENV=production
PORT=3000

# Database (PostgreSQL example)
DATABASE_URL=postgresql://user:password@host:port/dbname

# API Keys (example)
API_SECRET_KEY=your-secret-key
JWT_SECRET=your-jwt-secret

# Railway (auto-provided)
RAILWAY_ENVIRONMENT=production
EOF
```

**1.2. Ensure your `package.json` has start script:**

```json
{
  "scripts": {
    "start": "node server.js",
    "dev": "nodemon server.js",
    "build": "echo 'Build step if needed'"
  }
}
```

**1.3. Create `.gitignore` (if not exists):**

```bash
cat > .gitignore << 'EOF'
node_modules/
.env
.DS_Store
*.log
dist/
build/
.railway/
EOF
```

### Step 2: Sign Up for Railway

1. Go to https://railway.app
2. Click **"Login"** or **"Start a New Project"**
3. **Sign in with GitHub** (recommended for easy deployment)
4. Authorize Railway to access your repositories

### Step 3: Create a New Project

**3.1. From GitHub Repository:**

```
1. Click "New Project"
2. Select "Deploy from GitHub repo"
3. Choose your repository: "controlTowerBackoffice"
4. Railway will detect your framework automatically
```

**3.2. Railway will:**
- Detect your project type (Node.js, Python, etc.)
- Set up build and start commands automatically
- Create a deployment environment

### Step 4: Configure Environment Variables

**4.1. Add environment variables:**

```
1. In your Railway project, click "Variables"
2. Add each environment variable:
   - NODE_ENV = production
   - PORT = 3000
   - DATABASE_URL = (if using Railway database, see step 5)
   - API_SECRET_KEY = your-secret-key
   - Any other required variables
```

**4.2. Railway-specific variables:**
Railway automatically provides:
- `PORT` (will override if you set it)
- `RAILWAY_ENVIRONMENT`
- `RAILWAY_SERVICE_NAME`

### Step 5: Add a Database (Optional)

**5.1. Add PostgreSQL:**

```
1. In your project, click "New"
2. Select "Database" → "Add PostgreSQL"
3. Railway creates the database automatically
4. Copy the DATABASE_URL from the PostgreSQL service
5. Add it to your application's variables (or it may be auto-linked)
```

**5.2. Other databases available:**
- MySQL
- MongoDB
- Redis
- Even custom Docker containers

### Step 6: Set Up Environments (STAGING & PROD)

**6.1. Create STAGING environment:**

```
1. In your project, click the environment dropdown (default is "production")
2. Click "New Environment"
3. Name it "staging"
4. Deploy your "release/vX" branch to staging
```

**6.2. Set up branch deployments:**

For **PRODUCTION** environment:
```
1. Go to Settings → "Service Settings"
2. Under "Source", set branch to "main"
3. Enable "Automatic Deployments"
```

For **STAGING** environment:
```
1. Switch to "staging" environment
2. Go to Settings → "Service Settings"
3. Set branch to "develop" or "release/*"
4. Enable "Automatic Deployments"
```

**6.3. Environment-specific variables:**

You can set different variables per environment:
```
Production environment:
  - DATABASE_URL = prod-database-url
  - NODE_ENV = production

Staging environment:
  - DATABASE_URL = staging-database-url
  - NODE_ENV = staging
```

### Step 7: Deploy

**7.1. Automatic deployment:**

Once configured, Railway automatically deploys when you:
- Push to `main` (PROD environment)
- Push to `develop` or `release/*` (STAGING environment)

**7.2. Manual deployment:**

```
1. Go to your Railway project
2. Click "Deployments"
3. Click "Deploy" on the latest commit
```

**7.3. Monitor deployment:**

```
1. Click on the active deployment
2. View build logs in real-time
3. Check for errors
4. Once successful, you'll get a URL: https://your-project.up.railway.app
```

### Step 8: Custom Domain (Optional)

**8.1. Add custom domain:**

```
1. Go to "Settings" → "Domains"
2. Click "Custom Domain"
3. Enter your domain (e.g., api.yourdomain.com)
4. Update your DNS records as instructed:
   - Type: CNAME
   - Name: api (or @)
   - Value: your-project.up.railway.app
```

**8.2. Get a free domain:**
- https://www.freenom.com (free domains)
- https://www.dot.tk (.tk domains)
- Or use Railway's provided subdomain

### Step 9: Verify Deployment

**9.1. Test your deployment:**

```bash
# Test the endpoint
curl https://your-project.up.railway.app

# Or visit in browser
```

**9.2. Check logs:**

```
1. In Railway, go to "Deployments"
2. Click on your active deployment
3. Click "View Logs"
4. Monitor application logs in real-time
```

### Step 10: Set Up CI/CD with GitHub

Railway automatically deploys on push, but you can add GitHub Actions for testing first:

**10.1. Create `.github/workflows/deploy.yml`:**

```yaml
name: Test and Deploy

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      - name: Install dependencies
        run: npm ci
      - name: Run tests
        run: npm test
      - name: Run linter
        run: npm run lint

  # Railway deploys automatically, but you can add custom steps here
```

---

## Complete Workflow with Deployment

### Development → Staging → Production

**1. Work on a feature:**

```bash
# Create feature branch
git checkout develop
git pull origin develop
git checkout -b feature/new-feature

# Make changes, commit, push
git add .
git commit -m "Add new feature"
git push origin feature/new-feature
```

**2. Merge to develop:**

```bash
# Create PR on GitHub: feature/new-feature → develop
# After approval and merge:

git checkout develop
git pull origin develop

# Railway can auto-deploy develop to STAGING if configured
```

**3. Create release for STAGING:**

```bash
# Create release branch
git checkout -b release/v1.0.0
git push origin release/v1.0.0

# Railway deploys release/v1.0.0 to STAGING automatically
# Test on: https://your-project-staging.up.railway.app
```

**4. Deploy to PRODUCTION:**

```bash
# After testing on STAGING, create PR: release/v1.0.0 → main
# After approval and merge:

git checkout main
git pull origin main

# Railway deploys main to PRODUCTION automatically
# Live on: https://your-project.up.railway.app

# Tag the release
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0

# Merge back to develop
# Create PR: release/v1.0.0 → develop
```

---

## Cost Management Tips 💰

### Maximizing Railway's Free Tier

**1. Monitor your usage:**
```
- Check Railway dashboard for usage stats
- Set up usage alerts
- $5 free credit = ~500 hours/month
- One small service can run 24/7 on free tier
```

**2. Optimize resource usage:**
```
- Use lightweight Docker images
- Enable sleep mode for staging (if available)
- Combine services when possible
- Use serverless functions for occasional tasks
```

**3. Database optimization:**
```
- Use Railway's free PostgreSQL (500MB)
- Archive old data
- Use indexes for faster queries
- Consider SQLite for very small projects
```

### If You Exceed Free Tier

**Upgrade options:**
- **Hobby Plan**: Pay as you go (~$5-10/month for small apps)
- **Pro Plan**: $20/month (higher limits)

**Cheaper alternatives if needed:**
- **Fly.io**: 3 shared VMs free
- **Render**: Free tier for static sites
- **Oracle Cloud**: Always free tier (ARM VMs)
- **AWS Free Tier**: 12 months free (more complex)

---

## Alternative: Deploying to Render (Backup Option)

**If Railway doesn't work for you:**

### Render.com Free Tier

**1. Sign up:**
- Go to https://render.com
- Sign in with GitHub

**2. Create Web Service:**
```
1. Click "New" → "Web Service"
2. Connect your repository
3. Configure:
   - Name: control-tower-backoffice
   - Environment: Node
   - Build Command: npm install
   - Start Command: npm start
   - Free tier selected
```

**3. Add environment variables:**
- Same as Railway setup

**Render Free Tier Limits:**
- ✅ Free static sites (unlimited)
- ⚠️ Web services: Free (but spins down after 15min inactivity)
- ⚠️ 750 hours/month (will sleep when not in use)
- Limited databases on free tier

---

## Alternative: Self-Hosting on Oracle Cloud (Free VPS)

**For maximum control and 0 cost:**

### Oracle Cloud Always Free Tier

**1. Sign up:**
- Go to https://www.oracle.com/cloud/free/
- Create account (requires credit card for verification, but free)

**2. Free resources:**
- 2 AMD VMs (1/8 OCPU, 1GB RAM each)
- OR 4 ARM VMs (1 OCPU, 6GB RAM each) ← **Recommended**
- 200GB storage
- 10TB/month bandwidth

**3. Setup (Advanced):**
```bash
# SSH into your VM
ssh ubuntu@your-vm-ip

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install Git
sudo apt-get install -y git

# Clone your repo
git clone https://github.com/your-username/controlTowerBackoffice.git
cd controlTowerBackoffice

# Install dependencies
npm install

# Use PM2 for process management
sudo npm install -g pm2
pm2 start npm --name "backoffice" -- start
pm2 startup
pm2 save

# Install and configure Nginx (reverse proxy)
sudo apt-get install -y nginx
# Configure Nginx to proxy to your app
```

**This is more complex but gives you:**
- Full control
- $0 cost forever
- Can host multiple projects
- Learn DevOps skills

---

## Monitoring and Maintenance

### Railway Monitoring

**1. Built-in monitoring:**
```
- CPU usage
- Memory usage
- Network traffic
- Deployment history
- Real-time logs
```

**2. Set up alerts:**
```
- Usage threshold alerts
- Error rate alerts
- Deployment failure notifications
```

### Health Checks

**Add to your application:**

```javascript
// Express.js example
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV
  });
});
```

### Logging

**Use Railway's logging or add external service:**

```javascript
// Use console.log (Railway captures stdout)
console.log('Application started');
console.error('Error occurred:', error);

// Or use a logging library
const winston = require('winston');
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.json(),
  transports: [
    new winston.transports.Console()
  ]
});

logger.info('User logged in', { userId: 123 });
```

---

## Security Best Practices

### 1. Environment Variables

```bash
# NEVER commit sensitive data
# Use .env for local, Railway variables for production
# Always add .env to .gitignore

# .env.example (committed)
DATABASE_URL=your-database-url
API_KEY=your-api-key

# .env (not committed)
DATABASE_URL=actual-database-url
API_KEY=actual-api-key-value
```

### 2. HTTPS

```
- Railway provides HTTPS automatically
- Always use HTTPS in production
- Redirect HTTP to HTTPS
```

### 3. Security Headers

```javascript
// Use helmet.js for Express
const helmet = require('helmet');
app.use(helmet());
```

### 4. Rate Limiting

```javascript
// Prevent abuse
const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
});

app.use('/api/', limiter);
```

---

## Troubleshooting

### Deployment Fails

**Check build logs:**
```
1. Go to Railway → Deployments
2. Click failed deployment
3. Check build logs for errors
4. Common issues:
   - Missing dependencies
   - Wrong start command
   - Port configuration
   - Environment variables missing
```

### Application Crashes

**Check runtime logs:**
```
1. View logs in Railway
2. Look for error messages
3. Common issues:
   - Database connection fails
   - Missing environment variables
   - Code errors
   - Out of memory
```

### Database Connection Issues

```javascript
// Add error handling
const { Pool } = require('pg');

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: process.env.NODE_ENV === 'production' ? { rejectUnauthorized: false } : false
});

pool.on('error', (err) => {
  console.error('Unexpected database error:', err);
});
```

### Exceeded Free Tier

```
1. Check usage in Railway dashboard
2. Optimize resource usage
3. Consider upgrading ($5-10/month)
4. Or migrate to another free tier service
```

---

## Summary: Best Choice for Broke Students

### 🏆 Winner: Railway

**Recommended setup:**

1. **Use Railway's free tier** ($5/month credit)
2. **Deploy STAGING** on `develop` branch
3. **Deploy PRODUCTION** on `main` branch
4. **Add PostgreSQL** database (free 500MB)
5. **Monitor usage** to stay within free tier

**Expected costs:**
- **Month 1-∞**: $0 (if usage < $5/month)
- Most small student projects fit easily in free tier

**Workflow:**
```
feature → develop → release → main
   ↓         ↓         ↓        ↓
  local   develop   STAGING   PROD
                   (Railway) (Railway)
```

**When you need to scale:**
- Railway Hobby: ~$10/month
- Or migrate to Oracle Cloud Free Tier (requires DevOps skills)

---

## Quick Start Checklist

- [ ] Sign up for Railway with GitHub
- [ ] Create new project from your repository
- [ ] Add environment variables
- [ ] Configure branch deployments (main = PROD, develop/release = STAGING)
- [ ] Add database if needed
- [ ] Test deployment
- [ ] Set up custom domain (optional)
- [ ] Monitor usage to stay within free tier
- [ ] Celebrate your deployed app! 🎉

---

## Additional Resources

- [Railway Documentation](https://docs.railway.app/)
- [Railway Discord Community](https://discord.gg/railway)
- [Render Documentation](https://render.com/docs)
- [Oracle Cloud Free Tier](https://www.oracle.com/cloud/free/)
- [Fly.io Documentation](https://fly.io/docs/)
- [Student Developer Pack](https://education.github.com/pack) - Free credits for various services

---

**Good luck with your deployment! 🚀**

_Remember: The best hosting is the one that fits your budget and technical skills. Start with Railway, and scale up as your needs grow._
