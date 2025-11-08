# 📺 YouTube-Lite Clone (Flutter Demo)

This is a single-file Flutter application designed to demonstrate key modern UI patterns, state management concepts, and responsive design techniques within the Flutter framework, built as a clone of a video streaming interface like YouTube.

The entire application logic, UI, and simulated API are contained in a single `main.dart` file for ease of analysis and lab exercises.

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## ✨ Core Features & Concepts

The application incorporates several core architectural and visual features:

### ⚙️ State and Architecture
* **Centralized State:** Uses a simple **Provider pattern** with a custom `ChangeNotifier` (`AppState`) wrapped in an `InheritedWidget` for efficient state management.
* **Async Simulation:** Employs `Future.delayed` to simulate network latency (`fetchTrending`, `fetchVideoDetails`), demonstrating proper handling of **loading states**.
* **Search Debouncing:** Includes logic in `ShellScreen` to debounce search input, optimizing performance.

### 🎨 UI and Responsiveness
* **Responsive Shell (`ShellScreen`):** Dynamically adapts layout based on screen width:
    * **Narrow (Mobile):** AppBar, Drawer, and Bottom Navigation Bar.
    * **Wide (Desktop/Tablet):** Persistent Left Rail and Right Rail (Player/Comments) flanking the main feed.
* **Visual Flair:** Features staggered list item animations (`SizeTransition`) and uses `FadeInImage` for video thumbnails with colorful fallbacks.
* **Video Player:** Includes a basic player placeholder with a **CustomPainter** (`_PlayerScrubPainter`) for the scrub/progress bar.

### 🎬 Interactions
* **Playback Simulation:** Tracks video position using `Timer.periodic`.
* **Forms & Validation:** The comment input (`_CommentInput`) demonstrates Flutter form validation.
* **Micro-Interactions:** Includes an animated **Subscribe** button (`AnimatedSwitcher`) and modal options.

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

## 🚀 Getting Started

This project is a standard Flutter application and requires no external packages.

### Prerequisites
* Flutter SDK installed and configured.

### Running the Application

1.  Save the entire code into a single file named `main.dart`.
2.  Run the application from your terminal:

```bash
flutter run
