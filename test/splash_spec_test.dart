import 'package:flutter_test/flutter_test.dart';
import 'package:the_local_agora/brand/junkfeathers_splash_spec.dart';

void main() {
  test('Junkfeathers splash timing constants remain locked', () {
    expect(JunkfeathersSplashSpec.revealMs.inMilliseconds, 990);
    expect(JunkfeathersSplashSpec.holdMs.inMilliseconds, 1000);
    expect(JunkfeathersSplashSpec.hideMs.inMilliseconds, 880);
    expect(JunkfeathersSplashSpec.totalBrandedSequence.inMilliseconds, 2870);
    expect(JunkfeathersSplashSpec.animationImplemented, isTrue);
  });
}
