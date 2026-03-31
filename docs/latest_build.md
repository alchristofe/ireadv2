# iRead V2: Latest Build Documentation (March 2026)

This document provides a detailed overview of the latest features and architectural updates implemented in the iRead V2 platform, focusing on the Admin Experience and Cloud Synchronization capabilities.

## 1. Premium Admin Portal Overhaul
The Admin Dashboard has undergone a complete visual and functional transformation to provide a high-end, "Super Admin" experience.

### Visual Design System
*   **Glassmorphism**: UI components utilize `BackdropFilter` with `sigmaX: 12, sigmaY: 12` and subtle white borders (`alpha: 0.1`) to create a frosted glass effect over deep slate backgrounds (`#0F172A`).
*   **Nebula Backgrounds**: Custom radial gradients create a dynamic, atmospheric feel throughout the authentication and dashboard flows.
*   **Typography**: Transitioned to **Outfit** for headings and **Inter** for body text via `google_fonts`, ensuring readability and a modern aesthetic.
*   **Interactive Mascot**: Integrated a Rive-based "Antfly" mascot (`assets/rive/antfly.riv`) that provides subtle micro-animations during idle states and loading transitions.

### Authentication Flow
*   **Firebase Integration**: Secure sign-in powered by `firebase_auth`.
*   **Responsive Login Card**: A constrained, centered login interface that adapts seamlessly between mobile, tablet, and desktop views.
*   **Intentional Friction**: High-quality loading delays (800ms) added to the login flow to enhance the perceived security and premium feel.

---

## 2. Curriculum Management System
A robust system for managing phonics content across multiple languages has been implemented.

### Multi-Language Control
The dashboard now supports independent management for:
*   **English**
*   **Filipino**
*   **Hiligaynon**

### Phonics Unit Lifecycle
*   **Dynamic Listing**: A categorized grid view of phonics units (Vowels, Consonants, Blends/Kambal) with real-time updates from Firestore.
*   **Resource Editing**: Comprehensive form for modifying unit properties:
    *   Phonics Letter & Sound descriptions.
    *   **Cloudinary Integration**: Fully automated media upload pipeline for both audio (.m4a/.mp3) and image (.png/.jpg) assets.
    *   **Phonetic Support**: Field for IPA/Phonetic transcriptions for each word example.
*   **Flashcard Management**: Drag-and-drop or list-based management of word examples associated with each phonics unit.

---

## 3. Cloud Synchronization & Offline Capability
The platform now ensures a seamless experience even in low-connectivity environments.

### CloudSyncService
Located at `lib/data/services/cloud_sync_service.dart`, this service manages the edge-to-cloud relationship:
*   **Version Comparison**: Compares `updatedAt` timestamps between Firestore and local storage to determine which units need updating.
*   **Media Localization**: Automatically detects network URLs (Cloudinary) and downloads them to the device's local documents directory (`/offline_media/`).
*   **Lazy Sync**: Minimizes bandwidth usage by only downloading changed or missing assets.

### Technology Stack Highlights
*   **Frontend**: Flutter (Latest Stable)
*   **Backend**: Firebase (Auth, Firestore, Storage)
*   **Media**: Cloudinary (Network transformation & hosting)
*   **Animation**: Rive (Interactive vector animations)
*   **Icons**: Material Symbols Rounded & Custom SVGs

---

## 4. Build Details
*   **Version**: `1.0.0+1`
*   **Minimum SDK**: Dart `3.10.1`
*   **Platform Support**: Web (Admin Console), Mobile/Tablet (Teacher/Student Apps)
