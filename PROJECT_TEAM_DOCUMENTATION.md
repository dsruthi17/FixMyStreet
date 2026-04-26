# FixMyStreet Project - Team Work Division

**Project Overview:** Community complaint management system with Flutter frontend and Firebase backend

**Last Updated:** February 23, 2026

---

## Team Member 1: Authentication & User Management System

### **Primary Responsibilities:**

- User authentication flow (login, signup, password management)
- User profile management
- Role-based access control (Admin, Officer, Worker, Citizen)
- User data model and state management

### **Files & Components to Document:**

#### **Core Models:**

- `lib/core/models/user_model.dart`
  - User data structure with roles (admin, officer, worker, citizen)
  - Fields: uid, email, displayName, phoneNumber, userRole, profileImageUrl
  - **NEW: myComplaintIds** - Array storing complaint IDs owned by user (for ownership tracking)
  - Methods: fromMap, toMap, copyWith

#### **Authentication Provider:**

- `lib/providers/auth_provider.dart`
  - User authentication state management
  - Login/logout functionality
  - User session handling
  - Current user data access

#### **Authentication Screens:**

- `lib/screens/auth/login_screen.dart` - User login interface
- `lib/screens/auth/signup_screen.dart` - New user registration
- `lib/screens/auth/verify_phone_screen.dart` - Phone verification flow

#### **Profile Management:**

- `lib/screens/user/profile_screen.dart`
  - Display user information and statistics
  - Edit profile functionality
  - View user's complaint history
  - Uses **myComplaintIds** to fetch user's complaints

#### **Key Features Implemented:**

- Firebase Authentication integration
- Phone number verification
- Role-based UI rendering
- Profile image upload
- **ID-Based Ownership System** - Users track their complaints via myComplaintIds array

#### **Documentation Tasks:**

1. Document authentication flow diagram
2. Explain role-based access rules
3. Document user data schema in Firestore
4. Create API reference for AuthProvider methods
5. Document ID-based ownership system architecture
6. Security rules for user data access

---

## Team Member 2: Complaint Management & Backend Services

### **Primary Responsibilities:**

- Complaint lifecycle management (create, read, update, delete)
- Feedback and comment system
- Firestore database operations
- Storage service for media uploads
- **ID-Based Ownership Tracking System**

### **Files & Components to Document:**

#### **Core Models:**

- `lib/core/models/complaint_model.dart`
  - Complaint data structure
  - Fields: id, title, description, category, status, location, images, videos, upvotes, createdBy, userId, phoneNumber, isAnonymous, createdAt, lastModified
  - Status types: pending, in_progress, resolved, rejected
  - Categories: roads, water supply, electricity, sanitation, garbage

- `lib/core/models/feedback_model.dart`
  - User feedback/comments on complaints
  - Fields: id, complaintId, userId, userName, commentText, createdAt

#### **Backend Services:**

- `lib/core/services/firestore_service.dart`
  - **CRUD operations** for complaints
  - **NEW: addComplaintToUser()** - Adds complaint ID to user's myComplaintIds array using arrayUnion
  - **ENHANCED: deleteComplaint()** - Removes complaint ID from user's array using arrayRemove
  - **ENHANCED: getComplaintsStream()** - Accepts complaintIds parameter, handles Firestore 10-item limit with client-side filtering
  - Feedback/comment operations
  - Query filtering and sorting
  - Real-time data streaming

- `lib/core/services/storage_service.dart`
  - Image upload to Firebase Storage
  - Video upload functionality
  - Media file management and deletion

#### **Complaint Provider:**

- `lib/providers/complaint_provider.dart`
  - Complaint state management
  - **submitComplaint()** - Creates complaint, then calls addComplaintToUser() with complaint ID
  - **streamMyComplaints()** - Changed signature from userId to List<String> complaintIds
  - Delete, update operations
  - Upvote/downvote logic
  - Statistics calculation

#### **Key Features Implemented:**

