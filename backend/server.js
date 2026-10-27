// server.js
require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { predictSign } = require('./mlService');

const app = express();
app.use(cors());
app.use(express.json({ limit: '5mb' }));

app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', service: 'Fikir Signs Backend' });
});

// Route called by Flutter: POST /api/v1/translate
app.post('/api/v1/translate', async (req, res) => {
  try {
    const { frames } = req.body;

    if (!frames || frames.length !== 30 || frames[0].length !== 144) {
      return res.status(400).json({
        success: false,
        error: "Expected 30 frames of 144 landmarks each."
      });
    }

    // Call ML Service
    const prediction = await predictSign(frames);

    return res.json({
      success: true,
      sign: prediction.sign,
      amharic: prediction.amharic,
      confidence: prediction.confidence,
      top3: prediction.top3 || []
    });

  } catch (err) {
    console.error("Translation Pipeline Error:", err.message);
    return res.status(500).json({ success: false, error: err.message });
  }
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Backend running on port ${PORT}`);
});