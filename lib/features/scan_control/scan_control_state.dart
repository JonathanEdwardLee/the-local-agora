enum TimeWindow { tonight, tomorrow, thisWeekend, nextSevenDays }

extension TimeWindowLabel on TimeWindow {
  String get label {
    switch (this) {
      case TimeWindow.tonight:
        return 'TONIGHT';
      case TimeWindow.tomorrow:
        return 'TOMORROW';
      case TimeWindow.thisWeekend:
        return 'THIS WEEKEND';
      case TimeWindow.nextSevenDays:
        return 'NEXT 7 DAYS';
    }
  }
}

enum EventCategory { allSignals, music, art, stage, comedy, gatherings }

/// Version 0.1 dial options — art / gatherings / all-signals deferred.
const kV01EventCategories = <EventCategory>[
  EventCategory.music,
  EventCategory.comedy,
  EventCategory.stage,
];

extension EventCategoryLabel on EventCategory {
  String get label {
    switch (this) {
      case EventCategory.allSignals:
        return 'ALL SIGNALS';
      case EventCategory.music:
        return 'MUSIC';
      case EventCategory.art:
        return 'ART';
      case EventCategory.stage:
        return 'THEATER';
      case EventCategory.comedy:
        return 'COMEDY';
      case EventCategory.gatherings:
        return 'GATHERINGS';
    }
  }
}

/// Typed Scan Control state — no nested business logic in widgets.
class ScanControlState {
  const ScanControlState({
    this.locationText = '',
    this.timeWindow = TimeWindow.thisWeekend,
    this.category = EventCategory.music,
    this.locationError,
  });

  final String locationText;
  final TimeWindow timeWindow;
  final EventCategory category;
  final String? locationError;

  bool get hasLocation => locationText.trim().isNotEmpty;

  ScanControlState copyWith({
    String? locationText,
    TimeWindow? timeWindow,
    EventCategory? category,
    String? locationError,
    bool clearLocationError = false,
  }) {
    return ScanControlState(
      locationText: locationText ?? this.locationText,
      timeWindow: timeWindow ?? this.timeWindow,
      category: category ?? this.category,
      locationError: clearLocationError
          ? null
          : (locationError ?? this.locationError),
    );
  }
}
