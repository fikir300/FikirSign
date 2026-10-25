import 'hands_types.dart';

/// Used on platforms without hand detection (Android/iOS for now).
class HandTracker {
  bool get supported => false;
  void start() {}
  void stop() {}
  HandState read() => const HandState();
}
