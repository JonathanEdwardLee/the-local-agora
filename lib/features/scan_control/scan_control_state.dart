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
///
/// Pass 03.2: no presets — location empty; time frame / event type unselected
/// until the user chooses them in the search overlay.
class ScanControlState {
  const ScanControlState({
    this.locationText = '',
    this.timeWindow,
    this.category,
    this.locationError,
    this.timeWindowError,
    this.categoryError,
  });

  final String locationText;
  final TimeWindow? timeWindow;
  final EventCategory? category;
  final String? locationError;
  final String? timeWindowError;
  final String? categoryError;

  bool get hasLocation => locationText.trim().isNotEmpty;
  bool get hasTimeWindow => timeWindow != null;
  bool get hasCategory => category != null;
  bool get isReadyToScan => hasLocation && hasTimeWindow && hasCategory;

  ScanControlState copyWith({
    String? locationText,
    TimeWindow? timeWindow,
    EventCategory? category,
    String? locationError,
    String? timeWindowError,
    String? categoryError,
    bool clearLocationError = false,
    bool clearTimeWindowError = false,
    bool clearCategoryError = false,
    bool clearTimeWindow = false,
    bool clearCategory = false,
  }) {
    return ScanControlState(
      locationText: locationText ?? this.locationText,
      timeWindow: clearTimeWindow ? null : (timeWindow ?? this.timeWindow),
      category: clearCategory ? null : (category ?? this.category),
      locationError: clearLocationError
          ? null
          : (locationError ?? this.locationError),
      timeWindowError: clearTimeWindowError
          ? null
          : (timeWindowError ?? this.timeWindowError),
      categoryError: clearCategoryError
          ? null
          : (categoryError ?? this.categoryError),
    );
  }
}
