# Security Setup Guide

This guide explains how to securely configure your ShopWise app for production deployment.

## 🔒 Sensitive Data Secured

The following sensitive information has been removed from the codebase:

### 1. Firebase Configuration
- **File**: `lib/services/firebase_.dart`
- **Secured**: API keys, project ID, and database secrets
- **Action Required**: Set up environment variables (see below)

### 2. Test Credentials
- **Files**: `lib/utils/data.json`, `assets/data.json`
- **Secured**: Removed real email addresses and passwords
- **Action Required**: Configure your own test credentials

### 3. Documentation
- **File**: `MULTI_APP_SETUP.md`
- **Secured**: Removed hardcoded API keys from examples

## 🛡️ Files Protected by .gitignore

Your `.gitignore` file already excludes:
- `firebase_options.dart` - Contains Firebase configuration
- `.env` files - Environment variables
- `google-services.json` - Android Firebase config
- `GoogleService-Info.plist` - iOS Firebase config
- `*.key`, `*.pem`, `*.keystore` - Certificate files
- `secrets.json`, `config.json` - Configuration files

## ⚙️ Setup Instructions

### Step 1: Create Environment File
```bash
# Copy the example file
cp env.example .env

# Edit .env with your actual values
# DO NOT commit .env to version control
```

### Step 2: Configure Firebase
1. **Get your Firebase configuration**:
   - Go to Firebase Console → Project Settings → General
   - Click "Add App" or select existing app
   - Copy the configuration values

2. **Update your `.env` file**:
   ```env
   FIREBASE_PROJECT_ID=your-actual-project-id
   FIREBASE_API_KEY=your-actual-api-key
   FIREBASE_DATABASE_SECRET=your-actual-database-secret
   ```

### Step 3: Create firebase_options.dart
1. **Use FlutterFire CLI** (recommended):
   ```bash
   flutterfire configure
   ```

2. **Or manually create** from template:
   ```bash
   cp lib/firebase_options.dart.template lib/firebase_options.dart
   # Edit with your actual Firebase configuration
   ```

### Step 4: Configure Test Data
1. **Update test credentials** in `lib/utils/data.json`:
   ```json
   {
     "users": {
       "your-test-email@example.com": {
         "name": "Your Test User",
         "email": "your-test-email@example.com",
         "password": "your-secure-password",
         "phone": "your-phone-number",
         "address": "your-address",
         "storeName": "your-store-name"
       }
     }
   }
   ```

## 🚀 Deployment Checklist

Before pushing to production:

- [ ] All sensitive data removed from source code
- [ ] Environment variables configured
- [ ] Firebase configuration files excluded from Git
- [ ] Test credentials updated
- [ ] `.env` file created and configured
- [ ] `firebase_options.dart` generated with real values

## 🔍 Verification

Run these commands to verify security:

```bash
# Check for exposed API keys
grep -r "AIzaSy" . --exclude-dir=.git --exclude="*.md"

# Check for hardcoded passwords
grep -r "password.*:" . --exclude-dir=.git --exclude="*.md"

# Verify .gitignore is working
git status --ignored
```

## 📝 Environment Variables Reference

See `env.example` for a complete list of required environment variables.

## ⚠️ Important Notes

1. **Never commit** `.env` files or `firebase_options.dart` to version control
2. **Always use** environment variables for sensitive configuration
3. **Regularly rotate** API keys and passwords
4. **Use different** Firebase projects for development and production
5. **Enable** Firebase security rules for production

## 🆘 Troubleshooting

If you encounter issues:

1. **Firebase not connecting**: Check your `firebase_options.dart` configuration
2. **Authentication failing**: Verify your API keys and project ID
3. **Build errors**: Ensure all environment variables are set
4. **Git tracking sensitive files**: Check your `.gitignore` configuration

For more help, refer to the [Firebase documentation](https://firebase.google.com/docs) or [Flutter documentation](https://flutter.dev/docs).
