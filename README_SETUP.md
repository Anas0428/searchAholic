# Setup Instructions for ShopWise App

## Environment Setup

1. **Copy environment template:**
   ```bash
   cp env.template .env
   ```

2. **Copy Firebase configuration template:**
   ```bash
   cp lib/firebase_options.dart.template lib/firebase_options.dart
   ```

3. **Configure your environment variables:**
   - Edit `.env` file and add your actual API keys
   - Edit `lib/firebase_options.dart` and add your Firebase configuration

## Firebase Configuration

To get your Firebase configuration:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to Project Settings > General
4. Scroll down to "Your apps" section
5. Click on the configuration icon for your platform
6. Copy the configuration values to `lib/firebase_options.dart`

## Security Notes

- **Never commit `.env` or `firebase_options.dart` files to version control**
- These files contain sensitive API keys and should remain local only
- The `.gitignore` file is configured to exclude these sensitive files
- Use the template files as reference for the required structure

## Required Environment Variables

- `OPENAI_API_KEY`: Your OpenAI API key for AI features
- Add other variables as needed for your specific setup
