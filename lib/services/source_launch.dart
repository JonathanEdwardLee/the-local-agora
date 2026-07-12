import 'package:url_launcher/url_launcher.dart';

/// Opens an external original source URL safely.
Future<SourceLaunchResult> openOriginalSource(Uri? url) async {
  if (url == null ||
      !(url.isScheme('https') || url.isScheme('http')) ||
      url.host.isEmpty) {
    return SourceLaunchResult.invalid;
  }
  try {
    final ok = await launchUrl(url, mode: LaunchMode.externalApplication);
    return ok ? SourceLaunchResult.opened : SourceLaunchResult.failed;
  } catch (_) {
    return SourceLaunchResult.failed;
  }
}

enum SourceLaunchResult { opened, invalid, failed }
