# Contributing to Control Tower Backoffice

Thank you for your interest in contributing! This document provides guidelines and instructions for contributing to this project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Workflow](#development-workflow)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Commit Message Guidelines](#commit-message-guidelines)

## Code of Conduct

- Be respectful and inclusive
- Welcome newcomers and help them get started
- Provide constructive feedback
- Focus on what is best for the community

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues. When creating a bug report, include:

- **Clear title and description**
- **Steps to reproduce** the problem
- **Expected behavior** vs **actual behavior**
- **Screenshots** if applicable
- **Environment details** (OS, browser, version, etc.)

### Suggesting Features

Feature suggestions are welcome! Please:

- **Use a clear title** describing the feature
- **Provide detailed description** of the proposed functionality
- **Explain why** this feature would be useful
- **Include mockups** or examples if applicable

### Code Contributions

1. Look for issues labeled `good first issue` or `help wanted`
2. Comment on the issue to let others know you're working on it
3. Fork the repository
4. Create a feature branch
5. Make your changes
6. Submit a pull request

## Development Workflow

We follow a Git Flow-based workflow. Please read [WORKFLOW.md](WORKFLOW.md) for complete details.

### Quick Overview

```
develop → feature/xxx → develop → release/vX → main
                                    (STAGING)   (PROD)
```

### Setting Up Development Environment

```bash
# Fork the repository on GitHub
# Clone your fork
git clone https://github.com/YOUR-USERNAME/controlTowerBackoffice.git
cd controlTowerBackoffice

# Add upstream remote
git remote add upstream https://github.com/Jemima-Harisoa/controlTowerBackoffice.git

# Create a feature branch from develop
git checkout develop
git pull upstream develop
git checkout -b feature/your-feature-name
```

### Making Changes

```bash
# Make your changes
# Stage changes
git add .

# Commit with descriptive message
git commit -m "Add feature: description of what you did"

# Push to your fork
git push origin feature/your-feature-name
```

### Keeping Your Fork Updated

```bash
# Fetch upstream changes
git fetch upstream

# Update your develop branch
git checkout develop
git merge upstream/develop
git push origin develop

# Update your feature branch
git checkout feature/your-feature-name
git merge develop
# Resolve conflicts if any
git push origin feature/your-feature-name
```

## Pull Request Process

### Before Submitting

- [ ] Your code follows the project's coding standards
- [ ] You've added tests for new functionality (if applicable)
- [ ] All tests pass locally
- [ ] You've updated documentation if needed
- [ ] Your commits have clear, descriptive messages
- [ ] Your branch is up to date with `develop`

### Submitting a Pull Request

1. **Push your changes** to your fork
2. **Go to the original repository** on GitHub
3. **Click "New Pull Request"**
4. **Select your fork and branch**
5. **Fill in the PR template:**

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## How Has This Been Tested?
Describe testing process

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] No new warnings generated
- [ ] Tests added/updated
- [ ] All tests passing
```

6. **Request reviewers** (if you have permissions)
7. **Wait for review**

### After Submitting

- Respond to review comments promptly
- Make requested changes in new commits
- Push updates to the same branch
- Re-request review after making changes

### PR Review Process

PRs require:
- At least 1 approval from maintainers
- All CI checks passing
- No merge conflicts
- Up-to-date with base branch

## Coding Standards

### General Guidelines

- Write clean, readable code
- Follow existing code style
- Keep functions small and focused
- Add comments for complex logic
- Use meaningful variable and function names

### JavaScript/Node.js

```javascript
// Use const by default, let when reassignment needed
const userName = 'John';
let counter = 0;

// Use arrow functions for callbacks
array.map(item => item.value);

// Use async/await instead of callbacks
async function fetchData() {
  try {
    const response = await fetch(url);
    const data = await response.json();
    return data;
  } catch (error) {
    console.error('Error:', error);
  }
}

// Use template literals
const message = `Hello, ${userName}!`;

// Destructuring
const { name, age } = user;
```

### File Structure

```
project/
├── src/           # Source code
├── tests/         # Test files
├── docs/          # Documentation
├── config/        # Configuration files
└── public/        # Static assets
```

### Naming Conventions

- **Files**: `kebab-case.js`
- **Classes**: `PascalCase`
- **Functions/Variables**: `camelCase`
- **Constants**: `UPPER_SNAKE_CASE`

```javascript
// Good
const MAX_RETRY_COUNT = 3;
class UserService { }
function getUserById() { }

// Bad
const max_retry_count = 3;
class userService { }
function GetUserByID() { }
```

## Commit Message Guidelines

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation changes
- **style**: Code style changes (formatting, etc.)
- **refactor**: Code refactoring
- **test**: Adding or updating tests
- **chore**: Maintenance tasks

### Examples

```bash
# Simple commit
git commit -m "feat: add user authentication"

# With scope
git commit -m "fix(auth): resolve token expiration issue"

# With body
git commit -m "feat: add email notifications

- Implement email service
- Add email templates
- Configure SMTP settings"

# Breaking change
git commit -m "feat!: change API response format

BREAKING CHANGE: API now returns data in different structure"
```

### Best Practices

- Use present tense ("Add feature" not "Added feature")
- Use imperative mood ("Move cursor" not "Moves cursor")
- First line under 50 characters
- Separate subject from body with blank line
- Wrap body at 72 characters
- Reference issues: "Fixes #123", "Closes #456"

## Testing

### Running Tests

```bash
# Run all tests
npm test

# Run tests in watch mode
npm test -- --watch

# Run specific test file
npm test -- path/to/test.js

# Generate coverage report
npm test -- --coverage
```

### Writing Tests

- Write tests for all new features
- Update tests when modifying existing features
- Aim for high test coverage
- Test edge cases and error conditions

```javascript
// Example test structure
describe('UserService', () => {
  describe('getUserById', () => {
    it('should return user when ID is valid', async () => {
      // Arrange
      const userId = 1;
      
      // Act
      const user = await getUserById(userId);
      
      // Assert
      expect(user).toBeDefined();
      expect(user.id).toBe(userId);
    });
    
    it('should throw error when ID is invalid', async () => {
      // Arrange
      const invalidId = -1;
      
      // Act & Assert
      await expect(getUserById(invalidId)).rejects.toThrow();
    });
  });
});
```

## Documentation

### Code Documentation

- Add JSDoc comments for functions and classes
- Document complex algorithms
- Explain "why" not just "what"

```javascript
/**
 * Calculates the total price including tax
 * @param {number} price - Base price before tax
 * @param {number} taxRate - Tax rate as decimal (e.g., 0.2 for 20%)
 * @returns {number} Total price with tax included
 * @throws {Error} If price or taxRate is negative
 */
function calculateTotalPrice(price, taxRate) {
  if (price < 0 || taxRate < 0) {
    throw new Error('Price and tax rate must be non-negative');
  }
  return price * (1 + taxRate);
}
```

### README Updates

Update README.md when:
- Adding new features
- Changing setup process
- Modifying configuration
- Adding dependencies

## Getting Help

If you need help:

1. Check [WORKFLOW.md](WORKFLOW.md) and [DEPLOYMENT.md](DEPLOYMENT.md)
2. Search existing issues
3. Ask in pull request comments
4. Create a new issue with `question` label
5. Reach out to maintainers

## Recognition

Contributors are recognized in:
- GitHub contributors page
- Release notes
- Project documentation

Thank you for contributing! 🎉
