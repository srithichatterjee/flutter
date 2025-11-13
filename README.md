# 🧠 FlashNotes – AI-Powered Notes + Quiz App (Flutter Demo)

## Project Overview

**FlashNotes** is a single-file Flutter application designed as an intelligent study tool. Users input their lecture notes or raw text, and the application simulates AI processing to generate actionable study materials, including a summary, key points, and interactive flashcard quiz questions.

This project serves as a comprehensive demonstration of core and advanced Flutter concepts covered in the accompanying Lab Manual.

## ✨ Key Features & Lab Topics Covered

| Feature | Lab Manual Experiment | Description |
| :--- | :--- | :--- |
| **Dynamic Generation** | 9a, 9b (API Simulation) | Takes raw text input and instantly generates a unique summary, key points, and quiz questions (simulating an external AI service). |
| **Interactive Flashcards** | 8a, 8b (Animations) & 5a (Stateful) | Quiz flashcards are interactive, using **setState** and an **AnimatedOpacity** for a smooth fade transition when the user taps to reveal the answer. |
| **Secure Input Flow** | 7a, 7b (Forms & Validation) | Uses the **Form** widget, **TextFormField**, and custom **Validator** logic to ensure a minimum amount of notes is provided before processing. |
| **Routing** | 4a, 4b (Navigation) | Navigation between the **Input Screen** and **Results Screen** is managed using the **Navigator** widget and **Named Routes** (`/` and `/results`). |
| **UI Component Reusability** | 6a (Custom Widgets) | The **`ResultSection`** and **`QuizFlashcard`** widgets are custom, reusable components built to display structured data cleanly. |

## 💻 How to Run Locally

This is a single-file Flutter application.

1.  **Clone the repository:**
    ```bash
    git clone [YOUR_REPO_URL]
    cd [YOUR_REPO_NAME]
    ```
2.  **Ensure App File is Present:** The main application logic resides in `project.dart`.
3.  **Run the app:**
    ```bash
    flutter run
    ```

## ⚠️ Note on AI Simulation

This prototype uses a **dynamic simulation function** to process the text locally, as DartPad and typical lab environments do not support external HTTP API calls. The output changes based on the length and first few words of your input, demonstrating the correct data flow and UI responsiveness required for a true AI-powered application.
cange the name of flash notes and put the  all the nercerssary content and readme file should have
