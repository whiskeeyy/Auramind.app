# 🔒 Security Setup Guide

## ⚠️ CRITICAL: Environment Variables Setup

### Backend Setup

1. **Create `.env` file** in `backend/` directory:
   ```bash
   cd backend
   cp .env.example .env
   ```

2. **Get your Supabase credentials**:
   - Go to: https://rofkecleciqfyvqtdrgh.supabase.co
   - Navigate to: **Settings > API**
   - Copy the following values:

3. **Edit `backend/.env`** with your actual values:
   ```env
   SUPABASE_URL=https://rofkecleciqfyvqtdrgh.supabase.co
   SUPABASE_KEY=<your-supabase-anon-key>
   SUPABASE_JWT_SECRET=<your-jwt-secret>
   ```

   **Where to find:**
   - `SUPABASE_KEY`: Copy "anon public" key from API settings
   - `SUPABASE_JWT_SECRET`: Copy "JWT Secret" from API settings (⚠️ KEEP THIS SECRET!)

### Mobile Setup

1. **Update Supabase Anon Key** in `mobile/auramind_app/lib/config/supabase_config.dart`:
   
   Replace line 17:
   ```dart
   defaultValue: 'YOUR_SUPABASE_ANON_KEY_HERE',
   ```
   
   With your actual anon key:
   ```dart
   defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
   ```

   **OR** use environment variable (recommended for production):
   ```bash
   flutter run --dart-define=SUPABASE_ANON_KEY=<your-anon-key>
   ```

---

## 🛡️ Security Checklist

### Before Every Commit

- [ ] Check `git status` for sensitive files
- [ ] Ensure `.env` files are NOT staged
- [ ] Verify no API keys in source code
- [ ] Run `git diff --cached` to review staged changes
- [ ] Look for patterns: `eyJ`, `sk_`, `pk_`, `secret`, `password`

### Files to NEVER Commit

- ✅ `.env` (already in `.gitignore`)
- ✅ `backend/.env`
- ✅ Any file containing JWT secrets
- ✅ Database passwords
- ✅ Service account keys

### Safe to Commit

- ✅ `.env.example` (template with placeholders)
- ✅ Code with `String.fromEnvironment()` or `os.environ.get()`
- ✅ Configuration files with placeholder values

---

## 🔍 How to Check for Leaked Secrets

### Before Pushing

```bash
# Check what will be pushed
git log origin/main..HEAD --oneline

# Review all changes
git diff origin/main..HEAD

# Search for potential secrets
git diff origin/main..HEAD | grep -i "secret\|key\|password\|token"
```

### If You Accidentally Committed a Secret

1. **DO NOT PUSH** if you haven't already
2. **Remove from history**:
   ```bash
   git reset --soft HEAD~1  # Undo last commit, keep changes
   git reset HEAD <file>     # Unstage the file
   # Edit file to remove secret
   git add <file>
   git commit -m "your message"
   ```

3. **If already pushed**:
   - ⚠️ **ROTATE THE SECRET IMMEDIATELY** in Supabase dashboard
   - Contact team to inform about the leak
   - Force push after removing (use with caution):
     ```bash
     git push --force-with-lease
     ```

---

## 📝 Commit Message Convention

We use conventional commits for clear history:

```
feat(scope): description       # New feature
fix(scope): description        # Bug fix
docs(scope): description       # Documentation
refactor(scope): description   # Code refactoring
test(scope): description       # Tests
chore(scope): description      # Maintenance
```

**Scopes**: `database`, `backend`, `mobile`, `auth`, `api`

---

## ✅ Current Security Status

- ✅ `.gitignore` configured to exclude `.env` files
- ✅ Backend uses environment variables for secrets
- ✅ Mobile uses `String.fromEnvironment()` for keys
- ✅ No hardcoded secrets in committed code
- ✅ `.env.example` provided as template
- ✅ All commits reviewed for security

---

## 🚀 Next Steps

1. Run database migration in Supabase SQL Editor
2. Configure backend `.env` file
3. Update mobile Supabase anon key
4. Test authentication flow
5. Deploy to production

**Remember**: Security is everyone's responsibility! 🔐
