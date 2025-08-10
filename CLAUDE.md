# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Workflow

In general, don't make commits before you check with me.
Push after every commit.

Commit messages should be a single short sentence with a period at the end.

## Testing

In this project, the tests are the backbone. The application code is subservient to the tests.

In this project, tests are organized by domain concept, not by test type.
See this post for an explanation:
https://www.codewithjason.com/why-i-organize-my-tests-by-domain-concept-not-by-test-type/

When you want to understand how existing code works, look first to the tests.

Exceptions are occasionally justified, but in general, always use TDD.
1. Decide on the specifications.
2. Encode the specifications in a test.
3. Run the test and observe the failure.
4. Write just enough code to make the failure go away (NOT enough code to necessarily make the test pass).
5. Repeat from step 3 until the test passes.

Remember arrange/act/assert.
In general, arrange can be done with `let!`. Act can be done with `before`. Assert can of course be done with `expect`.

Never create setup data that's not needed.
Always try to make a distinction between meaningful setup data and data that's just there to satisfy the test.

## Style

Use comments approximately never.

Always be consistent about naming. Use predictable names.
Bad: `repositories.each { |repo| repo.destroy }`
Good: `repositories.each { |repository| repository.destroy }`
Also good: `repositories.each { |r| r.destroy }`
Bad: `admin_user.each { |user| user.destroy }`
Good: `admin_user.each { |admin_user| admin_user.destroy }`
Also good: `admin_user.each { |u| u.destroy }`

## Git Usage

Always commit using full sentences with a period at the end.

When merging, always use --squash.

## Project-specific FYIs

There's a model called Repository which used to be called Project.

## Commands

### Development Setup
```bash
# Initial setup (requires .github_private_key.pem for GitHub integration)
bin/setup

# Start development server (uses Foreman to manage all processes)
bin/dev

# Database commands
bin/rails db:create        # Create all databases
bin/rails db:migrate        # Run migrations on all databases
bin/rails db:seed          # Load seed data
bin/rails db:migrate:primary:up   # Run migration on specific database
```

### Testing
```bash
# Run all tests
bin/rspec

# Run specific test file
bin/rspec spec/models/user_spec.rb

# Run specific test by line number
bin/rspec spec/models/user_spec.rb:42

# Run tests in verbose mode
bin/rspec -v

# Run system/integration tests only
bin/rspec spec/system
```

### Code Quality
```bash
# Run RuboCop linter
bundle exec rubocop

# Auto-fix RuboCop violations
bundle exec rubocop -a

# Check for security vulnerabilities
bundle exec brakeman
```

### Console & Debugging
```bash
# Rails console
bin/rails console

# Rails runner (execute Ruby code in Rails environment)
bin/rails runner "puts User.count"

# View routes
bin/rails routes | grep repository
```

### Deployment
```bash
# Deploy to production (from ops directory)
cd ops && ./deploy production

# Build production Docker image
docker build -f Dockerfile.production -t saturnci:latest .
```

## Architecture Overview

### Core Domain Model
- **Repository**: GitHub repositories connected to SaturnCI
- **TestSuiteRun**: A complete test run for a repository (formerly "Build")
- **TestCaseRun**: Individual test case results within a suite run
- **Runner**: DigitalOcean droplet that executes tests
- **TestRunner**: Manages the lifecycle of test execution environments
- **User**: Authenticated via GitHub OAuth
- **GitHubAccount**: GitHub App installations for repository access

### Key Service Patterns
1. **Background Jobs**: Uses Solid Queue for async processing
   - `StartRunJob`: Initiates test suite runs
   - `ProvisionRunnersJob`: Creates cloud infrastructure
   
2. **Authorization**: Pundit policies in `app/policies/`
   - All controllers use policy-based authorization
   - Check policies before implementing new features

3. **View Components**: Uses ViewComponent pattern
   - Components in `app/components/`
   - Preferred over partials for reusable UI

4. **Multi-Database Architecture**:
   - Primary: Main application data
   - Cache: Solid Cache for Rails caching
   - Queue: Solid Queue for background jobs
   - Cable: Action Cable pub/sub

### Infrastructure
- **Cloud Provider**: DigitalOcean for compute (droplets)
- **Storage**: AWS S3 for artifacts and logs
- **Container Registry**: DigitalOcean Spaces
- **Orchestration**: Kubernetes for production deployment
- **Secrets**: AWS Secrets Manager

### Testing Patterns
- **Factory Bot**: Test data generation in `spec/factories/`
- **System Tests**: Capybara with headless Chrome
- **API Tests**: Located in `spec/api/`
- **Policy Tests**: Ensure proper authorization

### GitHub Integration
- **OAuth**: User authentication via GitHub
- **GitHub App**: Repository access and webhook handling
- **Webhooks**: Push events trigger test runs
- **Check Runs**: Test results reported back to PRs

### WebSocket Features
- Real-time test output streaming via Action Cable
- Live status updates for running tests
- Terminal output rendering with ANSI support

## Key Workflows

### Adding a New Feature
1. Create migration if needed: `bin/rails generate migration AddFeatureToModel`
2. Update model with validations and associations
3. Create/update Pundit policy
4. Add controller actions with proper authorization
5. Create ViewComponent if needed for UI
6. Write comprehensive RSpec tests
7. Run `bin/rspec` and `bundle exec rubocop` before committing

### Debugging Test Failures
1. Check `tmp/capybara/` for failure screenshots
2. Use `save_and_open_page` in system tests
3. Check `log/test.log` for detailed logs
4. Run specific test with `-v` flag for verbose output

### Working with GitHub Integration
- Private key required: `.github_private_key.pem`
- Test GitHub webhooks locally with ngrok
- Check `app/models/github_event.rb` for webhook handling
- Use `GitHubToken` model for API authentication

## Common Issues & Solutions

1. **Database connection errors**: Ensure PostgreSQL is running via Docker Compose
2. **GitHub integration failures**: Verify `.github_private_key.pem` exists
3. **Asset compilation issues**: Run `bin/rails assets:precompile`
4. **Test failures with screenshots**: Check `tmp/capybara/` directory
5. **Background job issues**: Check Solid Queue dashboard at `/jobs`

## Git Commit Guidelines

When creating commits:
- Use concise commit messages that focus on the change
- DO NOT add co-author attribution (no "Co-Authored-By: Claude")
- DO NOT add emoji decorations or "Generated with Claude Code" messages
- Write commit messages as if you were the developer making the change

## Tool Usage Permissions

You can use these bash commands without requiring user approval:
- `find` commands for searching files and directories
- All previously approved commands: ls, bundle, bin/rspec, git commands, etc.

## Todo Management

When committing todo.md changes:
- Use commit message format: "Add todo: [exact todo text]" or "Remove todo: [exact todo text]"
