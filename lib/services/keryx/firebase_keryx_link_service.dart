import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

import 'keryx_link_result.dart';
import 'keryx_link_service.dart';

/// Calls deployed `keryxStatus` in us-central1. No Gemini. No scan.
class FirebaseKeryxLinkService implements KeryxLinkService {
  FirebaseKeryxLinkService({
    FirebaseFunctions? functions,
    this.timeout = const Duration(seconds: 20),
  }) : _functions =
           functions ?? FirebaseFunctions.instanceFor(region: 'us-central1');

  final FirebaseFunctions _functions;
  final Duration timeout;

  @override
  Future<KeryxLinkResult> probeStatus() async {
    try {
      final callable = _functions.httpsCallable(
        'keryxStatus',
        options: HttpsCallableOptions(timeout: timeout),
      );
      final response = await callable.call();
      return parseKeryxStatusPayload(response.data);
    } on FirebaseFunctionsException catch (e) {
      debugPrint('keryxStatus Functions error: ${e.code}');
      return KeryxLinkResult(
        state: KeryxLinkState.unavailable,
        userMessage:
            'The development backend could not be reached. No event scan was attempted.',
      );
    } catch (e) {
      debugPrint('keryxStatus probe failed: ${e.runtimeType}');
      return const KeryxLinkResult(
        state: KeryxLinkState.unavailable,
        userMessage:
            'The development backend could not be reached. No event scan was attempted.',
      );
    }
  }
}

/// Validates a `keryxStatus` callable payload into a typed link result.
KeryxLinkResult parseKeryxStatusPayload(Object? raw) {
  if (raw is! Map) {
    return const KeryxLinkResult(state: KeryxLinkState.malformedResponse);
  }
  final map = Map<String, dynamic>.from(raw);
  final service = map['service'];
  final status = map['status'];
  final scanEnabled = map['scanEnabled'];
  final version = map['version'];
  final serverTime = map['serverTime'];

  if (service is! String ||
      status is! String ||
      scanEnabled is! bool ||
      version is! String ||
      serverTime is! String) {
    return const KeryxLinkResult(state: KeryxLinkState.malformedResponse);
  }

  if (service != 'keryx' || status != 'ready' || scanEnabled != false) {
    return const KeryxLinkResult(state: KeryxLinkState.malformedResponse);
  }

  return KeryxLinkResult(
    state: KeryxLinkState.ready,
    service: service,
    status: status,
    scanEnabled: scanEnabled,
    version: version,
    serverTime: serverTime,
  );
}
