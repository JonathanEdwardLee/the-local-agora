import 'agora_event_signal.dart';

/// Chronological Agora ordering:
/// 1) known start ascending;
/// 2) known date with unknown time;
/// 3) unknown date/time last.
/// Stable secondary key: title then id.
List<AgoraEventSignal> sortAgoraSignalsChronologically(
  Iterable<AgoraEventSignal> input,
) {
  final list = List<AgoraEventSignal>.from(input);
  list.sort((a, b) {
    final rankA = _rank(a);
    final rankB = _rank(b);
    if (rankA != rankB) return rankA.compareTo(rankB);

    final startA = a.startsAt;
    final startB = b.startsAt;
    if (startA != null && startB != null) {
      final c = startA.compareTo(startB);
      if (c != 0) return c;
    }

    final dateA = a.displayedDate ?? '';
    final dateB = b.displayedDate ?? '';
    final dc = dateA.compareTo(dateB);
    if (dc != 0) return dc;

    final tc = a.title.compareTo(b.title);
    if (tc != 0) return tc;
    return a.id.compareTo(b.id);
  });
  return list;
}

int _rank(AgoraEventSignal s) {
  if (s.startsAt != null) return 0;
  final hasDate = (s.displayedDate ?? '').trim().isNotEmpty;
  final hasTime = (s.displayedTime ?? '').trim().isNotEmpty;
  if (hasDate && !hasTime) return 1;
  if (hasDate && hasTime) return 0; // date+time without parsed DateTime
  return 2;
}