- Real-time complaint streaming
- Media upload (images/videos)
- Anonymous complaint support
- Upvoting system
- **ID-Based Ownership System:**
  - Every complaint stores unique ID in user's myComplaintIds array
  - Works for all complaint types (anonymous, normal, old, new)
  - Firestore arrayUnion/arrayRemove for atomic operations
  - Ownership verified by checking: myComplaintIds.contains(complaintId)

#### **Documentation Tasks:**

1. Document complaint data flow diagram
2. Firestore collection structure and indexes
3. Document complaint status workflow
4. API reference for FirestoreService methods
5. Storage bucket organization and security rules
6. **ID-Based Ownership Architecture:**
   - How complaint IDs are added to user arrays
   - Ownership verification logic
   - Handling old complaints without IDs
   - Firestore 10-item limit workaround

---

## Team Member 3: User Interface & Screen Components

### **Primary Responsibilities:**

- Screen layouts and navigation
- Custom widgets and UI components
- Theme and styling
- User interaction flows
- **New Bulletin Board Feature**

### **Files & Components to Document:**

#### **Screen Implementations:**

**Home & Navigation:**

- `lib/screens/user/home_screen.dart`
  - Main navigation hub with 5 tabs
  - Bottom navigation bar: Home, Map, Report, **Bulletin (NEW)**, Profile
  - Feed screen with filters and search
  - Category chips and complaint cards

**Complaint Screens:**

- `lib/screens/user/submit_complaint_screen.dart`
  - Multi-step complaint submission form
  - Category selection
  - Location picker (manual entry or GPS)
  - Media upload (photos/videos)
  - Anonymous submission option

- `lib/screens/user/complaint_detail_screen.dart`
  - Full complaint details view
  - Image/video gallery
  - Comments section
  - Upvote button
  - **SIMPLIFIED: Delete button** - Now uses simple myComplaintIds.contains(id) check
  - Share functionality
  - Debug logging for ownership verification

- `lib/screens/user/my_complaints_screen.dart`
  - User's personal complaints list
  - **UPDATED:** Uses myComplaintIds to fetch complaints
  - Pull-to-refresh functionality
  - Status filter tabs

**NEW: Bulletin Board Feature:**

- `lib/screens/user/bulletin_board_screen.dart` **(683 lines - NEWLY CREATED)**
  - **Community-wide complaint viewing** with voting
  - **Advanced Filtering System:**
    - Category filter (roads, water, electricity, sanitation, garbage, all)
    - Status filter (pending, in_progress, resolved, rejected, all)
    - Sort options: newest, oldest, mostUpvoted
  - **Role-Based Privacy:**
    - Officers/Admins see full user details
    - Citizens see "Anonymous" tag for anonymous complaints
  - **UI Components:**
    - Gradient info banner with total complaint count
    - Active filter chips with remove buttons
    - "Clear All Filters" option
    - ModalBottomSheet for filter selection
    - Custom complaint cards with category icons, upvote counts, location badges
  - **Features:**
    - Pull-to-refresh support
    - Empty state handling
    - Real-time updates via StreamBuilder
    - Tap to view full details
  - **Purpose:** Community engagement and transparency as requested: _"make sure keep a section like bulleitein and show them there for all the user and they can vote them and in the filter in bulleitein we can filter tehm based on teh highest votes or place or types or etc filterations"_

**Other User Screens:**

- `lib/screens/user/map_view_screen.dart` - Geographical complaint view
- `lib/screens/user/notifications_screen.dart` - User notifications
- `lib/screens/user/settings_screen.dart` - App settings

**Admin Screens:**

- `lib/screens/admin/admin_dashboard_screen.dart` - Admin overview
- `lib/screens/admin/manage_officers_screen.dart` - Officer management
- `lib/screens/admin/admin_complaints_screen.dart` - All complaints view

**Officer Screens:**

- `lib/screens/officer/officer_dashboard_screen.dart` - Officer workspace
- `lib/screens/officer/assign_worker_screen.dart` - Task assignment

**Worker Screens:**

- `lib/screens/worker/worker_dashboard_screen.dart` - Worker tasks
- `lib/screens/worker/worker_complaints_screen.dart` - Assigned work

