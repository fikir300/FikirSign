// backend/server.js
require('dotenv').config();
const express = require('express');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(express.json({ limit: '10mb' }));

const ML_ENDPOINT = process.env.ML_LAMBDA_URL || "https://o7dchd3hgicxm3wtbtvcx44ega0akfeh.lambda-url.eu-north-1.on.aws/";
const ML_API_KEY = process.env.ML_API_KEY || "FikirSigns2026SecureKey";

// Health check
app.get(['/', '/api/health'], (req, res) => {
  res.json({ status: 'online', service: 'Fikir Signs Bridge Backend' });
});

// Translation Route (Supports both /api/translate and /api/v1/translate)
app.post(['/api/translate', '/api/v1/translate'], async (req, res) => {
  try {
    const rawFrames = req.body.frames || req.body.landmarks;

    if (!rawFrames || !Array.isArray(rawFrames) || rawFrames.length === 0) {
      console.warn("⚠️ Empty or missing frames received from Flutter.");
      return res.status(400).json({ success: false, error: "Missing 'frames' array" });
    }

    console.log(`📥 Received ${rawFrames.length} frames from Flutter (features per frame: ${rawFrames[0].length})`);

    // 1. Standardize to 30 frames (Resample if Flutter sends 15-45 frames)
    let frames30 = rawFrames;
    if (rawFrames.length !== 30 && rawFrames.length >= 5) {
      frames30 = [];
      for (let i = 0; i < 30; i++) {
        const idx = Math.min(Math.round((i / 29) * (rawFrames.length - 1)), rawFrames.length - 1);
        frames30.push(rawFrames[idx]);
      }
    }

    // 2. CRITICAL ADAPTER: If Flutter sends 126 hand coordinates, pad with 18 zeros for Pose
    const standardizedFrames = frames30.map(frame => {
      if (frame.length === 126) {
        return [...frame, ...new Array(18).fill(0.0)]; // Pad to 144
      }
      return frame;
    });

    // 3. Forward to AWS ML Lambda
    const mlRes = await fetch(ML_ENDPOINT, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': ML_API_KEY
      },
      body: JSON.stringify({ frames: standardizedFrames })
    });

    if (!mlRes.ok) {
      const errText = await mlRes.text();
      throw new Error(`AWS ML Error [${mlRes.status}]: ${errText}`);
    }

    const data = await mlRes.json();
    console.log(`🧠 Recognized: ${data.sign} (${data.amharic}) [${(data.confidence * 100).toFixed(0)}%]`);

    return res.json({
      success: true,
      sign: data.sign || "IDLE",
      amharic: data.amharic || "ምንም ምልክት የለም",
      confidence: data.confidence || 0.0,
      top3: data.top3 || []
    });

  } catch (err) {
    console.error("❌ Translation error:", err.message);
    return res.status(500).json({ success: false, error: err.message });
  }
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, '0.0.0.0', () => {
  console.log("==================================================");
  console.log(`🚀 Fikir Signs Backend live on port ${PORT}`);
  console.log(`📡 Linked to AWS: ${ML_ENDPOINT}`);
  console.log("==================================================");
});