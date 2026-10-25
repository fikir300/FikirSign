import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'hands_types.dart';

/// Reads results from web/hands.js (MediaPipe Hand Landmarker in the browser).
class HandTracker {
  bool get supported => true;
  void start() => globalContext.callMethod<JSAny?>('fikrHandsStart'.toJS);
  void stop() => globalContext.callMethod<JSAny?>('fikrHandsStop'.toJS);

  HandState read() {
    final h = globalContext.getProperty<JSObject?>('fikrHands'.toJS);
    if (h == null) return const HandState();
    return HandState(
      ready: h.getProperty<JSBoolean?>('ready'.toJS)?.toDart ?? false,
      visible: h.getProperty<JSBoolean?>('visible'.toJS)?.toDart ?? false,
      frame: h.getProperty<JSString?>('frame'.toJS)?.toDart ?? '',
      hands: h.getProperty<JSNumber?>('hands'.toJS)?.toDartInt ?? 0,
      fingers: h.getProperty<JSNumber?>('fingers'.toJS)?.toDartInt ?? 0,
    );
  }
}
