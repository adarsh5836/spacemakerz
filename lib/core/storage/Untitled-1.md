

Tech Stack:

* Flutter
* Dart
* path_provider
* dart:io
* Local JSON Storage
* No backend/API for now
* Hardcoded local database using JSON files
* Architecture should be future-proof so real APIs can be integrated later easily.

---

## APP OVERVIEW

This is a role-based field task management application.

Roles:

1. Manager
2. Dealer
3. User

Super Admin exists but currently has no UI role.

Super Admin creates Projects.
Projects are assigned to Managers.
Managers create Tasks.
Tasks are visible state-wise to Dealers and Users.

State-based access control:

* Manager can only see Dealers and Users from their own state.
* Dealers and Users cannot access data from other states.

---

## LOCAL STORAGE REQUIREMENT

Use:

* path_provider
* dart:io
* jsonEncode/jsonDecode

Create local JSON files for:

* users.json
* projects.json
* tasks.json
* task_photos.json

Store files inside:
ApplicationDocumentsDirectory

Implement complete local CRUD operations:

* Create
* Read
* Update
* Delete

Create service layer similar to real API architecture.

---

## FOLDER STRUCTURE

Generate proper scalable folder structure:

lib/
┣ core/
┣ models/
┣ services/
┣ repositories/
┣ data/
┣ screens/
┣ widgets/
┣ utils/
┣ constants/
┣ routes/

---

## USER TABLE

Create hardcoded users for 3 states:

* Uttar Pradesh
* Delhi
* Rajasthan

Fields:

* id
* role
* name
* mobile_no
* password
* email
* profile_image
* state
* city
* manager_id
* dealer_id
* is_active
* created_at
* updated_at

Create:

* 2 Managers
* 3 Dealers
* 5 Users

Add login credentials.

---

## PROJECT TABLE

Fields:

* id
* project_name
* project_code
* description
* start_date
* end_date
* city
* state
* address
* manager_id
* status
* priority
* created_by
* created_at
* updated_at

Add 4-5 hardcoded projects.

---

## TASK TABLE

Fields:

* id
* project_id
* task_title
* task_code
* date
* utc_date
* nds
* dealer_name
* dealer_id
* user_id
* manager_id
* address
* state
* city
* district
* site_type
* status
* remarks
* latitude
* longitude
* installation_location
* completed_count
* total_count
* range_in_meter
* created_at
* updated_at

Site Type:

* Field Office
* Construction Site

Task Status:

* Pending
* In Progress
* Completed
* Rejected

Create 10+ hardcoded tasks.

---

## TASK PHOTO TABLE

Fields:

* id
* task_id
* uploaded_by_role
* uploaded_by_id
* image_path
* caption
* latitude
* longitude
* created_at
* updated_at

Use local image storage.

---

## LOGIN FLOW

Create login using:

* mobile number
* password

After login:
Navigate user according to role:

* Manager Dashboard
* Dealer Dashboard
* User Dashboard

Persist session locally.

---

## ROLE FEATURES

1. USER ROLE

Features:

* View Projects
* View Tasks
* Open Project → show related tasks
* Open Task → Task Details page
* Upload task photos
* Edit/Delete own uploaded photos
* Allowed only when:

  * Pending
  * In Progress

If task status is Completed:

* View only mode

---

2. DEALER ROLE

Features:

* View Projects
* View Tasks
* View User uploaded photos
* Upload own photos
* Edit/Delete own uploads
* Mark task Completed
* Reject task

Completed tasks:

* View only mode

Dealer cannot modify User uploads.

---

3. MANAGER ROLE

Features:

* View all state tasks
* View all uploads
* Upload photos
* Share task
* View analytics
* Monitor task progress

Manager can view:

* Dealer uploads
* User uploads

Add:

* Share button
* Timeline section

---

## UI REQUIREMENTS

Create modern enterprise UI.

Use:

* Material 3
* Clean cards
* Proper spacing
* Rounded corners
* Professional dashboard

Screens Required:

* Splash
* Login
* Dashboard
* Project Listing
* Task Listing
* Task Details
* Profile
* Settings

---

## TASK DETAILS PAGE

Design modern details page with:

Project Details Card:

* Assigned Date
* Dealer Name
* User Name
* District
* City
* Address
* Installation Location
* Status
* Range
* Latitude/Longitude
* NDS
* Site Type

Statistics Cards:

* Total Count
* Completed Count
* Progress

Photo Upload Section:

* Camera button
* Gallery picker
* Image grid
* Upload progress

Bottom Actions:

* Upload Photo
* Mark Complete
* Reject
* Share

Add:

* Activity Timeline
* GPS badge
* Offline mode support

---

## STATE FILTER LOGIC

Manager:
Can access only their state data.

Dealer/User:
Can only access assigned tasks/projects.

---

## SERVICES

Create:

* AuthService
* UserService
* ProjectService
* TaskService
* PhotoService
* LocalStorageService

All services should behave like real APIs using async/await and Future delays.

---

## IMPORTANT

Use clean architecture.
Write reusable code.
Create proper models with fromJson/toJson.
Use enums for roles and statuses.
Use constants.
Add comments.
Make project production-ready.

The app should feel like a real backend-powered application even though it uses local JSON storage temporarily.
