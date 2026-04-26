# Firebase Storage Rules Deployment Guide

## Issue Fixed

Images were not visible because Firebase Storage security rules were not configured. Even though images were uploading successfully, they couldn't be read due to missing permissions.

## Changes Made

### 1. **Created storage.rules file**

- Location: `storage.rules` (root of project)
- Allows authenticated users to read/write complaint images
- Sets file size limits (10MB for complaints, 5MB for profiles)
- Restricts uploads to image and video types only

### 2. **Improved Image Display Code**

- Added better null/empty checks for mediaUrls
- Added detailed error messages when images fail to load
- Added debug logging to help diagnose issues
- Better error handling in CachedNetworkImage widgets

### 3. **Enhanced Debug Logging**

- Provider now logs each file upload with details
- Screens now log image loading errors with URLs
- Better visibility into what's happening during upload/display

## How to Deploy Storage Rules

### Option 1: Using Firebase CLI (Recommended)

1. **Install Firebase CLI** (if not already installed):

   ```bash
   npm install -g firebase-tools
   ```

2. **Login to Firebase**:

   ```bash
   firebase login
   ```

3. **Initialize Firebase** (if not done before):

   ```bash
   firebase init storage
   ```

   - Select your project
   - Choose `storage.rules` as your rules file

4. **Deploy storage rules**:
   ```bash
   firebase deploy --only storage
   ```

### Option 2: Using Firebase Console (Manual)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Click on **Storage** in the left sidebar
4. Click on the **Rules** tab
5. Replace the existing rules with the content from `storage.rules`
6. Click **Publish**

## Storage Rules Content

```rules
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {

    // Complaints media files
    match /complaints/{complaintId}/{fileName} {
      // Anyone authenticated can read complaint images
      allow read: if request.auth != null;

      // Anyone authenticated can upload images
      allow write: if request.auth != null
                   && request.resource.size < 10 * 1024 * 1024  // 10MB limit
                   && request.resource.contentType.matches('image/.*|video/.*');

      // Allow delete for admins only
      allow delete: if request.auth != null;
    }

    // Profile photos
    match /profiles/{userId}/{fileName} {
      // Anyone can read profile photos
      allow read: if request.auth != null;

      // Users can upload their own profile photos
      allow write: if request.auth != null
                   && request.auth.uid == userId
                   && request.resource.size < 5 * 1024 * 1024  // 5MB limit
                   && request.resource.contentType.matches('image/.*');
    }
  }
}
```

## Testing

After deploying the rules:

1. **Test image upload**:
   - Submit a new complaint with an image
   - Check console logs (use `flutter run --verbose`) for upload status
   - You should see "✅ Uploaded file 1: [URL]" messages

2. **Test image display**:
   - View the complaint detail screen
   - Images should now load properly
   - Check console for any "🖼️ IMAGE ERROR" messages

3. **Verify storage rules**:
   - Go to Firebase Console > Storage > Rules
   - Rules should match the content above
   - Check "Usage" tab to see if files are being accessed

## Troubleshooting

### Images still not showing?

1. **Check Firebase Storage Rules**:

   ```bash
   firebase deploy --only storage
   ```

2. **Clear app cache and restart**:

   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

3. **Check console logs**:
   - Look for "🖼️ IMAGE ERROR" messages
   - Look for "📸 Upload complete" messages
   - Verify URLs are valid (should start with https://firebasestorage.googleapis.com/)

4. **Verify in Firebase Console**:
   - Go to Storage > Files
   - Check if images exist in `complaints/[complaintId]/` folders
   - Click on an image to see its URL
   - Try opening the URL in a browser (while logged in)

5. **Check internet/CORS**:
   - Images need internet connection
   - Some networks may block Firebase Storage
   - Try on different network/mobile data

### Still having issues?

Check the Flutter console for detailed error messages. The new code will show:

- 🖼️ for image-related logs
- ✅ for successful operations
- ❌ for errors
- 📸 for upload operations
- 📦 for data structure details

## Important Notes

- Deploy storage rules **before** testing on mobile
- Rules deployment is instant, no app rebuild needed
- Make sure user is authenticated (logged in) to see images
- Images from before the rules may need re-uploading

## For Production

Before going to production:

1. Review and tighten security rules
2. Consider adding virus scanning
3. Add content moderation
4. Set up billing alerts (storage costs)
5. Monitor Storage usage in Firebase Console
