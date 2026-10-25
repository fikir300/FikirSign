# FikirSign Match Backend (Part A)

AI phrase-matching serverless endpoint for **FikirSign**, an assistive communication application for hospital staff and deaf patients in Ethiopia.

The service accepts a transcribed or typed sentence, matches it against an approved medical phrase catalog (`phrases.json`), and returns the top matched phrase IDs with confidence scores along with logical clinical follow-up suggestions.

---

## Architecture Overview

```
                      +-----------------------------+
                      |   Flutter Client App        |
                      |   POST /match               |
                      +--------------+--------------+
                                     |
                                     v
                      +-----------------------------+
                      |   Amazon API Gateway        |
                      +--------------+--------------+
                                     |
                                     v
                      +-----------------------------+
                      |   AWS Lambda (Python 3.12)  |
                      |   lambda_function.py        |
                      +-------+-------------+-------+
                              |             |
        USE_BEDROCK=true      |             | Fallback on error,
        + Model ID set        |             | empty, or USE_BEDROCK=false
                              v             v
             +-------------------+       +--------------------+
             | Amazon Bedrock    |       | Local Fallback     |
             | Converse API      |       | (difflib + Unicode |
             | (temperature 0)   |       | + keyword index)   |
             +---------+---------+       +---------+----------+
                       |                           |
                       +------------+--------------+
                                    |
                                    v
                      +-----------------------------+
                      | Code Validation & Sanitizer |
                      | - Drop any unapproved ID    |
                      | - Clamp score 0.0 .. 1.0    |
                      | - Cap list to max 3 items   |
                      +--------------+--------------+
                                     |
                                     v
                      +-----------------------------+
                      | 200 OK Response             |
                      | {"phraseIds", "suggestions"}|
                      +-----------------------------+
```

1. **Amazon Bedrock (Converse API)**: Uses low-temperature semantic matching with prompt injection guardrails.
2. **Local Fallback Matcher**: Substring matching, Unicode-safe text normalization, `difflib` similarity, and clinical domain keywords. Guarantees that the endpoint never fails even if AWS Bedrock is unreachable or times out.
3. **Zero-Trust Output Validator**: Drops any phrase ID not in `phrases.json`, clamps scores to `0.0..1.0`, and caps list lengths.

---

## API Specification

### Endpoint: `POST /match`

#### Request Headers
```http
Content-Type: application/json
x-api-key: <OPTIONAL_API_KEY>
```

#### Request Body
```json
{
  "text": "Where does it hurt?",
  "lang": "en",
  "sessionId": "session-xyz-123"
}
```

- `text` *(string, required)*: The typed sentence or transcribed speech (1 to 300 characters).
- `lang` *(string, optional)*: Language code (`en` or `am`, defaults to `en`).
- `sessionId` *(string, optional)*: Chat session identifier.

#### Success Response (`200 OK`)
```json
{
  "phraseIds": [
    {
      "id": "p001",
      "score": 1.0
    }
  ],
  "suggestions": [
    "p002",
    "p004"
  ],
  "source": "ai"
}
```
*Note: `source` is `"ai"` when matched via Bedrock, or `"local"` when handled by the fallback matcher.*

#### Error Response (`400 Bad Request`)
Returned for invalid JSON, empty `text`, or `text` longer than 300 characters:
```json
{
  "error": "Field 'text' exceeds maximum length of 300 characters"
}
```

---

## Environment Variables

| Variable | Required | Default | Description |
| :--- | :--- | :--- | :--- |
| `BEDROCK_MODEL_ID` | Optional | *None* | Bedrock model identifier (e.g. `anthropic.claude-3-haiku-20240307-v1:0` or `meta.llama3-8b-instruct-v1:0`). |
| `BEDROCK_REGION` | Optional | `us-east-1` | AWS region where Bedrock model access is enabled. |
| `USE_BEDROCK` | Optional | `false` | Set to `true` to enable Bedrock LLM matching; set to `false` for offline local-only matching. |

---

## Local Testing on Windows (`cmd.exe`)

All commands below are formatted for Windows Command Prompt (`cmd.exe`).

### 1. Run local test suite (33 test cases + unit validator tests)
```cmd
cd C:\Users\ermiy\FikirSign\backend\match
set USE_BEDROCK=false
python test_local.py
```

### 2. Run local test suite with Bedrock enabled (requires AWS credentials & model ID)
```cmd
cd C:\Users\ermiy\FikirSign\backend\match
set USE_BEDROCK=true
set BEDROCK_MODEL_ID=anthropic.claude-3-haiku-20240307-v1:0
set BEDROCK_REGION=us-east-1
python test_local.py
```

---

## Building and Packaging the Zip

AWS Lambda runs Python 3.12 with `boto3` pre-installed in the runtime. The deployment artifact needs only `lambda_function.py` and `phrases.json`.

Run the automated builder script:
```cmd
cd C:\Users\ermiy\FikirSign\backend\match
python build_zip.py
```

This generates `function.zip` containing:
- `lambda_function.py`
- `phrases.json`

---

## Deployment to AWS Lambda

### Option A: AWS Management Console
1. Open the [AWS Lambda Console](https://console.aws.amazon.com/lambda).
2. Click **Create function** -> **Author from scratch**.
   - **Function name**: `FikirSignMatch`
   - **Runtime**: `Python 3.12`
   - **Architecture**: `x86_64` (or `arm64`)
3. Under **Code source**, click **Upload from** -> **.zip file** and select `C:\Users\ermiy\FikirSign\backend\match\function.zip`.
4. In **Runtime settings**, verify Handler is: `lambda_function.lambda_handler`.
5. In **Configuration** -> **General configuration**:
   - Set **Timeout**: `5 seconds` (Converse API client has a 3s read timeout).
   - Set **Memory**: `256 MB`.
6. In **Configuration** -> **Environment variables**, set:
   - `USE_BEDROCK` = `true`
   - `BEDROCK_MODEL_ID` = `<YOUR_MODEL_ID>` (e.g. `anthropic.claude-3-haiku-20240307-v1:0`)
   - `BEDROCK_REGION` = `us-east-1`

### Option B: AWS CLI (Windows cmd)
```cmd
cd C:\Users\ermiy\FikirSign\backend\match
aws lambda update-function-code --function-name FikirSignMatch --zip-file fileb://function.zip
```
