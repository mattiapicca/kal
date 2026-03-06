# Kal

Kal is an AI-powered iOS app for calorie and macro tracking through food photo analysis.

The product is inspired by the core loop of Cal AI, but intentionally scoped as a narrow MVP focused on:
- daily calorie and macro target calculation
- AI meal analysis from a photo
- manual review and correction of estimated results
- daily nutrition tracking and simple history

Kal is designed to feel like a lightweight AI companion for nutrition tracking: fast, simple, editable, and trustworthy.

---

## Product scope

### In scope
Kal currently includes only these product capabilities:

1. User onboarding
2. Personal goal setup
3. Daily calorie target calculation
4. Daily macro target calculation
5. Food photo upload or capture
6. AI-based meal estimation
7. Manual review and correction of meal results
8. Save meal to diary
9. Daily intake summary
10. Simple meal history

### Out of scope
Unless explicitly requested, Kal does **not** include:

- workout plans
- exercise logging
- gym routines
- recipe generation
- grocery lists
- barcode scanning
- wearables integrations
- social features
- challenges, streaks, or gamification
- coaching chat systems
- Android app
- web app
- admin dashboard
- speculative monetization systems

---

## Core user loop

Every feature should support this loop:

1. User understands their calorie and macro target
2. User logs food quickly with a photo
3. User reviews and corrects the estimate if needed
4. User saves the meal
5. User sees daily progress

If a feature does not improve this loop or directly support it, it should probably not be built.

---

## Product principles

Kal should feel:

- simple
- fast
- mobile-native
- trustworthy
- editable
- non-judgmental

### Key principles
- AI estimates are estimates, not facts
- Users must always be able to review and correct results
- The app should reduce friction, not increase it
- The MVP should stay narrow
- Fewer screens and fewer decisions are better
- Avoid overengineering in both product and code

---

## Tech direction

This repository is structured for a focused iOS-first product.

### Current direction
- **Platform:** iOS
- **Frontend:** SwiftUI
- **Architecture:** pragmatic MVVM
- **Async model:** async/await
- **Backend:** Supabase / Postgres
- **Storage:** image storage for meal photos
- **AI flow:** structured meal analysis with validation before persistence

### Important engineering rules
- Keep business logic out of views where practical
- Prefer small, focused files
- Prefer explicit contracts over hidden magic
- Keep database and API design simple
- Avoid speculative abstractions
- Make all AI-derived nutrition results editable

---

## Repository structure

```text
.
├── .cursor/
│   ├── agents/
│   ├── plans/
│   └── rules/
├── apps/
│   └── ios/
├── backend/
├── docs/
│   └── product/
├── README.md
└── .gitignore