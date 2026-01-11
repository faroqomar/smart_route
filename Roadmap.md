Smart Route Detailed Project Roadmap
This document outlines the step-by-step execution plan for the Smart Route application. It is designed to be a learning guide, explaining the why and how of each technical decision.

Phase 1: Foundation & Architecture Setup
Goal: Establish a robust codebase that supports scaling without refactoring later.

1.1: Flutter Project Structure (MVVM)
What to do: Create the folder hierarchy to separate UI, Logic, and Data.
How to do it:
Create lib/core/ for shared utilities (theme, constants, failures).
Create lib/data/ for the Repository pattern.
Create lib/presentation/ for UI and ViewModels.
Why: Separation of concerns makes the app testable and easier to read.
1.2: Local Database Setup (Drift/SQLite)
What to do: Initialize the local SQLite database using the Drift package.
How to do it:
Add drift, sqlite3_flutter_libs, path_provider to
pubspec.yaml
.
Create database.dart extending DriftDatabase.
Define Stores and Routes tables as Dart classes.
Run dart run build_runner build to generate the database code.
Why: Drift allows writing SQL logic in Dart, providing type safety and auto-completion.
1.3: FastAPI Backend Scaffold
What to do: Set up the Python server for the stateless optimization logic.
How to do it:
Create a backend/ folder.
Create a virtual environment (python -m venv venv).
Install fastapi and uvicorn.
Create main.py with a simple “Hello World” root endpoint.
Why: Keeping the backend separate allows you to change optimization logic without redeploying the mobile app.
Phase 2: Store Management System
Goal: Allow users to create, read, update, and delete (CRUD) store data locally.

2.1: Store Data Modeling
What to do: creating the Store entity and Data Transfer Objects (DTOs).
How to do it:
Define a Store class in Drift.
Fields: id, name, category, notes, address, lat, lng, photoPath, googleMapsUrl.
Create a StoreRepository abstract class and its implementation StoreRepositoryImpl.
2.2: Google Maps Link Parser
What to do: Extract coordinates from a shared Google Maps URL.
How to do it:
Create a regex utility or simple HTTP service.
When a user pastes a link (https://goo.gl/maps/…), resolve the redirect to get the full URL.
Regex extract !3d{LAT}!4d{LNG} or @{LAT},{LNG}.
Why: Manual coordinate entry is error-prone; this automates it.
2.3: Photo Handling
What to do: Save images to the device’s file system and store the path in the DB.
How to do it:
Use image_picker package to capture/select photos.
Use path_provider to find the App Document Directory.
Copy the image file to a persistent local folder.
Save only the String path in SQLite, not the Blob.
Why: Storing images directly in SQLite bloats the database and slows queries.
2.4: UI Implementation (Stores)
What to do: Build the screens for listing and adding stores.
How to do it:
StoreListScreen: Use a StreamBuilder listening to Drift’s watch stores.
AddStoreScreen: Form with validation. Use TextEditingController.
StoreViewModel: Handle logic like “Save Store” which calls repository.addStore().
Phase 3: Route Calculation Engine (The Brain)
Goal: Connect the Flutter app to the Python backend to solve the Traveling Salesperson Problem (TSP).

3.1: Optimization Algorithm (Backend)
What to do: Implement the logic to sort locations efficiently.
How to do it:
Use networkx or google-ortools in Python.
Receive a JSON payload: {“start”: {lat, lng}, “stores”: [{id, lat, lng}, …], “end”: {lat, lng}}.
Calculate a Distance Matrix (distance between every pair of points).
Solve for the shortest path visiting all nodes.
Return the ordered list of Store IDs.
3.2: API Integration (Frontend)
What to do: Send data to backend and parse response.
How to do it:
Use http or dio package.
Create OptimizationService.
POST the selected stores to your local IP (e.g., 10.0.2.2 for Android emulator or your Mac’s IP for iOS).
Handle timeouts and offline errors gracefully.
3.3: Route Builder UI
What to do: A screen to select which stores to visit today.
How to do it:
Multi-select list from your saved stores.
“Optimize” button triggers the API call.
Loading state (spinner) while waiting for Python.
Phase 4: Visualization & Navigation
Goal: Show the result on a map and let the user drive/walk.

4.1: Map Visualization
What to do: Display pins and lines on a map.
How to do it:
Use google_maps_flutter or flutter_map (OpenStreetMap).
Draw Markers for each store in the optimized list.
Draw a Polyline connecting them in order.
Label markers nicely (1, 2, 3…).
4.2: Navigation Actions
What to do: One-click deep link to external navigation.
How to do it:
Use url_launcher.
Format: google.navigation:q={lat},{lng} (Android) or comgooglemaps://?daddr={lat},{lng} (iOS).
Provide a “GO” button next to each stop in the list.
Phase 5: Saved Routes & Templates
Goal: Save time by reusing common routes.

5.1: Saved Route Schema
What to do: Store the result of an optimization.
How to do it:
New Table SavedRoutes.
Fields: id, name, orderedStoreIds (stored as JSON string or separate relation table).
createdAt.
5.2: Template Management UI
What to do: Load a previous route.
How to do it:
Screen listing saved routes.
Tapping one loads the stores into the Route Builder, pre-selected.
Phase 6: Multi-language Support
Goal: Accessibility for Arabic, Turkish, and English speakers.

6.1: Localization Setup
What to do: Externalize all strings.
How to do it:
Use flutter_localizations and intl package.
Create arb files: app_en.arb, app_ar.arb, app_tr.arb.
Replace hardcoded strings with S.of(context).stringName.
6.2: Dynamic Reference
What to do: Allow language switching at runtime.
How to do it:
Store user preference in shared_preferences.
Wrap the MaterialApp in a provider that rebuilds when locale changes.
Phase 7: Statistics & Insights
Goal: Gamify the experience and show value.

7.1: Trip Logging
What to do: Record when a trip is “Finished”.
How to do it:
Add a “Complete Route” button.
Log entry in TripHistory table: date, storesVisitedCount, totalDistance.
7.2: Dashboard UI
What to do: Visual improvements.
How to do it:
Simple charts (using fl_chart) showing trips per week.
“Best Time” records.
Phase 8: Final Polishing & Release
Goal: Make it feel like a pro app.

8.1: Add Skeleton Loaders (shimmer effect) while data loads.
8.2: Create App Icon and Launch Screen.
8.3: Run flutter build ipa and flutter build apk for physical device installation.