#### **Reusable Widgets:**

- `lib/widgets/complaint_card.dart` - Complaint display card
- `lib/widgets/category_chip.dart` - Category selector chip
- `lib/widgets/status_badge.dart` - Status indicator
- `lib/widgets/stat_card.dart` - Statistics display
- `lib/widgets/media_viewer.dart` - Image/video viewer

#### **Theme & Styling:**

- `lib/config/theme.dart` - App theme configuration
- `lib/core/constants/app_colors.dart` - Color palette
- `lib/core/constants/app_strings.dart` - Localized strings

#### **Key Features Implemented:**

- Material Design 3
- Responsive layouts
- Custom animations
- Pull-to-refresh patterns
- ModalBottomSheets for filters
- **Bulletin Board with advanced filtering and role-based privacy**

#### **Documentation Tasks:**

1. UI/UX design patterns used
2. Navigation flow diagrams
3. Widget tree structure
4. Theme customization guide
5. Responsive design breakpoints
6. **Bulletin Board Feature:**
   - Filter implementation details
   - Role-based rendering logic
   - Sorting algorithm
   - Empty state handling
   - Integration with home navigation

---

## Team Member 4: Configuration, Utilities & Integration

### **Primary Responsibilities:**

- App configuration and routing
- Utility functions and helpers
- Firebase integration
- Build configuration
- Constants and enums

### **Files & Components to Document:**

#### **App Configuration:**

- `lib/main.dart`
  - App entry point
  - Provider initialization
  - Firebase initialization
  - Theme configuration

- `lib/app.dart`
  - MaterialApp configuration
  - Route management
  - Global error handling

- `lib/config/routes.dart`
  - Named route definitions
  - Route generation logic
  - Navigation guards

- `lib/firebase_options.dart`
  - Firebase configuration for all platforms
  - Auto-generated by FlutterFire CLI

#### **Utility Functions:**

- `lib/core/utils/helpers.dart`
  - Date formatting
  - Category icon mapping
  - Status color mapping
  - Time ago formatter
  - Location distance calculator
  - String validators

#### **Constants & Enums:**

- `lib/core/constants/app_config.dart`
  - API endpoints
  - App version
  - Feature flags

- `lib/core/constants/app_colors.dart`
  - Color definitions
  - Primary/secondary palettes
  - Gradient definitions

- `lib/core/constants/app_strings.dart`
  - UI text strings
  - Error messages
  - Localization support

#### **Firebase Integration:**

- `firestore.rules` - Firestore security rules
- `pubspec.yaml` - Dependencies and assets

#### **Platform Configurations:**

- `android/` - Android build configuration
- `ios/` - iOS build configuration
- `web/` - Web build configuration
- `windows/` - Windows build configuration

#### **Key Features Implemented:**

- Multi-platform support
- Firebase integration (Auth, Firestore, Storage)
- Provider state management
- Routing system
- Localization ready

#### **Documentation Tasks:**

1. Project setup and installation guide
2. Firebase configuration steps
3. Environment variables setup
4. Build and deployment process
5. Dependencies documentation
6. Helper functions API reference
7. Security rules explanation

---

## Recent Major Updates (February 2026)

### **1. ID-Based Ownership System** ✅

**Problem Solved:** Anonymous complaints didn't show delete button for owners because userId was empty string.

**Solution Implemented:**

- Added `myComplaintIds` field to user model (List<String>)
- Store complaint ID in user's array when created (Firestore arrayUnion)
- Remove complaint ID when deleted (Firestore arrayRemove)
- Simplified ownership check: `myComplaintIds.contains(complaintId)`

**Files Modified:**

- `lib/core/models/user_model.dart` - Added myComplaintIds field
- `lib/core/services/firestore_service.dart` - Added addComplaintToUser(), enhanced deleteComplaint()
- `lib/providers/complaint_provider.dart` - Integrated ID tracking
- `lib/screens/user/complaint_detail_screen.dart` - Simplified ownership check
- `lib/screens/user/my_complaints_screen.dart` - Updated to use myComplaintIds
- `lib/screens/user/profile_screen.dart` - Updated to use myComplaintIds

