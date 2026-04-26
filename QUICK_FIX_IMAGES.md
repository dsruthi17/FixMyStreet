# 🔧 Quick Fix: Deploy Storage Rules Manually

## The Problem

Images are uploading but not displaying because Firebase Storage doesn't have read permissions configured.

## Quick Solution (5 Minutes)

### Step 1: Open Firebase Console

1. Go to https://console.firebase.google.com/
2. Select your **FixMyStreet** project

### Step 2: Navigate to Storage Rules

1. Click **Storage** in the left sidebar
2. Click the **Rules** tab at the top

### Step 3: Replace Rules

1. You'll see existing rules (probably `allow read, write: if false;`)
2. **Delete all existing rules**
3. **Copy and paste** the following rules:

```
rules_version = '2';

service firebase.storage {
  match /b/{bucket}/o {

    // Complaints media - anyone authenticated can read/upload
    match /complaints/{complaintId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null
                   && request.resource.size < 10 * 1024 * 1024
                   && request.resource.contentType.matches('image/.*|video/.*');
      allow delete: if request.auth != null;
    }

    // Profile photos - users can upload their own
    match /profiles/{userId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null
                   && request.auth.uid == userId
                   && request.resource.size < 5 * 1024 * 1024
                   && request.resource.contentType.matches('image/.*');
    }
  }
}
```

### Step 4: Publish

1. Click the **Publish** button
2. Wait for "Rules published successfully" confirmation

### Step 5: Test on Mobile

1. **Restart your app** on mobile
2. **Submit a new complaint** with an image
3. **View the complaint** - image should now be visible!

## ✅ That's It!

Your images should now be visible. The changes are immediate - no need to rebuild the app.

## Still Not Working?

Check these:

1. **User must be logged in** - images only show to authenticated users
2. **Check Storage in Firebase Console**:
   - Go to Storage > Files tab
   - Look for `complaints/[some-id]/` folders
   - You should see uploaded images there

3. **Check app logs**:
   - Open terminal and run: `flutter run --verbose`
   - Look for:
     - `📸 Upload complete: X files uploaded successfully` (when uploading)
     - `🖼️ IMAGE ERROR:` (if images fail to load)

4. **Re-upload images**:
   - Old images uploaded before rules might not work
   - Submit a new complaint with a new image
   - The new one should work

## Why This Fixes It

- Firebase Storage by default denies all access
- Your images were uploading (write permission was somehow working)
- But viewing them was blocked (read permission was missing)
- These new rules allow authenticated users to read and write images

---

**Need more help?** Check `STORAGE_RULES_DEPLOYMENT.md` for detailed troubleshooting.
