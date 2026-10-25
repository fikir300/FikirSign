import { FilesetResolver, HandLandmarker } from "https://cdn.jsdelivr.net/npm/@mediapipe/tasks-vision@0.10.14/vision_bundle.mjs";

const WASM = "https://cdn.jsdelivr.net/npm/@mediapipe/tasks-vision@0.10.14/wasm";
const MODEL = "https://storage.googleapis.com/mediapipe-models/hand_landmarker/hand_landmarker/float16/1/hand_landmarker.task";
const MIN_SCORE = 0.7; // ignore weak detections (faces, shadows, random shapes)

window.fikrHands = { ready: false, visible: false, frame: "", hands: 0, fingers: 0, running: false };
let landmarker = null;
let lastTime = -1;

const d = (a, b) => Math.hypot(a.x - b.x, a.y - b.y);

// Counts extended fingers, whatever the hand's orientation.
function countFingers(p) {
  let n = 0;
  for (const [tip, pip] of [[8, 6], [12, 10], [16, 14], [20, 18]]) if (d(p[tip], p[0]) > d(p[pip], p[0]) * 1.15) n++;
  if (d(p[4], p[17]) > d(p[3], p[17]) * 1.05 && d(p[4], p[5]) > d(p[3], p[5])) n++; // thumb
  return n;
}

window.fikrHandsStart = async () => {
  const H = window.fikrHands;
  H.running = true;
  try {
    if (!landmarker) {
      const fileset = await FilesetResolver.forVisionTasks(WASM);
      const make = (delegate) => HandLandmarker.createFromOptions(fileset, {
        baseOptions: { modelAssetPath: MODEL, delegate }, runningMode: "VIDEO", numHands: 2,
        minHandDetectionConfidence: MIN_SCORE, minHandPresenceConfidence: MIN_SCORE, minTrackingConfidence: MIN_SCORE,
      });
      try { landmarker = await make("GPU"); } catch { landmarker = await make("CPU"); }
    }
  } catch (e) { console.error("Hand model failed to load", e); return; }
  H.ready = true;
  const loop = () => {
    if (!H.running) return;
    const v = document.querySelector("video");
    if (v && v.readyState >= 2 && v.currentTime !== lastTime) {
      lastTime = v.currentTime;
      const r = landmarker.detectForVideo(v, performance.now());
      const ok = r.landmarks.length > 0 && (r.handedness?.[0]?.[0]?.score ?? 0) >= MIN_SCORE;
      H.hands = ok ? r.landmarks.length : 0;
      H.visible = ok;
      H.fingers = ok ? countFingers(r.landmarks[0]) : 0;
      H.frame = ok ? JSON.stringify(r.landmarks[0].map((p) => [p.x, p.y, p.z])) : "";
    }
    requestAnimationFrame(loop);
  };
  loop();
};

window.fikrHandsStop = () => {
  const H = window.fikrHands;
  H.running = false; H.ready = false; H.visible = false; H.frame = ""; H.hands = 0; H.fingers = 0;
};
