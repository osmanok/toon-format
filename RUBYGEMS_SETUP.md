# RubyGems Publishing Setup

This document explains how to set up automatic publishing to RubyGems for this repository.

## Prerequisites

1. A RubyGems account (https://rubygems.org)
2. Repository admin access to configure GitHub secrets

## Step 1: Get Your RubyGems API Key

### Option A: Generate a New API Key (Recommended)

1. Go to https://rubygems.org and sign in with your account (`osmanokuyan`)
2. Click on your username in the top right corner
3. Select "Edit Profile" or go to https://rubygems.org/profile/edit
4. Scroll down to the "API Access" section
5. Click "Create a New API Key" or "Show" if you have an existing one
6. Choose the appropriate scope:
   - **Push rubygems** - Allows pushing new gem versions (recommended for CI/CD)
   - Or create a key with full access if needed
7. Give it a descriptive name like "GitHub Actions - toon-format"
8. Copy the API key (it will only be shown once!)

### Option B: Use Existing Credentials

If you have existing credentials in `~/.gem/credentials`:
```bash
cat ~/.gem/credentials
```

Look for the `:rubygems_api_key:` value.

## Step 2: Add the API Key to GitHub Secrets

1. Go to your GitHub repository: https://github.com/osmanok/toon-format
2. Click on "Settings" tab
3. In the left sidebar, click "Secrets and variables" → "Actions"
4. Click "New repository secret"
5. Add the following secret:
   - **Name:** `RUBYGEMS_API_KEY`
   - **Value:** Paste the API key you copied from RubyGems
6. Click "Add secret"

## Step 3: Test the Workflow

Once the secret is added, the workflow will automatically run when:
- Code is pushed to the `master` or `main` branch
- A version tag is pushed (e.g., `v1.0.0`)

To test it:
```bash
# Update version in lib/toon_format/version.rb if needed
git add .
git commit -m "Prepare for release"
git push origin master

# Or create and push a version tag
git tag v1.0.0
git push origin v1.0.0
```

## Workflow Details

The GitHub Action will:
1. Check out the code
2. Set up Ruby 3.2
3. Install dependencies with Bundler
4. Run tests
5. Build the gem
6. Publish to RubyGems (only if tests pass)

## Troubleshooting

### MFA Issues

Your gemspec has `rubygems_mfa_required: true`, which is good for security. The API key method bypasses the need for manual MFA during CI/CD publishing.

### Authentication Errors

If you see "401 Unauthorized" errors:
- Verify the API key is correctly added to GitHub Secrets
- Ensure the API key has "Push rubygems" permission
- Check if the API key hasn't expired

### Gem Already Published

If you get "Repushing of gem versions is not allowed":
- You need to bump the version in `lib/toon_format/version.rb`
- RubyGems doesn't allow overwriting existing versions

## Alternative: Using Username/Password (Not Recommended)

If you prefer using username/password (less secure):

1. Add two secrets to GitHub:
   - `RUBYGEMS_USERNAME`: your RubyGems username
   - `RUBYGEMS_PASSWORD`: your RubyGems password

2. Modify `.github/workflows/publish.yml` to use:
```yaml
- name: Publish to RubyGems
  env:
    RUBYGEMS_USERNAME: ${{ secrets.RUBYGEMS_USERNAME }}
    RUBYGEMS_PASSWORD: ${{ secrets.RUBYGEMS_PASSWORD }}
  run: |
    mkdir -p ~/.gem
    cat > ~/.gem/credentials << EOF
    ---
    :rubygems: ${RUBYGEMS_USERNAME}:${RUBYGEMS_PASSWORD}
    EOF
    chmod 0600 ~/.gem/credentials
    gem push *.gem
```

**Note:** This method won't work if you have MFA enabled (which you should), so API key is the better approach.

## Security Notes

- Never commit API keys or credentials to the repository
- Use GitHub Secrets for sensitive data
- Regularly rotate your API keys
- Use scoped API keys with minimal required permissions
