import 'event_location_privacy.dart';

/// Source-supported Agora event signal for the contest discovery vertical slice.
///
/// Unknown facts stay null / omitted — never invent ticket price, lineup, etc.
/// [sourceUrl] is null when no verified public source is available.
class AgoraEventSignal {
  const AgoraEventSignal({
    required this.id,
    required this.title,
    required this.sourceLabel,
    this.sourceUrl,
    this.startsAt,
    this.displayedDate,
    this.displayedTime,
    this.venueName,
    this.city,
    this.category,
    this.summary,
    this.lastCheckedAt,
    this.privacy = EventLocationPrivacy.venueOnly,
    this.uncertainties = const [],
  });

  final String id;
  final String title;
  final DateTime? startsAt;
  final String? displayedDate;
  final String? displayedTime;
  final String? venueName;
  final String? city;
  final String? category;
  final String? summary;

  /// Verified public HTTP(S) source, or null when unavailable.
  final Uri? sourceUrl;
  final String sourceLabel;
  final DateTime? lastCheckedAt;
  final EventLocationPrivacy privacy;
  final List<String> uncertainties;

  bool get hasLaunchableSource {
    final url = sourceUrl;
    if (url == null) return false;
    return (url.isScheme('https') || url.isScheme('http')) &&
        url.host.isNotEmpty;
  }

  String get locationLine {
    final parts = <String>[];
    if (venueName != null && venueName!.trim().isNotEmpty) {
      parts.add(venueName!.trim());
    }
    if (city != null && city!.trim().isNotEmpty) {
      parts.add(city!.trim());
    }
    if (parts.isEmpty) return 'VENUE NOT CONFIRMED';
    return parts.join(' // ');
  }

  String get whenLine {
    final date = displayedDate?.trim();
    final time = displayedTime?.trim();
    if ((date == null || date.isEmpty) && (time == null || time.isEmpty)) {
      return 'TIME NOT CONFIRMED';
    }
    if (date != null && date.isNotEmpty && time != null && time.isNotEmpty) {
      return '$date // $time';
    }
    if (date != null && date.isNotEmpty) return date;
    return 'TIME NOT CONFIRMED // $time';
  }
}
