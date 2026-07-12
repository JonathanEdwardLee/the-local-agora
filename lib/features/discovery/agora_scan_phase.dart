import '../../services/keryx/keryx_service.dart';

/// Discovery scan UI phase for Pass 03.
enum AgoraScanPhase { idle, validating, searching, results, empty, error }

class AgoraScanSession {
  const AgoraScanSession({
    this.phase = AgoraScanPhase.idle,
    this.result,
    this.statusLines = const [],
  });

  final AgoraScanPhase phase;
  final KeryxScanResult? result;
  final List<String> statusLines;

  AgoraScanSession copyWith({
    AgoraScanPhase? phase,
    KeryxScanResult? result,
    List<String>? statusLines,
    bool clearResult = false,
  }) {
    return AgoraScanSession(
      phase: phase ?? this.phase,
      result: clearResult ? null : (result ?? this.result),
      statusLines: statusLines ?? this.statusLines,
    );
  }
}