**Benefits:**

- Works for ALL complaint types (anonymous, normal)
- No more complex fallback logic
- Atomic operations with Firestore
- Future-proof ownership tracking

### **2. Community Bulletin Board Feature** ✅

**User Request:** _"make sure keep a section like bulleitein and show them there for all the user and they can vote them and in the filter in bulleitein we can filter tehm based on teh highest votes or place or types or etc filterations"_

**Implementation:**

- Created `lib/screens/user/bulletin_board_screen.dart` (683 lines)
- Added to home navigation as 4th tab with forum icon
- Advanced filtering: category, status, sort (newest/oldest/mostUpvoted)
- Role-based privacy protection
- Beautiful UI with gradient banners, filter chips, status badges
- Pull-to-refresh support

**Features:**

- View all community complaints
- Upvote display on each card
- ModalBottomSheet filter interface
- Active filter indicators with quick remove
- Empty state handling
- Real-time updates

---

## Testing & Quality Assurance (Shared Responsibility)

### **Testing Priorities:**

1. **Authentication Flow Testing** (Member 1)
   - Login/logout functionality
   - Role-based access verification
   - Profile updates
   - **ID ownership system validation**

2. **Complaint Operations Testing** (Member 2)
   - Create/read/update/delete operations
   - Anonymous complaint creation
   - **ID tracking (add/remove from user array)**
   - Media upload
   - Upvoting system

3. **UI/UX Testing** (Member 3)
   - Navigation between screens
   - Filter and search functionality
   - **Bulletin board filtering**
   - Responsive design on different devices
   - **Role-based privacy in bulletin board**

4. **Integration Testing** (Member 4)
   - Firebase connectivity
   - Real-time updates
   - Platform-specific builds
   - Performance optimization

---

## Future Enhancements

### **Pending Features:**

1. **Location-Based "Near Me" Sorting** - Filter complaints by proximity
2. **Advanced Analytics** - Trending issues, category statistics
3. **Notification System** - Alert users about highly upvoted complaints
4. **Date Range Filtering** - Filter complaints by creation date
5. **Migration Script** - Add complaint IDs to existing users' arrays
6. **Multi-language Support** - Complete localization

### **Known Issues to Address:**

- Test ID-based ownership with existing anonymous complaints
- Verify myComplaintIds array updates correctly in all scenarios
- Performance optimization for large complaint lists
- Offline mode support

---

## Quick Start Guide

### **Project Structure:**

```
lib/
├── main.dart                    # App entry point
├── app.dart                     # MaterialApp configuration
├── config/                      # Routes and theme
├── core/
│   ├── constants/              # App constants
│   ├── models/                 # Data models
│   ├── services/               # Backend services
│   └── utils/                  # Helper functions
├── providers/                  # State management
├── screens/                    # UI screens
│   ├── admin/                  # Admin screens
│   ├── auth/                   # Authentication screens
│   ├── officer/                # Officer screens
│   ├── user/                   # Citizen screens
│   └── worker/                 # Worker screens
├── translations/               # Localization files
└── widgets/                    # Reusable widgets
```

### **Technology Stack:**

- **Frontend:** Flutter 3.x, Material Design 3
- **State Management:** Provider
- **Backend:** Firebase (Auth, Firestore, Storage)
- **Video Player:** video_player package
- **Image Handling:** cached_network_image, image_picker
- **Location:** geolocator, geocoding
- **Sharing:** share_plus

### **Development Commands:**

```bash
# Get dependencies
flutter pub get

# Run on device
flutter run

# Build for production
flutter build apk           # Android
flutter build ios           # iOS
flutter build web           # Web
flutter build windows       # Windows
```

---

## Contact & Support

For questions specific to each module, contact the respective team member:

- **Member 1:** Authentication & User Management
- **Member 2:** Complaint Management & Backend
- **Member 3:** UI/UX & Screens
- **Member 4:** Configuration & Integration

**Project Repository:** d:\CSP\FixMyStreet_v1

**Last Updated:** February 23, 2026
