/// Typed result of a Keryx Firebase link probe (status callable only).
enum KeryxLinkState {
  untested,
  connecting,
  ready,
  unavailable,
  malformedResponse,
}

class KeryxLinkResult {
  const KeryxLinkResult({
    required this.state,
    this.service,
    this.status,
    this.scanEnabled,
    this.version,
    this.serverTime,
    this.userMessage,
  });

  final KeryxLinkState state;
  final String? service;
  final String? status;
  final bool? scanEnabled;
  final String? version;
  final String? serverTime;
  final String? userMessage;

  static const untested = KeryxLinkResult(
    state: KeryxLinkState.untested,
    userMessage: 'Firebase link untested.',
  );

  static const connecting = KeryxLinkResult(
    state: KeryxLinkState.connecting,
    userMessage: 'CONNECTING TO KERYX...',
  );

  String get machineTitle {
    switch (state) {
      case KeryxLinkState.untested:
        return 'KERYX LINK UNTESTED';
      case KeryxLinkState.connecting:
        return 'CONNECTING TO KERYX...';
      case KeryxLinkState.ready:
        return 'KERYX LINK READY';
      case KeryxLinkState.unavailable:
      case KeryxLinkState.malformedResponse:
        return 'KERYX LINK UNAVAILABLE';
    }
  }

  String get supportText {
    switch (state) {
      case KeryxLinkState.untested:
        return 'Press TEST KERYX LINK to probe the development backend.';
      case KeryxLinkState.connecting:
        return 'Contacting Firebase callable. No event scan is running.';
      case KeryxLinkState.ready:
        return 'Firebase callable connection confirmed. Live event scanning remains disabled.';
      case KeryxLinkState.unavailable:
        return userMessage ??
            'The development backend could not be reached. No event scan was attempted.';
      case KeryxLinkState.malformedResponse:
        return 'The backend response was not understood. No event scan was attempted.';
    }
  }
}
