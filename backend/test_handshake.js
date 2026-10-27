// test_handshake.js — Zero-dependency test
const ML_URL = "https://o7dchd3hgicxm3wtbtvcx44ega0akfeh.lambda-url.eu-north-1.on.aws/";
const API_KEY = "FikirSigns2026SecureKey";

async function runJointTest() {
  console.log("==================================================");
  console.log("🤝 RUNNING JOINT HANDSHAKE TEST: Node.js -> AWS ML");
  console.log(`Target URL: ${ML_URL}`);
  console.log("==================================================");

  // 1. Generate 30 dummy frames x 144 floats
  const dummyFrames = Array.from({ length: 30 }, () =>
    Array.from({ length: 144 }, () => Math.random() * 0.1)
  );

  try {
    const startTime = Date.now();

    // 2. Direct HTTPS fetch to AWS Lambda with secret key
    const response = await fetch(ML_URL, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': API_KEY
      },
      body: JSON.stringify({ frames: dummyFrames })
    });

    const latency = Date.now() - startTime;

    if (!response.ok) {
      const errText = await response.text();
      throw new Error(`AWS ML Error [${response.status}]: ${errText}`);
    }

    const result = await response.json();

    console.log(`\n🎉 SUCCESS! Handshake confirmed in ${latency} ms`);
    console.log("AWS Response Payload:");
    console.log(JSON.stringify(result, null, 2));
    console.log("\n✅ The Backend & ML Lambda are officially connected!");

  } catch (error) {
    console.error("\n❌ HANDSHAKE FAILED:");
    console.error(error.message);
  }
}

runJointTest();