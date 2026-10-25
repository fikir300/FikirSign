# FikirSign Healthcare Sign Language Translation & Matching Backend

AI phrase-matching, sign-composition, and real-time translation serverless endpoint for **FikirSign**, an assistive communication application for Ethiopian hospital staff and deaf patients using Ethiopian Sign Language (EthSL) and Amharic.

The backend is aligned with the **FikirSign Translator Screen** workflow:
1. Camera preview captures hand/facial gestures.
2. The on-device ML model recognizes a sign class, landmark sequence, or phrase concept.
3. The recognized result is submitted to the backend along with the user's preferred target language (`en` or `am`).
4. The backend validates the input, checks confidence, maps the concept, and returns clean, display-ready translated text.
5. The frontend displays the translation in the Translated Text area and offers Copy and Audio/TTS controls.

---

## Catalogs

### 1. `phrases.json` (Staff-side Phrase Catalog)
Contains **38 approved healthcare phrases** organized into 7 clinical categories:
- **Symptoms** (e.g., headache, stomach pain, chest pain, back pain, fever, cough, dizziness, nausea, difficulty breathing)
- **Medical History** (e.g., allergies, chronic conditions, prior surgery, current medications)
- **Examination** (e.g., sit down, open mouth, deep breath, where does it hurt?, when did pain start?, blood pressure)
- **Medication & Treatment** (e.g., take medicine twice a day, when to take, dosage questions)
- **Emergency Communication** (e.g., please help me, severe pain, immediate medical assistance)
- **Basic Communication** (e.g., yes, no, please, thank you, I do not understand, repeat, water, bathroom)
- **Appointments & Follow-up** (e.g., need appointment, when to return, where to go next)

### 2. `signs.json` (Patient-side Sign Classes)
Contains recognized sign classes from the on-device ML model (`pain`, `head`, `stomach`, `help`, `doctor`, `medicine`, `yes`, `no`).
> **Note**: These sign classes are **PLACEHOLDERS** to be replaced with the ML teammate's real class list.

---

## Language Selection & Safety Philosophy

### Target Languages
- **English (`en`)**: Spoken/written English translation.
- **Amharic (`am`)**: Spoken/written Amharic translation in Fidel script.
- **Default**: `en` if omitted.
- **Unsupported Codes**: Any code outside `{"en", "am"}` (e.g. `fr`, `es`) returns HTTP 400.

### Medical Safety & Confidence Handling
In healthcare, **a wrong translation is worse than no translation**.
- **Conservative Local Matcher**: Requires similarity score $\ge 0.6$. When unsure, returns an empty list (`[]`) rather than guessing.
- **Confidence Threshold**: If recognition `confidence < 0.50`, the service returns status `"uncertain"` with a prompt asking the patient to repeat the sign.
- **Zero-Trust Sanitizer**: Model output and input IDs are strictly validated against `phrases.json` or `signs.json`. Unrecognized signs return status `"unsupported"`.

---

## API Specifications

### 1. Direct Translation (`POST /translate` or direct sign input)
Aligned with the real-time Translator Screen.

#### Request Body
```json
{
  "signId": "head",
  "confidence": 0.94,
  "targetLanguage": "am"
}
```

#### Success Response (`200 OK`)
```json
{
  "status": "success",
  "translatedText": "ራስ ምታት አለብኝ።",
  "targetLanguage": "am",
  "recognizedConcept": "head",
  "signIds": ["head"],
  "confidence": 0.94,
  "source": "local"
}
```

#### Low Confidence Clarification Response (`200 OK`)
Returned when `confidence < 0.50`:
```json
{
  "status": "uncertain",
  "translatedText": "እባክዎ ምልክቱን እንደገና ያሳዩ (ግልጽ አልነበረም)።",
  "targetLanguage": "am",
  "confidence": 0.35,
  "recognizedConcept": null,
  "signIds": [],
  "source": "local"
}
```

#### Unsupported Concept Response (`200 OK`)
```json
{
  "status": "unsupported",
  "translatedText": "ያልታወቀ ወይም ያልተደገፈ ምልክት።",
  "targetLanguage": "am",
  "recognizedConcept": "unsupported_sign",
  "source": "local"
}
```

---

### 2. Sign Composition (`POST /compose`)
Composes multiple patient signs recognized into a statement.

#### Request Body
```json
{
  "signIds": ["pain", "stomach"],
  "targetLanguage": "en"
}
```

#### Success Response (`200 OK`)
```json
{
  "status": "success",
  "composedText": "I have stomach pain.",
  "translatedText": "I have stomach pain.",
  "targetLanguage": "en",
  "signIds": ["pain", "stomach"],
  "source": "local"
}
```

---

### 3. Staff Phrase Matching (`POST /match`)
Matches typed/spoken sentences to approved phrases in `phrases.json`.

#### Request Body
```json
{
  "text": "Where does it hurt?",
  "targetLanguage": "am"
}
```

#### Success Response (`200 OK`)
```json
{
  "status": "success",
  "phraseIds": [
    {
      "id": "p001",
      "score": 1.0
    }
  ],
  "suggestions": ["p002", "p004"],
  "translatedText": "የት ነው የሚያመዎት?",
  "targetLanguage": "am",
  "source": "local"
}
```

---

## Local Testing on Windows (`cmd.exe`)

Run the automated test suite covering all validators, language selections, confidence checks, and sentence tests:

```cmd
cd C:\Users\ermiy\FikirSign\backend\match
set USE_BEDROCK=false
python test_local.py
```

To run with Amazon Bedrock enabled:
```cmd
cd C:\Users\ermiy\FikirSign\backend\match
set USE_BEDROCK=true
set BEDROCK_MODEL_ID=anthropic.claude-3-haiku-20240307-v1:0
set BEDROCK_REGION=us-east-1
python test_local.py
```

---

## Building and Packaging the Deployment ZIP

The Lambda deployment artifact requires only the lightweight runtime files (`lambda_function.py`, `phrases.json`, and `signs.json`).

Run:
```cmd
cd C:\Users\ermiy\FikirSign\backend\match
python build_zip.py
```

This verifies and packages `function.zip` ready for AWS Lambda upload.
