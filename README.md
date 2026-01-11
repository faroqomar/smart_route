Smart Route Optimization App
Smart Route is a personal logistics assistant engineered for high-density navigation. It combines a clean, mobile-first Flutter interface with a powerful Python-based routing engine to solve complex Traveling Salesperson Problems (TSP) for shopping agents, delivery drivers, and tourism planners.

📚 Project Documentation
The project is guided by the following core documents:

MVP Definition
: Detailed breakdown of core features, technical constraints, and future vision.
Detailed Roadmap
: A step-by-step phased execution guide, serving as a learning resource for MVVM architecture and algorithm implementation.
Implementation Plan
: Current active task planning.
🚀 Key Features
Intelligent Routing: Optimizes visiting order for shortest time or distance.
Offline-First: SQL-based local storage ensures speed and privacy without internet dependency.
Store Memory: Save store details, photos, and precise locations.
Link Parsing: Auto-extract coordinates from Google Maps links.
Multi-Template: Ready for expansion into Delivery, Tourism, and Sales modes.
🛠 Tech Stack
Frontend: Flutter (Dart)
Architecture: MVVM (Model-View-ViewModel)
Database: Drift (SQLite)
Maps: Google Maps SDK
Backend: Python (FastAPI)
Engine: NetworkX / Google OR-Tools
Role: Stateless computation microservice
📂 Project Structure
smart_route/
├── backend/           # Python FastAPI Server (Optimization Logic)
└── lib/               # Flutter App Source
    ├── core/          # Shared utilities & Failure definitions
    ├── data/          # Repositories & Local Database
    └── presentation/  # UI Views & ViewModels
🏁 Getting Started
Refer to the 
Roadmap
 for the Phase-by-Phase implementation guide.