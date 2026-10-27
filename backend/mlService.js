// mlService.js
require('dotenv').config();

const ML_URL = process.env.ML_LAMBDA_URL;
const API_KEY = process.env.ML_API_KEY;

async function predictSign(frames30x144) {
  // 1. Contract Validation
  if (!frames30x144 || frames30x144.length !== 30) {
    throw new Error(`Invalid frames: Expected 30 frames, received ${frames30x144 ? frames30x144.length : 0}`);
  }

  // 2. HTTP POST to AWS Lambda with credentials
  const response = await fetch(ML_URL, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-api-key': API_KEY  // <--- Credentials passed here!
    },
    body: JSON.stringify({ frames: frames30x144 })
  });

  if (!response.ok) {
    const errorBody = await response.text();
    throw new Error(`AWS ML Error [${response.status}]: ${errorBody}`);
  }

  return await response.json();
}

module.exports = { predictSign };