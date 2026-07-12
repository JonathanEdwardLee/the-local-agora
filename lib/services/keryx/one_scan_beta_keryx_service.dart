import 'beta_scan_allowance_store.dart';
import 'keryx_service.dart';

/// Gates [inner] to one completed beta scan per installation/profile.
///
/// Consumes allowance only after a completed valid response
/// ([KeryxScanOutcome.results] or [KeryxScanOutcome.empty]).
/// Validation failures and transport/service errors do not consume.
class OneScanBetaKeryxService implements KeryxService {
  OneScanBetaKeryxService({required this.inner, required this.allowance});

  final KeryxService inner;
  final BetaScanAllowanceStore allowance;

  int callCount = 0;

  @override
  Future<bool> hasConsumedBetaAllowance() => allowance.hasUsedBetaScan();

  @override
  Future<KeryxScanResult> scan(KeryxScanRequest request) async {
    callCount += 1;
    if (await allowance.hasUsedBetaScan()) {
      return KeryxScanResult(
        outcome: KeryxScanOutcome.error,
        request: request,
        errorKind: KeryxScanErrorKind.betaScanConsumed,
        machineTitle: 'ERR // ONLY ONE SCAN ALLOWED FOR BETA',
        supportText:
            'This installation has already used its contest beta event search.',
        origin: KeryxResultOrigin.none,
      );
    }

    final result = await inner.scan(request);
    if (result.outcome == KeryxScanOutcome.results ||
        result.outcome == KeryxScanOutcome.empty) {
      await allowance.markBetaScanUsed();
    }
    return result;
  }
}
