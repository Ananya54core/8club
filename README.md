

## 🏆 Hotspot Host Onboarding App

A Flutter-based onboarding experience built for the **Hotspot Host Internship Assignment**.
This app provides an elegant and engaging way for users to apply as a host by sharing their experiences through text, audio, and video — all wrapped in a smooth and visually appealing user journey. ✨


video link : https://drive.google.com/file/d/10lXyuf4bJOvDnMAhnseoetTmmZmctgMt/view?usp=sharing
---

## 🚀 Overview

The app allows a user to:

* Select areas of experience and describe them.
* Record or upload an **audio or video** answer about why they want to become a host.
* Review all their details on a **summary screen** before submission.

It’s designed with a focus on **user delight, clarity, and interactivity** — reflecting both strong Flutter fundamentals and product design thinking.

---

## 🌟 Features Implemented

### 🧩 Core Functionality

* **Experience Selection Screen:**
  Users can select one or more experiences and add a short description to personalize their onboarding journey.

* **Onboarding Question Screen:**

  * Record **audio responses** directly using the microphone.
  * Record **video responses** using the camera.
  * Option to **pick video files** from the gallery for flexibility.
  * **Playback audio** and **preview video** before submitting.
  * Responsive character counter for text input (max 600 chars).

* **Summary Screen:**
  Displays a **final overview** of all user inputs (experience selections, text, audio, and video) before submission — ensuring transparency and completion confidence.

---

## 🎯 Brownie Point Items Implemented

These elements go beyond functionality to demonstrate **attention to detail and UI/UX excellence**:

* 🎨 **Modern UI/UX Design:**
  Smooth gradients, rounded cards, subtle shadows, and consistent typography for a polished visual identity.

* 🌀 **Animations and Transitions:**

  * Fade and slide animations for screen transitions.
  * Animated waveform while recording audio for a dynamic touch.
  * Button animations for better interactivity feedback.

* 🔊 **Media Interactivity:**

  * Audio playback with real-time status updates.
  * Video playback within the app using `video_player`.

* 📱 **Responsive Layout:**
  Optimized for mobile viewing, scrollable content with bounce physics, and consistent spacing.

* 💬 **User Guidance:**
  Labels like “Optional,” “Step 2 of 2,” and progress indicators for clarity and guided onboarding.

* ✅ **Submission Flow:**
  Snackbar-based success message confirming application submission — simple yet effective UX closure.

---

## 🧠 Additional Enhancements

* **Summary Screen (Overview Page):**
  Added an additional screen summarizing all input data before final submission — showcasing thoughtful product completion.

* **Permissions Handling:**
  Integrated `permission_handler` to gracefully request microphone and camera access at runtime.

* **Error Handling and Safe Operations:**
  Included fallback logs and exception handling for media recording and playback to ensure stability.

* **Clean Architecture Approach:**
  Structured code into modular sections (UI builders, logic handlers, animations) for readability and maintainability.

---

## 🛠️ Tech Stack

* **Framework:** Flutter
* **Language:** Dart
* **Packages Used:**

  * `flutter_sound` – for audio recording
  * `audioplayers` – for playback
  * `image_picker` – for capturing or selecting videos
  * `video_player` – for in-app video preview
  * `permission_handler` – for runtime permissions

---

## 💡 Future Improvements

* Add backend API integration for actual submission of responses.
* Store media securely in Firebase Storage or S3.
* Integrate onboarding analytics for drop-off tracking.
* Provide theme customization (dark/light mode).

---

## ✨ Developer Notes

This project focuses on:

* Crafting a **delightful onboarding flow** that feels professional and interactive.
* Demonstrating both **technical fluency in Flutter** and **UI/UX empathy**.
* Balancing performance, animation, and user experience — ideal for an internship or pre-production showcase app.

---

## 📸 Preview 
video link : https://drive.google.com/file/d/10lXyuf4bJOvDnMAhnseoetTmmZmctgMt/view?usp=sharing
---

## 🧑‍💻 Author

**Ananya Sah**
🌐 Flutter Developer | UI/UX Enthusiast
📧 ananyasah0512@gmail.com

