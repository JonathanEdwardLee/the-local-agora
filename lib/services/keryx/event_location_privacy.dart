/// Location privacy modes (ADR / blueprint). Discovery shows only source-supported detail.
enum EventLocationPrivacy {
  exactPublic,
  venueOnly,
  generalArea,
  cityOnly,
  askOrganizer,
}

extension EventLocationPrivacyLabel on EventLocationPrivacy {
  String get label {
    switch (this) {
      case EventLocationPrivacy.exactPublic:
        return 'EXACT PUBLIC';
      case EventLocationPrivacy.venueOnly:
        return 'VENUE ONLY';
      case EventLocationPrivacy.generalArea:
        return 'GENERAL AREA';
      case EventLocationPrivacy.cityOnly:
        return 'CITY ONLY';
      case EventLocationPrivacy.askOrganizer:
        return 'ASK ORGANIZER';
    }
  }
}
