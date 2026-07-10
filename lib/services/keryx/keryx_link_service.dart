import 'keryx_link_result.dart';

/// Transport for the non-AI Keryx status callable.
abstract class KeryxLinkService {
  Future<KeryxLinkResult> probeStatus();
}

/// Test double / offline stub — never hits the network.
class FakeKeryxLinkService implements KeryxLinkService {
  FakeKeryxLinkService({
    this.result = const KeryxLinkResult(
      state: KeryxLinkState.ready,
      service: 'keryx',
      status: 'ready',
      scanEnabled: false,
      version: '0.1',
    ),
    this.delay = Duration.zero,
    this.onProbe,
  });

  KeryxLinkResult result;
  Duration delay;
  void Function()? onProbe;
  int probeCount = 0;

  @override
  Future<KeryxLinkResult> probeStatus() async {
    probeCount += 1;
    onProbe?.call();
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    return result;
  }
}
