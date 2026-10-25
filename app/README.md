# FikirSign (ፍቅር ሳይን)

A chat-style mobile application (like ChatGPT / Claude) built with Flutter to facilitate seamless communication between Ethiopian hospital staff and deaf patients using Ethiopian Sign Language (EthSL) and Amharic.

---

## Getting Started

### Prerequisites
- **Flutter SDK**: `>= 3.44.0` (Dart `>= 3.12.0`)
- **Android SDK**: `minSdkVersion 24`
- An Android or iOS device / emulator with camera and microphone permissions enabled.

### Setup & Run Instructions

1. **Navigate to the app directory**:
   ```bash
   cd app
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Configure environment variables**:
   Create your local `.env` file from the provided example template:
   - On Windows (PowerShell):
     ```powershell
     Copy-Item .env.example .env
     ```
   - On macOS / Linux:
     ```bash
     cp .env.example .env
     ```
   Verify keys in `.env`:
   ```env
   API_BASE_URL=https://example.execute-api.region.amazonaws.com/prod
   API_KEY=changeme
   USE_MOCK_API=true
   ```

4. **Run static analysis & tests**:
   ```bash
   flutter analyze
   flutter test
   ```

5. **Launch the application**:
   ```bash
   flutter run
   ```

---

## Project Structure (`lib/`)

```
app/
├── .env                  # Local secret configs (ignored by git)
├── .env.example          # Safe template committed to git
├── assets/
│   └── phrases.json      # 5 sample curated ESL phrases (id, en, am, category)
├── lib/
│   ├── main.dart         # Entry point: loads .env and starts FikirSignApp
│   ├── app.dart          # MaterialApp, routes, theme switcher, and localizations
│   ├── core/
│   │   ├── config/
│   │   │   └── env.dart            # Reads API_BASE_URL, API_KEY, USE_MOCK_API
│   │   ├── constants/
│   │   │   └── app_constants.dart  # Route names, timeout duration, headers
│   │   ├── theme/
│   │   │   └── app_theme.dart      # Light & high-contrast themes, large text
│   │   └── utils/
│   │       └── formatters.dart     # Timestamp and confidence formatting
│   ├── models/
│   │   ├── chat_message.dart       # id, timestamp, sender, type, text, phraseId, confidence
│   │   └── phrase.dart             # id, en, am, category
│   ├── data/
│   │   ├── phrase_repository.dart  # Loads & queries assets/phrases.json
│   │   └── api_client.dart         # POST /match and /feedback (3s timeout, mock mode)
│   ├── services/
│   │   ├── recognition_service.dart# Abstract ESL service + stub returning {phraseId, confidence}
│   │   ├── tts_service.dart        # Thin wrapper over flutter_tts (English & Amharic)
│   │   └── stt_service.dart        # Thin wrapper over speech_to_text
│   └── features/
│       ├── chat/                   # Main chat timeline
│       │   ├── chat_screen.dart
│       │   └── widgets/
│       │       ├── composer_bar.dart
│       │       ├── message_bubble.dart
│       │       └── suggestion_chips.dart
│       ├── sign_input/             # Sign camera modal sheet placeholder
│       │   └── sign_input_sheet.dart
│       ├── phrase_library/         # Categorized phrase catalog & search
│       │   └── phrase_library_screen.dart
│       ├── feedback/               # Accuracy reporting & correction submission
│       │   └── feedback_screen.dart
│       ├── settings/               # High-contrast toggle, API status & medical limitations
│       │   └── settings_screen.dart
│       └── onboarding/             # Clinical consent and camera permission notice
│           └── consent_screen.dart
└── test/
    └── widget_test.dart            # App smoke test
```

---

## Branch & Pull Request Rules

1. **Branch Naming Conventions**:
   - `feature/<short-description>`: New UI or logic additions (e.g., `feature/camera-stream`)
   - `fix/<issue-description>`: Bug and regression fixes (e.g., `fix/audio-permission`)
   - `chore/<task>`: Dependency upgrades, CI, and tooling (e.g., `chore/lint-rules`)

2. **Quality Gates Before Opening a PR**:
   Every PR must satisfy the following checks before merge approval:
   ```bash
   flutter analyze --no-fatal-infos
   flutter test
   ```
   PRs introducing analyzer errors or failing tests will not be merged.

3. **Secrets Management**:
   - Never commit `.env`, keystore files (`*.jks`, `*.keystore`), `key.properties`, or AWS credentials.
   - Any new environment variable must be documented in `.env.example`.

4. **Medical & Accessibility Guidelines**:
   - Ensure color contrast complies with WCAG AA/AAA.
   - Preserve large touch targets and readable font sizes across all clinical screens.
