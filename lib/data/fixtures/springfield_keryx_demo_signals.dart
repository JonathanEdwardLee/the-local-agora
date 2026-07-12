import '../../services/keryx/agora_event_signal.dart';
import '../../services/keryx/event_location_privacy.dart';

/// Demonstration provenance timestamp (Pass 01 evaluation window).
final DateTime kSpringfieldDemoLastChecked = DateTime.utc(2026, 7, 10, 18, 0);

/// Verified-Keryx-derived demonstration signals (see FIXTURE_PROVENANCE.md).
///
/// Not the exact Pass 02B.2A 10-signal live JSON. Public-safe fields only.
final List<AgoraEventSignal> kSpringfieldKeryxDemoSignals = [
  AgoraEventSignal(
    id: 'demo-music-01',
    title: 'PET SOUNDS LIVE',
    startsAt: null,
    displayedDate: '2026-07-11',
    displayedTime: null,
    venueName: null,
    city: 'Springfield, Missouri',
    category: 'MUSIC',
    summary: 'Source-supported music signal from Pass 01 MUSIC evaluation set.',
    sourceUrl: Uri.parse('https://example.com/agora-demo/pet-sounds-live'),
    sourceLabel: 'Venue calendar (demo provenance)',
    lastCheckedAt: null, // filled at scan from kSpringfieldDemoLastChecked
    privacy: EventLocationPrivacy.cityOnly,
    uncertainties: ['TIME NOT CONFIRMED', 'VENUE NOT CONFIRMED'],
  ),
  AgoraEventSignal(
    id: 'demo-music-02',
    title: 'Live Music @ Tie & Timber Beer Co.',
    displayedDate: '2026-07-11',
    displayedTime: null,
    venueName: 'Tie & Timber Beer Co.',
    city: 'Springfield, Missouri',
    category: 'MUSIC',
    summary: 'Friday/Saturday live music sessions noted in Pass 01 MUSIC set.',
    sourceUrl: Uri.parse('https://example.com/agora-demo/tie-timber'),
    sourceLabel: 'Venue listing (demo provenance)',
    privacy: EventLocationPrivacy.venueOnly,
    uncertainties: ['TIME NOT CONFIRMED'],
  ),
  AgoraEventSignal(
    id: 'demo-music-03',
    title: 'Live From Downtown: Sister Lucille',
    displayedDate: '2026-07-12',
    displayedTime: '19:00',
    startsAt: null, // keep date+time display without forcing parse ambiguity
    venueName: 'Downtown Springfield',
    city: 'Springfield, Missouri',
    category: 'MUSIC',
    summary: 'Downtown live music signal from Pass 01 MUSIC evaluation set.',
    sourceUrl: Uri.parse('https://example.com/agora-demo/sister-lucille'),
    sourceLabel: 'Event listing (demo provenance)',
    privacy: EventLocationPrivacy.generalArea,
    uncertainties: const [],
  ),
  AgoraEventSignal(
    id: 'demo-music-04',
    title: 'WonkyWilla at The Regency Live',
    displayedDate: '2026-07-11',
    displayedTime: '20:00',
    venueName: 'The Regency Live',
    city: 'Springfield, Missouri',
    category: 'MUSIC',
    summary:
        'Regency Live music signal retained from Pass 01 evaluation titles.',
    sourceUrl: Uri.parse('https://example.com/agora-demo/wonkywilla'),
    sourceLabel: 'Venue calendar (demo provenance)',
    privacy: EventLocationPrivacy.venueOnly,
  ),
  AgoraEventSignal(
    id: 'demo-music-05',
    title: 'Candlelight: Coldplay & Imagine Dragons',
    displayedDate: '2026-07-13',
    displayedTime: null,
    venueName: null,
    city: 'Springfield, Missouri',
    category: 'MUSIC',
    summary: 'Candlelight tribute program noted in Pass 01 MUSIC set.',
    sourceUrl: Uri.parse('https://example.com/agora-demo/candlelight-coldplay'),
    sourceLabel: 'Promoter listing (demo provenance)',
    privacy: EventLocationPrivacy.cityOnly,
    uncertainties: ['VENUE NOT CONFIRMED', 'TIME NOT CONFIRMED'],
  ),
  AgoraEventSignal(
    id: 'demo-music-06',
    title: 'Candlelight: Fleetwood Mac',
    displayedDate: '2026-07-14',
    displayedTime: null,
    venueName: null,
    city: 'Springfield, Missouri',
    category: 'MUSIC',
    summary: 'Candlelight tribute program noted in Pass 01 MUSIC set.',
    sourceUrl: Uri.parse(
      'https://example.com/agora-demo/candlelight-fleetwood',
    ),
    sourceLabel: 'Promoter listing (demo provenance)',
    privacy: EventLocationPrivacy.cityOnly,
    uncertainties: ['VENUE NOT CONFIRMED', 'TIME NOT CONFIRMED'],
  ),
  AgoraEventSignal(
    id: 'demo-music-07',
    title: "Live Music at Gailey's Cafe",
    displayedDate: '2026-07-12',
    displayedTime: null,
    venueName: "Gailey's Cafe",
    city: 'Springfield, Missouri',
    category: 'MUSIC',
    summary: 'Cafe live music signal from Pass 01 MUSIC evaluation set.',
    sourceUrl: Uri.parse('https://example.com/agora-demo/gaileys'),
    sourceLabel: 'Venue listing (demo provenance)',
    privacy: EventLocationPrivacy.venueOnly,
    uncertainties: ['TIME NOT CONFIRMED'],
  ),
  AgoraEventSignal(
    id: 'demo-music-08',
    title: 'La Reunión Norteña',
    displayedDate: '2026-07-15',
    displayedTime: '21:00',
    venueName: null,
    city: 'Springfield, Missouri',
    category: 'MUSIC',
    summary: 'Music signal retained from Pass 01 MUSIC evaluation titles.',
    sourceUrl: Uri.parse('https://example.com/agora-demo/la-reunion'),
    sourceLabel: 'Event listing (demo provenance)',
    privacy: EventLocationPrivacy.cityOnly,
    uncertainties: ['VENUE NOT CONFIRMED'],
  ),
  AgoraEventSignal(
    id: 'demo-comedy-01',
    title: 'Eric Eaton Live',
    displayedDate: '2026-07-10',
    displayedTime: null,
    venueName: 'Springfield Comedy Club',
    city: 'Springfield, Missouri',
    category: 'COMEDY',
    summary: 'Comedy signal from Pass 01 broad evaluation titles.',
    sourceUrl: Uri.parse('https://example.com/agora-demo/eric-eaton'),
    sourceLabel: 'Venue calendar (demo provenance)',
    privacy: EventLocationPrivacy.venueOnly,
    uncertainties: ['TIME NOT CONFIRMED'],
  ),
];

/// Applies the shared last-checked stamp used by the demo service.
List<AgoraEventSignal> springfieldDemoSignalsWithLastChecked() {
  return [
    for (final s in kSpringfieldKeryxDemoSignals)
      AgoraEventSignal(
        id: s.id,
        title: s.title,
        startsAt:
            s.startsAt ?? _tryParseStart(s.displayedDate, s.displayedTime),
        displayedDate: s.displayedDate,
        displayedTime: s.displayedTime,
        venueName: s.venueName,
        city: s.city,
        category: s.category,
        summary: s.summary,
        sourceUrl: s.sourceUrl,
        sourceLabel: s.sourceLabel,
        lastCheckedAt: kSpringfieldDemoLastChecked,
        privacy: s.privacy,
        uncertainties: s.uncertainties,
      ),
  ];
}

DateTime? _tryParseStart(String? date, String? time) {
  if (date == null || date.isEmpty) return null;
  if (time == null || time.isEmpty) return null;
  try {
    final parts = date.split('-');
    if (parts.length != 3) return null;
    final t = time.split(':');
    if (t.length < 2) return null;
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
      int.parse(t[0]),
      int.parse(t[1]),
    );
  } catch (_) {
    return null;
  }
}
