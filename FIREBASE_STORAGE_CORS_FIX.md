# Firebase Storage CORS Configuration for Web Uploads

## Issue

Web uploads to Firebase Storage are being blocked by CORS (Cross-Origin Resource Sharing) policy.

## Solution

Configure Firebase Storage to allow requests from your web app's localhost domain.

### Option 1: Using Google Cloud Console (Recommended)

1. **Install Google Cloud SDK** (if not already installed):
   - Download from: https://cloud.google.com/sdk/docs/install
   - Or use the Cloud Shell in Google Cloud Console

2. **Configure CORS using the cors.json file**:

   ```bash
   cd D:\CSP\FixMyStreet_v1

   gsutil cors set cors.json gs://fixmystreet-c72b7.firebasestorage.app
   ```

3. **Verify CORS configuration**:
   ```bash
   gsutil cors get gs://fixmystreet-c72b7.firebasestorage.app
   ```

### Option 2: Temporary Development Fix (Allow All Origins)

**⚠️ WARNING: Only use this during development! Remove before production!**

1. Go to Firebase Console: https://console.firebase.google.com/
2. Select your project: **fixmystreet-c72b7**
3. Go to **Storage** → **Rules**
4. Temporarily add this rule at the bottom (inside the `service firebase.storage` block):
   ```
   // DEVELOPMENT ONLY - Remove in production!
   match /{allPaths=**} {
     allow read, write: if true;
   }
   ```

### Option 3: Update Storage Rules for Development

In Firebase Console → Storage → Rules, replace with:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Allow all authenticated users during development
    match /{allPaths=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### Testing

After configuring CORS:

1. Restart your Flutter web app: `flutter run -d edge`
2. Try uploading an image in a complaint
3. Check the terminal for these success messages:
   - `✅ StorageService - upload successful`
   - `✅ Complaint created with ID`

### Current Error Symptoms

- Upload hangs at "starting upload..."
- No error message appears
- Timeout occurs after 60 seconds
- Browser console shows CORS errors

### Verification

After setting CORS, you should see:

```
📸 Starting media upload: 1 XFiles
🔍 StorageService - starting upload...
🔍 StorageService - waiting for upload completion...
✅ StorageService - upload successful: https://...
```
