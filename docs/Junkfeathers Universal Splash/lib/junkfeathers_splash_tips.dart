import 'dart:math';

/// Example app-neutral splash tips for reference and testing.
const List<String> exampleSplashTips = [
  'tip01',
  'tip02',
  'tip03',
];

/// Picks a splash tip from the provided list.
/// If [deterministicIndex] is provided, it selects the tip at that index (clamped to the list size).
/// Otherwise, it picks a random tip.
/// Safely returns an empty string if the list is empty.
String selectSplashTip(List<String> tips, {int? deterministicIndex}) {
  if (tips.isEmpty) {
    return '';
  }
  if (deterministicIndex != null) {
    return tips[deterministicIndex % tips.length];
  }
  return tips[Random().nextInt(tips.length)];
}
