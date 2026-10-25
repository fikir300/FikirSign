/// What the hand detector sees right now.
class HandState {
  final bool ready, visible;
  final String frame; // JSON: 21 points [x, y, z]
  final int hands, fingers; // fingers = how many fingers are extended
  const HandState({this.ready = false, this.visible = false, this.frame = '', this.hands = 0, this.fingers = 0});
}
