You are working on an existing Flutter application named “Spacemakerz”.

IMPORTANT:
Do NOT create a new Flutter project.
The project is already created.
UI screens already exist.
You only need to refactor, modularize, and implement clean architecture with Bloc/Cubit state management.

---

## CURRENT TECH STACK

Dependencies already added:

path_provider: ^2.1.5
io: ^1.0.5
image_picker: ^1.2.2
google_fonts: ^8.1.0
camera: ^0.12.0+1
flutter_bloc: ^9.1.1
equatable: ^2.0.8

Use:

* flutter_bloc
* Cubit + State
* Clean architecture
* Reusable widgets
* Modular code structure

IMPORTANT:
UI and Logic must remain completely separated.

---

## CURRENT EXISTING SCREENS

Already existing files:

* tasks_screen.dart
* task_details_screen.dart
* projects_screen.dart
* profile_screen.dart
* dashboard_view.dart
* login_screen.dart

Currently:
Each screen contains all code in one file.

Your task:
Break all screens into:

* small reusable widgets
* cubit/state management
* reusable components
* proper folder structure

DO NOT rewrite entire UI unnecessarily.
Refactor existing code cleanly.

---

## COMMON WIDGETS

Already existing:

common/widgets/

* common_loader.dart
* common_button.dart
* common_empty_widget.dart

constants/

* app_colors.dart

Reuse these components properly.

---

## Note -

* Local JSON Storage
* No backend/API for now
* Hardcoded local database using JSON files
* Architecture should be future-proof so real APIs can be integrated later easily.

## APP OVERVIEW

This is a role-based task management and field work tracking application.

Roles:

1. Manager
2. Dealer
3. User

Super Admin exists but currently has no active UI role.

App Name:
Spacemakerz

---

## BUSINESS FLOW

Super Admin:

* Creates projects
* Assigns projects to Managers

Manager:

* Creates tasks
* Tasks visible state-wise
* Can only access their own state data

Dealer:

* Can view assigned tasks/projects
* Can upload photos
* Can mark task completed/rejected

User:

* Can upload work photos
* Can only update while task status is:

  * pending
  * in_progress

Completed tasks become view-only.

---

## LOCAL STORAGE REQUIREMENT

Use:

* path_provider
* dart:io

Create local JSON storage behaving like fake APIs.

Create JSON files:

* users.json
* projects.json
* tasks.json
* task_photos.json

Implement:

* create
* read
* update
* delete

Use async methods with Future delays to simulate APIs.

---

## STATE MANAGEMENT

Use flutter_bloc.

Create proper:

* Cubits
* States
* Repository layer
* Services layer

Example:

features/
┣ tasks/
┃ ┣ cubit/
┃ ┣ models/
┃ ┣ repositories/
┃ ┣ services/
┃ ┣ widgets/
┃ ┗ screens/

Use Equatable states.

Separate:

* UI
* business logic
* storage logic

---

## HARDCODED USERS

Create hardcoded data for 3 states:

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
* state
* city
* manager_id
* dealer_id
* created_at
* updated_at

Add login credentials.

---

## PROJECT DATA

Fields:

* project_name
* start_date
* end_date
* city
* state
* description
* created_at
* updated_at

Add additional fields:

* project_code
* manager_id
* status
* priority

Create proper relationships between:

* Manager
* Dealer
* User

---

## TASK DATA

Create hardcoded task listing.

Required fields:

* task_title
* project_id
* date
* utc_date
* nds (integer)
* dealer_name
* address
* state
* city
* district
* status
* site_type
* created_at
* updated_at

Additional fields:

* latitude
* longitude
* task_code
* manager_id
* user_id
* dealer_id
* remarks
* installation_location
* range_in_meter

Site Type:

* Field Office
* Construction Site

Status:

* pending
* in_progress
* completed
* rejected

---

## ROLE-BASED FEATURES

1. USER ROLE

Features:

* View projects
* View tasks
* Open project → related tasks
* Open task → details page
* Upload photos
* Edit/delete own uploaded photos

Condition:
Can upload/edit only if task status:

* pending
* in_progress

Completed:

* View only

---

2. DEALER ROLE

Features:

* View projects
* View tasks
* View user uploaded photos
* Upload own photos
* Edit/delete own uploads
* Mark task completed
* Reject task

Dealer:
Cannot modify user uploads.

Completed task:

* View only mode

---

3. MANAGER ROLE

Features:

* View all state tasks
* View all uploaded photos
* Upload photos
* Share task
* Monitor progress

Manager can see:

* Dealer uploads
* User uploads

---

## TASK DETAILS SCREEN

Existing:
task_details_screen.dart

Refactor into:

* widgets/
* cubit/
* state/
* reusable cards

Create reusable widgets:

* project_details_card.dart
* task_status_badge.dart
* task_statistics_card.dart
* photo_upload_section.dart
* uploaded_photo_grid.dart
* task_action_buttons.dart
* task_timeline_widget.dart
* location_info_card.dart

---

## TASK DETAILS FEATURES

Show:

* Assigned Date
* Dealer Name
* User Name
* District
* City
* Address
* Installation Location
* Status
* NDS
* Site Type
* Latitude/Longitude
* Range

Add:

* Photo upload section
* Camera support
* Gallery picker
* Uploaded image grid
* Image preview

Use:

* image_picker
* camera

---

## PERMISSION LOGIC

User:
Can edit/delete only own uploads.

Dealer:
Can edit/delete only dealer uploads.

Manager:
View all + share.

Completed task:
Disable all actions.

---

## UI REQUIREMENTS

Keep existing UI style.
Improve:

* modularity
* spacing
* readability
* reusability

Use:

* Material 3
* Google Fonts
* Clean enterprise UI

Avoid huge widget trees.

---

## IMPORTANT DEVELOPMENT RULES

* Do not create unnecessary files
* Keep reusable architecture
* Keep code scalable
* Use const constructors
* Use proper null safety
* Avoid duplicate widgets
* Create helper methods
* Add comments where needed
* Keep naming clean
* Use enums for status and roles
* Use extensions/helpers if needed

The application should behave like a real production-ready app using local JSON storage temporarily before real APIs are integrated later.
