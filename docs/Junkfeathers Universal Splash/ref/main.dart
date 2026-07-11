/// ORPHEUS DECK
/// Retro cassette interface, pro native audio engine.
/// Read ORPHEUS_DESIGN_MANIFESTO.md and ORPHEUS_NATIVE_AUDIO_PLAN.md
/// before making architectural audio changes.

library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'orpheus_ffmpeg.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:audio_session/audio_session.dart' as as_sess;

import 'widgets/tape_reel_transport.dart';

import 'orpheus_bpm_input.dart';
import 'orpheus_name_entry_screen.dart';
import 'orpheus_track_clips.dart';
import 'orpheus_track_names.dart';
import 'orpheus_track_templates.dart';
import 'orpheus_export_clip_plan.dart';
import 'orpheus_waveform_clip_view.dart';
import 'orpheus_mic_source.dart';
import 'orpheus_native_audio_qa.dart';
import 'orpheus_click_preview.dart';
import 'orpheus_splash_tips.dart';
import 'native/orpheus_native_audio.dart';
import 'native/orpheus_native_bindings.dart';
import 'native/orpheus_native_test_screen.dart';
import 'orpheus_click_beat_ui.dart';
import 'native/native_guide_click.dart';
import 'orpheus_onboarding.dart';
import 'orpheus_view_projects_dialog.dart';
import 'orpheus_app_storage.dart';
import 'orpheus_release_log.dart';
import 'recorder/native_oboe_recorder_engine.dart';
import 'recorder/native_record_take.dart';
import 'recorder/native_session_timing.dart';
import 'recorder/native_test_wav_generator.dart';
import 'recorder/native_wav_validation.dart';
import 'recorder/recorder_engine_types.dart';
import 'recorder/recorder_engine_selector.dart';
import 'recorder/wav_waveform_analyzer.dart';
import 'orpheus_feature_gate.dart';
import 'orpheus_billing.dart';
import 'orpheus_billing_config.dart';
import 'orpheus_fx_player_screen.dart';
import 'orpheus_pro_dialog.dart';
import 'orpheus_template_flow.dart';

/// R3-QA-B: `true` matched R3-QA (`3189949`) and correlated with underwater USB headset REC.
/// R2 (`b84a9df`) used configure-only. Keep false until device A/B says otherwise.
const bool kOrpheusAudioSessionSetActiveOnInit = false;

/// One cassette side — fixed transport length (0 … tapeLengthMs).
/// Clip lengths do not shorten the tape; matches ORPHEUS_DESIGN_MANIFESTO.md.
const int tapeLengthMs = 15 * 60 * 1000;

enum OrpheusWavImportPlacement { zero, current }

class _ImportedProjectWav {
  const _ImportedProjectWav({
    required this.path,
    required this.waveform,
    required this.durationMs,
    required this.converted,
  });

  final String path;
  final List<double> waveform;
  final int durationMs;
  final bool converted;
}

class _PickedImportWav {
  const _PickedImportWav({
    required this.path,
    this.displayName,
    this.mimeType,
    this.uri,
  });

  final String path;
  final String? displayName;
  final String? mimeType;
  final String? uri;
}

class _WavImportFailure implements Exception {
  const _WavImportFailure(this.userMessage, this.reason);

  final String userMessage;
  final String reason;

  @override
  String toString() => reason;
}

class OrpheusImportWavDiagnosticsStore {
  OrpheusImportWavDiagnosticsStore._();
  static final OrpheusImportWavDiagnosticsStore instance =
      OrpheusImportWavDiagnosticsStore._();

  String? _lastDiagnostics;

  void record(String diagnostics) {
    _lastDiagnostics = diagnostics;
    debugPrint('Orpheus IMPORT_WAV: diagnostics saved');
  }

  Future<void> copyLastDiagnosticsToClipboard() async {
    final text = _lastDiagnostics;
    if (text == null || text.trim().isEmpty) {
      throw StateError('NO IMPORT DIAGNOSTICS YET');
    }
    await Clipboard.setData(ClipboardData(text: text));
  }
}

/// Header / dial tape clock [`mm:ss`] from [`tapeTransportMs`] (same as `_playbackMs`).
String _tapeClockMmSs(int ms) {
  final int clampedMs = ms < 0 ? 0 : ms;
  final int totalSec = clampedMs ~/ 1000;
  final m = (totalSec ~/ 60).toString().padLeft(2, '0');
  final s = (totalSec % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

String _formatExportDateTime(DateTime d) {
  final l = d.toLocal();
  final y = l.year.toString().padLeft(4, '0');
  final mo = l.month.toString().padLeft(2, '0');
  final da = l.day.toString().padLeft(2, '0');
  final h = l.hour.toString().padLeft(2, '0');
  final mi = l.minute.toString().padLeft(2, '0');
  return '$y-$mo-$da $h:$mi';
}

/// Matches [pubspec.yaml] version — shown in Settings ▸ About.
const String kOrpheusAppVersion = '1.0.0';

/// Strip characters invalid for OrpheusDeck project folder names.
String sanitizeOrpheusProjectFolderName(String raw) =>
    raw.replaceAll(RegExp(r'[\\/:*?"<>|]'), '').trim();

/// Sorted project folder names under internal OrpheusDeck storage.
Future<List<String>> listOrpheusDeckProjectNames() =>
    listOrpheusProjectFolderNames();

/// Returns an OLED toast message when invalid, or null when OK.
String? validateOrpheusProjectFolderName(
  String raw, {
  required Iterable<String> existingNames,
  String? allowSameAs,
}) {
  final safe = sanitizeOrpheusProjectFolderName(raw);
  if (safe.isEmpty) return 'NAME CANNOT BE EMPTY';
  if (allowSameAs != null && safe == allowSameAs) return null;
  for (final n in existingNames) {
    if (n == safe) return 'PROJECT NAME ALREADY EXISTS';
  }
  return null;
}

OverlayEntry? _orpheusOledToastEntry;

/// OLED-style status toast — black panel, white border, uppercase monospace.
void showOrpheusOledToast(BuildContext context, String message) {
  _orpheusOledToastEntry?.remove();
  _orpheusOledToastEntry = null;
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) {
    orpheusReleaseLog('toast skipped (no overlay): $message');
    return;
  }
  final upper = message.toUpperCase();
  final entry = OverlayEntry(
    builder: (ctx) {
      final pad = MediaQuery.paddingOf(ctx);
      return Stack(
        children: [
          Positioned(
            left: 16,
            right: 16,
            top: pad.top + 56,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Text(
                      upper,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 0.6,
                        height: 1.25,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
  _orpheusOledToastEntry = entry;
  overlay.insert(entry);
  Future<void>.delayed(const Duration(milliseconds: 2300), () {
    entry.remove();
    if (identical(_orpheusOledToastEntry, entry)) {
      _orpheusOledToastEntry = null;
    }
  });
}

/// App-level preferences at internal OrpheusDeck/settings.json (not per session).
class OrpheusSettings {
  OrpheusSettings._();
  static final OrpheusSettings instance = OrpheusSettings._();

  static const int nativeLatencySampleRate = 48000;
  static const int defaultNativeRecordLatencyOffsetSamples =
      OrpheusNativeAudio.devDefaultRecordLatencyOffsetSamples;
  static const int nativeLatencyOffsetMinSamples = 0;
  static const int nativeLatencyOffsetMaxSamples = nativeLatencySampleRate * 2;

  static const int manualLatencyAdjustMinMs = -2000;
  static const int manualLatencyAdjustMaxMs = 2000;

  /// Native record placement compensation. Defaults ON for native-only beta.
  bool latencyCompensationEnabled = true;

  /// True after a successful native N2E profile run.
  bool latencyCalibrated = false;

  /// Last successful native latency test result (diagnostic / reset target).
  int lastLatencyTestMs = 0;

  /// Last test recommendation; manual adjustment can diverge from this value.
  int? latencyTestRecommendedOffsetSamples;

  /// Native N3C default record placement correction for new takes.
  int defaultRecordLatencyOffsetSamples =
      defaultNativeRecordLatencyOffsetSamples;

  /// When true, show the pre-record informational checklist dialog.
  bool recordingCheckReminderEnabled = true;

  /// Human-readable mirror of [defaultRecordLatencyOffsetSamples] used by the
  /// waveform lane helper and old settings migrations.
  int manualLatencyAdjustMs = 60;

  /// N5B-B: welcome hidden permanently when user checks Don't show again.
  bool hasSeenWelcome = false;

  /// Local app cold-start counter (on-device only; not sent off device).
  int appOpenCount = 0;

  /// True after review prompt dismissed via either button.
  bool reviewPromptCompleted = false;

  /// R3-QA-E: phone mic is the default recording source; headphones monitor.
  OrpheusMicSource micSource = OrpheusMicSource.phoneMic;

  Future<File> _settingsFile() async => orpheusSettingsJsonFile();

  static double nativeLatencySamplesToMs(int samples) =>
      samples * 1000.0 / nativeLatencySampleRate;

  static int nativeLatencyMsToSamples(double ms) =>
      (ms * nativeLatencySampleRate / 1000.0).round();

  static int _clampNativeLatencyOffsetSamples(int samples) => samples.clamp(
        nativeLatencyOffsetMinSamples,
        nativeLatencyOffsetMaxSamples,
      );

  int get effectiveRecordLatencyOffsetSamples =>
      latencyCompensationEnabled ? defaultRecordLatencyOffsetSamples : 0;

  double get defaultRecordLatencyOffsetMs =>
      nativeLatencySamplesToMs(defaultRecordLatencyOffsetSamples);

  String get defaultRecordLatencyOffsetLabel =>
      '$defaultRecordLatencyOffsetSamples samples / '
      '${defaultRecordLatencyOffsetMs.toStringAsFixed(1)} ms';

  String get currentLatencyOffsetLabel {
    final prefix = latencyCalibrated ? '' : 'DEFAULT ';
    return '$prefix$defaultRecordLatencyOffsetLabel';
  }

  Future<void> load() async {
    try {
      final file = await _settingsFile();
      if (!await file.exists()) {
        await save();
        OrpheusNativeAudio.instance.rememberN2eRecommendedOffset(
          defaultRecordLatencyOffsetSamples,
        );
        return;
      }
      final dynamic raw = jsonDecode(await file.readAsString());
      if (raw is Map<String, dynamic>) {
        final dynamic calibratedRaw = raw['latencyCalibrated'];
        latencyCalibrated = calibratedRaw is bool ? calibratedRaw : false;

        final dynamic manRaw = raw['manualLatencyAdjustMs'];
        if (manRaw is num) {
          manualLatencyAdjustMs = manRaw
              .round()
              .clamp(manualLatencyAdjustMinMs, manualLatencyAdjustMaxMs);
        } else {
          manualLatencyAdjustMs = 0;
        }

        final dynamic testOffsetRaw =
            raw['latencyTestRecommendedOffsetSamples'];
        latencyTestRecommendedOffsetSamples = testOffsetRaw is num
            ? _clampNativeLatencyOffsetSamples(testOffsetRaw.round())
            : null;

        final dynamic defaultOffsetRaw =
            raw['defaultRecordLatencyOffsetSamples'];
        if (defaultOffsetRaw is num) {
          defaultRecordLatencyOffsetSamples =
              _clampNativeLatencyOffsetSamples(defaultOffsetRaw.round());
        } else if (latencyCalibrated && manRaw is num) {
          defaultRecordLatencyOffsetSamples = _clampNativeLatencyOffsetSamples(
            nativeLatencyMsToSamples(manRaw.toDouble()),
          );
        } else {
          defaultRecordLatencyOffsetSamples =
              defaultNativeRecordLatencyOffsetSamples;
        }
        manualLatencyAdjustMs =
            nativeLatencySamplesToMs(defaultRecordLatencyOffsetSamples).round();

        final dynamic lastLatencyRaw = raw['lastLatencyTestMs'];
        lastLatencyTestMs = lastLatencyRaw is num ? lastLatencyRaw.toInt() : 0;

        final dynamic latRaw = raw['latencyCompensationEnabled'];
        latencyCompensationEnabled = latRaw is bool ? latRaw : true;

        final dynamic recRemRaw = raw['recordingCheckReminderEnabled'];
        recordingCheckReminderEnabled = recRemRaw is bool ? recRemRaw : true;

        final dynamic welcomeRaw = raw['hasSeenWelcome'];
        hasSeenWelcome = welcomeRaw is bool ? welcomeRaw : false;

        final dynamic openCountRaw = raw['appOpenCount'];
        appOpenCount = openCountRaw is num ? openCountRaw.toInt() : 0;

        final dynamic reviewRaw = raw['reviewPromptCompleted'];
        reviewPromptCompleted = reviewRaw is bool ? reviewRaw : false;

        micSource = parseOrpheusMicSource(raw['micSource']);
      } else {
        latencyCompensationEnabled = true;
        latencyCalibrated = false;
        lastLatencyTestMs = 0;
        latencyTestRecommendedOffsetSamples = null;
        defaultRecordLatencyOffsetSamples =
            defaultNativeRecordLatencyOffsetSamples;
        manualLatencyAdjustMs =
            nativeLatencySamplesToMs(defaultRecordLatencyOffsetSamples).round();
        recordingCheckReminderEnabled = true;
        hasSeenWelcome = false;
        appOpenCount = 0;
        reviewPromptCompleted = false;
        micSource = OrpheusMicSource.phoneMic;
      }
    } catch (e, st) {
      debugPrint('Orpheus Deck: settings load error $e\n$st');
      latencyCompensationEnabled = true;
      latencyCalibrated = false;
      lastLatencyTestMs = 0;
      latencyTestRecommendedOffsetSamples = null;
      defaultRecordLatencyOffsetSamples =
          defaultNativeRecordLatencyOffsetSamples;
      manualLatencyAdjustMs =
          nativeLatencySamplesToMs(defaultRecordLatencyOffsetSamples).round();
      recordingCheckReminderEnabled = true;
      hasSeenWelcome = false;
      appOpenCount = 0;
      reviewPromptCompleted = false;
      micSource = OrpheusMicSource.phoneMic;
    }
    OrpheusNativeAudio.instance.rememberN2eRecommendedOffset(
      defaultRecordLatencyOffsetSamples,
    );
  }

  Future<bool> save() async {
    try {
      final file = await _settingsFile();
      final ok = await writeOrpheusTextFileAtomic(
        file,
        contents: jsonEncode(<String, dynamic>{
          'latencyCalibrated': latencyCalibrated,
          'latencyCompensationEnabled': latencyCompensationEnabled,
          'manualLatencyAdjustMs': manualLatencyAdjustMs,
          'defaultRecordLatencyOffsetSamples':
              defaultRecordLatencyOffsetSamples,
          'latencyTestRecommendedOffsetSamples':
              latencyTestRecommendedOffsetSamples,
          'lastLatencyTestMs': lastLatencyTestMs,
          'recordingCheckReminderEnabled': recordingCheckReminderEnabled,
          'hasSeenWelcome': hasSeenWelcome,
          'appOpenCount': appOpenCount,
          'reviewPromptCompleted': reviewPromptCompleted,
          'micSource': micSource.storageValue,
        }),
      );
      if (!ok) {
        orpheusReleaseLog('settings save failed path=${file.path}');
      }
      return ok;
    } catch (e, st) {
      orpheusReleaseLogError('settings save', e, st);
      return false;
    }
  }

  Future<void> setHasSeenWelcome(bool seen) async {
    hasSeenWelcome = seen;
    await save();
    debugPrint('Orpheus Deck: settings hasSeenWelcome=$seen');
  }

  /// Increment once per cold start; stored locally in settings.json only.
  Future<void> incrementAppOpenCount() async {
    appOpenCount += 1;
    await save();
    debugPrint('Orpheus Deck: settings appOpenCount=$appOpenCount');
  }

  Future<void> setReviewPromptCompleted(bool completed) async {
    reviewPromptCompleted = completed;
    await save();
    debugPrint('Orpheus Deck: settings reviewPromptCompleted=$completed');
  }

  Future<void> setLatencyCompensation(bool enabled) async {
    latencyCompensationEnabled = enabled;
    await save();
    OrpheusNativeAudio.instance.rememberN2eRecommendedOffset(
      defaultRecordLatencyOffsetSamples,
    );
    debugPrint(
      'Orpheus Deck: settings latencyCompensationEnabled=$enabled',
    );
  }

  Future<void> setManualLatencyAdjustMs(int deltaMs) async {
    await setDefaultRecordLatencyOffsetSamples(
      nativeLatencyMsToSamples(deltaMs.toDouble()),
    );
  }

  Future<void> setDefaultRecordLatencyOffsetSamples(int samples) async {
    defaultRecordLatencyOffsetSamples =
        _clampNativeLatencyOffsetSamples(samples);
    manualLatencyAdjustMs =
        nativeLatencySamplesToMs(defaultRecordLatencyOffsetSamples)
            .round()
            .clamp(manualLatencyAdjustMinMs, manualLatencyAdjustMaxMs);
    await save();
    OrpheusNativeAudio.instance.rememberN2eRecommendedOffset(
      defaultRecordLatencyOffsetSamples,
    );
    debugPrint(
      'Orpheus Deck: settings defaultRecordLatencyOffsetSamples='
      '$defaultRecordLatencyOffsetSamples',
    );
  }

  Future<void> bumpManualLatencyAdjustMs(int delta) async =>
      setManualLatencyAdjustMs(manualLatencyAdjustMs + delta);

  Future<void> bumpDefaultRecordLatencyOffsetSamples(int delta) async =>
      setDefaultRecordLatencyOffsetSamples(
        defaultRecordLatencyOffsetSamples + delta,
      );

  Future<void> applySuccessfulNativeLatencyCalibration({
    required int recommendedOffsetSamples,
  }) async {
    final samples = _clampNativeLatencyOffsetSamples(recommendedOffsetSamples);
    latencyCalibrated = true;
    latencyCompensationEnabled = true;
    latencyTestRecommendedOffsetSamples = samples;
    lastLatencyTestMs = DateTime.now().millisecondsSinceEpoch;
    await setDefaultRecordLatencyOffsetSamples(samples);
    debugPrint(
      'Orpheus Deck: native latency calibrated samples=$samples '
      'ms=${nativeLatencySamplesToMs(samples).toStringAsFixed(1)}',
    );
  }

  Future<void> resetLatencyOffsetToTestResult() async {
    final samples = latencyTestRecommendedOffsetSamples;
    if (samples == null) return;
    await setDefaultRecordLatencyOffsetSamples(samples);
  }

  Future<void> setRecordingCheckReminderEnabled(bool enabled) async {
    recordingCheckReminderEnabled = enabled;
    await save();
    debugPrint(
      'Orpheus Deck: settings recordingCheckReminderEnabled=$enabled',
    );
  }

  Future<void> setMicSource(OrpheusMicSource source) async {
    micSource = source;
    await save();
    debugPrint(
      'Orpheus Deck: settings micSource=${source.storageValue}',
    );
  }
}

/// Debug QA actions for hidden beta diagnostics (long-press Settings ▸ About).
void showOrpheusBetaDiagnosticsDialog(
  BuildContext context, {
  VoidCallback? onGenerateDebugWavTracks,
}) {
  Future<void> runDiag(
    String okToast,
    Future<void> Function() action,
  ) async {
    try {
      await action();
      if (context.mounted) {
        showOrpheusOledToast(context, okToast);
      }
    } catch (e) {
      if (context.mounted) {
        showOrpheusOledToast(context, e.toString().toUpperCase());
      }
    }
  }

  Widget diagBtn(String label, Future<void> Function() act) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => runDiag('OK', act),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.white54),
          foregroundColor: Colors.white,
          backgroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: Colors.black,
        shape: Border.all(color: Colors.white, width: 2),
        title: const Text(
          'BETA DIAGNOSTICS',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              diagBtn(
                'COPY LAST AUDIO DIAGNOSTICS',
                OrpheusNativeAudioQaStore.instance.copyDiagnosticsToClipboard,
              ),
              const SizedBox(height: 8),
              diagBtn(
                'COPY LAST IMPORT DIAGNOSTICS',
                OrpheusImportWavDiagnosticsStore
                    .instance.copyLastDiagnosticsToClipboard,
              ),
              const SizedBox(height: 8),
              diagBtn(
                'COPY BILLING DIAGNOSTICS',
                OrpheusBillingService.instance.copyDiagnosticsToClipboard,
              ),
              const SizedBox(height: 8),
              diagBtn(
                'COPY LAST TRACK PATH',
                OrpheusNativeAudioQaStore.instance.copyLastTrackPathToClipboard,
              ),
              const SizedBox(height: 8),
              diagBtn(
                'SHARE LAST TRACK WAV',
                OrpheusNativeAudioQaStore.instance.shareLastTrackWav,
              ),
              if (Platform.isAndroid) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      openOrpheusNativeTestScreen(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white54),
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                    ),
                    child: const Text(
                      'NATIVE AUDIO TESTS',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
              if (onGenerateDebugWavTracks != null) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      onGenerateDebugWavTracks();
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white38),
                      foregroundColor: Colors.white70,
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                    ),
                    child: const Text(
                      'GENERATE DEBUG WAV TEST TRACKS',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              GestureDetector(
                onLongPress: () {
                  showOrpheusBetaProToggleDialog(context);
                },
                child: const Text(
                  'THANK YOU FOR HELPING BETA TEST ORPHEUS!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white38,
                    fontFamily: 'monospace',
                    fontSize: 9,
                    height: 1.4,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'CLOSE',
              style: TextStyle(
                color: Colors.white54,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  );
}

/// Shared settings UI (home menu + recording reminder “OPEN SETTINGS”).
void showOrpheusDeckSettingsDialog(
  BuildContext outerContext, {
  bool Function()? isTransportBusy,
  bool openLatencyTestImmediately = false,
  VoidCallback? onGenerateDebugWavTracks,
}) {
  showDialog(
    context: outerContext,
    builder: (dialogContext) {
      var latencyCalibBusy = false;
      var latencyPassLabel = '';
      var didScheduleLatencyOpen = false;

      return StatefulBuilder(
        builder: (context, setDialogState) {
          final settings = OrpheusSettings.instance;
          final latencyOn = settings.latencyCompensationEnabled;
          final bool recReminderOn =
              OrpheusSettings.instance.recordingCheckReminderEnabled;
          final micSource = OrpheusSettings.instance.micSource;
          final currentOffset = settings.currentLatencyOffsetLabel;

          bool transportBusy() => isTransportBusy?.call() ?? false;

          Widget micBtn(OrpheusMicSource source) {
            final selected = micSource == source;
            return OutlinedButton(
              onPressed: () async {
                await OrpheusSettings.instance.setMicSource(source);
                setDialogState(() {});
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: selected ? Colors.white : Colors.white38,
                  width: selected ? 2 : 1,
                ),
                foregroundColor: Colors.white,
                backgroundColor: selected ? Colors.white12 : Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                minimumSize: const Size(0, 30),
              ),
              child: Text(
                source.displayLabel,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.white70,
                  fontFamily: 'monospace',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          void showLatencyResultDialog({
            required String title,
            required String body,
          }) {
            showDialog<void>(
              context: dialogContext,
              builder: (resultCtx) => AlertDialog(
                backgroundColor: Colors.black,
                shape: Border.all(color: Colors.white, width: 2),
                title: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                content: Text(
                  body,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontFamily: 'monospace',
                    fontSize: 10,
                    height: 1.4,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(resultCtx),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          Future<void> runNativeLatencyTest() async {
            if (transportBusy()) {
              showOrpheusOledToast(outerContext, 'STOP PLAY/REC FIRST');
              return;
            }
            setDialogState(() {
              latencyCalibBusy = true;
              latencyPassLabel = 'PASS 1/3';
            });
            try {
              await OrpheusNativeAudio.instance.stopN3d();
              await OrpheusNativeAudio.instance.stopN3c();
              await OrpheusNativeAudio.instance.stopN3b();
              await OrpheusNativeAudio.instance.stopN6b();
              final profile =
                  await OrpheusNativeAudio.instance.runCalibrationProfile(
                onPassStarted: (current, total) {
                  if (!dialogContext.mounted) return;
                  setDialogState(() {
                    latencyPassLabel = 'PASS $current/$total';
                  });
                },
              );
              if (profile.profileSuccess &&
                  profile.recommendedOffsetSamples != null) {
                await OrpheusSettings.instance
                    .applySuccessfulNativeLatencyCalibration(
                  recommendedOffsetSamples: profile.recommendedOffsetSamples!,
                );
                if (dialogContext.mounted) {
                  setDialogState(() {
                    latencyCalibBusy = false;
                    latencyPassLabel = '';
                  });
                }
                final ms = profile.recommendedOffsetMs ??
                    OrpheusSettings.nativeLatencySamplesToMs(
                      profile.recommendedOffsetSamples!,
                    );
                if (dialogContext.mounted) {
                  showLatencyResultDialog(
                    title: 'LATENCY OFFSET SET',
                    body: '${profile.recommendedOffsetSamples} samples / '
                        '${ms.toStringAsFixed(1)} ms\n'
                        'QUALITY: ${profile.qualityLabel}',
                  );
                }
              } else {
                if (dialogContext.mounted) {
                  setDialogState(() {
                    latencyCalibBusy = false;
                    latencyPassLabel = '';
                  });
                }
                if (dialogContext.mounted) {
                  showLatencyResultDialog(
                    title: 'LATENCY TEST FAILED',
                    body: 'TURN UP PHONE VOLUME\n'
                        'KEEP ROOM QUIET\n'
                        'LET MIC HEAR THE CLICKS\n'
                        'TRY AGAIN',
                  );
                }
              }
            } catch (e, st) {
              debugPrint('Orpheus native latency test failed: $e\n$st');
              if (dialogContext.mounted) {
                setDialogState(() {
                  latencyCalibBusy = false;
                  latencyPassLabel = '';
                });
              }
              if (dialogContext.mounted) {
                showLatencyResultDialog(
                  title: 'LATENCY TEST FAILED',
                  body: 'TURN UP PHONE VOLUME\n'
                      'KEEP ROOM QUIET\n'
                      'LET MIC HEAR THE CLICKS\n'
                      'TRY AGAIN',
                );
              }
            }
          }

          void openLatencyInstructions() {
            if (transportBusy()) {
              showOrpheusOledToast(outerContext, 'STOP PLAY/REC FIRST');
              return;
            }
            showDialog<void>(
              context: dialogContext,
              builder: (prepCtx) => AlertDialog(
                backgroundColor: Colors.black,
                shape: Border.all(color: Colors.white, width: 2),
                title: const Text(
                  'LATENCY TEST',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                content: const SingleChildScrollView(
                  child: Text(
                    'USE PHONE SPEAKER.\n'
                    'QUIET ROOM.\n'
                    'LET MIC HEAR THE CLICKS.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontFamily: 'monospace',
                      fontSize: 10,
                      height: 1.4,
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(prepCtx),
                    child: const Text(
                      'CANCEL',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(prepCtx);
                      unawaited(runNativeLatencyTest());
                    },
                    child: const Text(
                      'START TEST',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          void openAdjustLatencyDialog() {
            showDialog<void>(
              context: dialogContext,
              builder: (adjustCtx) => StatefulBuilder(
                builder: (adjustContext, setAdjustState) {
                  final s = OrpheusSettings.instance;

                  Future<void> adjustSamples(int delta) async {
                    await s.bumpDefaultRecordLatencyOffsetSamples(delta);
                    setDialogState(() {});
                    setAdjustState(() {});
                  }

                  Widget adjustBtn(String label, int delta) => TextButton(
                        onPressed: () => adjustSamples(delta),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                        ),
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );

                  return AlertDialog(
                    backgroundColor: Colors.black,
                    shape: Border.all(color: Colors.white, width: 2),
                    title: const Text(
                      'ADJUST LATENCY',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          s.defaultRecordLatencyOffsetLabel,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'monospace',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 4,
                          runSpacing: 4,
                          children: [
                            adjustBtn('-5MS',
                                -OrpheusSettings.nativeLatencyMsToSamples(5)),
                            adjustBtn('-1MS',
                                -OrpheusSettings.nativeLatencyMsToSamples(1)),
                            adjustBtn('+1MS',
                                OrpheusSettings.nativeLatencyMsToSamples(1)),
                            adjustBtn('+5MS',
                                OrpheusSettings.nativeLatencyMsToSamples(5)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed:
                              s.latencyTestRecommendedOffsetSamples == null
                                  ? null
                                  : () async {
                                      await s.resetLatencyOffsetToTestResult();
                                      setDialogState(() {});
                                      setAdjustState(() {});
                                    },
                          child: const Text(
                            'RESET TO TEST RESULT',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'monospace',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(adjustCtx),
                        child: const Text(
                          'DONE',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          }

          if (openLatencyTestImmediately && !didScheduleLatencyOpen) {
            didScheduleLatencyOpen = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (dialogContext.mounted) {
                openLatencyInstructions();
              }
            });
          }

          return AlertDialog(
            backgroundColor: Colors.black,
            shape: Border.all(color: Colors.white, width: 2),
            title: const Text(
              'SETTINGS',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'RECORDING',
                    style: TextStyle(
                      color: Colors.white54,
                      fontFamily: 'monospace',
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'USE WIRED HEADPHONES. BLUETOOTH ADDS DELAY.',
                    style: TextStyle(
                      color: Colors.white38,
                      fontFamily: 'monospace',
                      fontSize: 9,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'MIC SOURCE',
                    style: TextStyle(
                      color: Colors.white54,
                      fontFamily: 'monospace',
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: OrpheusMicSource.values.map(micBtn).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'LATENCY',
                    style: TextStyle(
                      color: Colors.white54,
                      fontFamily: 'monospace',
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed:
                          latencyCalibBusy ? null : openLatencyInstructions,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      ),
                      child: Text(
                        latencyCalibBusy
                            ? 'RUNNING ${latencyPassLabel.isEmpty ? "" : latencyPassLabel}'
                            : 'RUN LATENCY TEST',
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'OFFSET: $currentOffset',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontFamily: 'monospace',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: openAdjustLatencyDialog,
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                          ),
                          child: const Text(
                            'ADJUST OFFSET',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'COMP:',
                        style: TextStyle(
                          color: Colors.white38,
                          fontFamily: 'monospace',
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Switch(
                        value: latencyOn,
                        activeThumbColor: Colors.black,
                        activeTrackColor: Colors.white,
                        inactiveThumbColor: Colors.white54,
                        inactiveTrackColor: Colors.white24,
                        onChanged: (v) async {
                          await OrpheusSettings.instance
                              .setLatencyCompensation(v);
                          setDialogState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'RECORDING CHECK REMINDER',
                          style: TextStyle(
                            color: Colors.white54,
                            fontFamily: 'monospace',
                            fontSize: 10,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      Switch(
                        value: recReminderOn,
                        activeThumbColor: Colors.black,
                        activeTrackColor: Colors.white,
                        inactiveThumbColor: Colors.white54,
                        inactiveTrackColor: Colors.white24,
                        onChanged: (v) async {
                          await OrpheusSettings.instance
                              .setRecordingCheckReminderEnabled(v);
                          setDialogState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'ENGINE',
                    style: TextStyle(
                      color: Colors.white54,
                      fontFamily: 'monospace',
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    kOrpheusUserFacingAudioEngineLine,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'monospace',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '48 KHZ WAV · LOW-LATENCY ANDROID AUDIO',
                    style: TextStyle(
                      color: Colors.white38,
                      fontFamily: 'monospace',
                      fontSize: 9,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () =>
                          showOrpheusRecordingTipsDialog(dialogContext),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      ),
                      child: const Text(
                        'RECORDING TIPS',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => showOrpheusProUserDialog(dialogContext),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      ),
                      child: const Text(
                        kOrpheusProMenuButtonLabel,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: OrpheusBillingService.instance.isCheckInFlight
                          ? null
                          : () async {
                              final billing = OrpheusBillingService.instance;
                              await billing.checkSubscription();
                              if (dialogContext.mounted) {
                                showOrpheusOledToast(
                                  dialogContext,
                                  billing.userStatusMessage.toUpperCase(),
                                );
                              }
                            },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                      ),
                      child: Text(
                        OrpheusBillingService.instance.isCheckInFlight
                            ? 'CHECKING...'
                            : kOrpheusProCheckSubscriptionButtonLabel,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'ABOUT',
                    style: TextStyle(
                      color: Colors.white54,
                      fontFamily: 'monospace',
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onLongPress: () {
                      Navigator.pop(dialogContext);
                      showOrpheusBetaDiagnosticsDialog(
                        outerContext,
                        onGenerateDebugWavTracks: onGenerateDebugWavTracks,
                      );
                    },
                    child: const Text(
                      '$kOrpheusPublicProductLine\n'
                      '$kOrpheusPublicVersionLine',
                      style: TextStyle(
                        color: Colors.white70,
                        fontFamily: 'monospace',
                        fontSize: 10,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text(
                  'CLOSE',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await OrpheusSettings.instance.load();
  await OrpheusSettings.instance.incrementAppOpenCount();
  await OrpheusBillingService.instance.initialize();
  await OrpheusFeatureGate.instance.load();
  await logOrpheusStartupStoragePaths();
  runApp(const OrpheusDeckApp());
}

enum UndoAction { none, clearTrack, mixer, rename }

class UndoState {
  UndoAction action = UndoAction.none;

  int? trackIndex;
  String? trackFile;
  List<double>? trackWaveform;
  int? trackTapeStartMs;

  List<double>? volumes;
  List<bool>? mutes;
  List<bool>? solos;

  String? oldName;
  String? newName;

  void clear() {
    action = UndoAction.none;
    trackIndex = null;
    trackFile = null;
    trackWaveform = null;
    trackTapeStartMs = null;
    volumes = null;
    mutes = null;
    solos = null;
    oldName = null;
    newName = null;
  }

  bool get hasUndo => action != UndoAction.none;
}

/// Final mix export metadata (session.json). Raw track M4As stay internal-only.
class ExportEntry {
  final String filename;

  /// User-facing location, e.g. Music/Orpheus Deck/foo.wav
  final String displayPath;
  final String? storageUri;
  final String? absolutePath;
  final String kind;
  final DateTime createdAt;

  ExportEntry({
    required this.filename,
    required this.displayPath,
    this.storageUri,
    this.absolutePath,
    required this.kind,
    required this.createdAt,
  });

  String get shareRef => storageUri ?? absolutePath ?? '';

  ExportEntry copyWith({
    String? filename,
    String? displayPath,
    String? storageUri,
    String? absolutePath,
    String? kind,
    DateTime? createdAt,
  }) {
    return ExportEntry(
      filename: filename ?? this.filename,
      displayPath: displayPath ?? this.displayPath,
      storageUri: storageUri ?? this.storageUri,
      absolutePath: absolutePath ?? this.absolutePath,
      kind: kind ?? this.kind,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'filename': filename,
        'displayPath': displayPath,
        if (storageUri != null) 'storageUri': storageUri,
        if (absolutePath != null) 'absolutePath': absolutePath,
        'kind': kind,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ExportEntry.fromJson(Map<String, dynamic> json) {
    final abs = json['absolutePath'] as String?;
    final fname = json['filename'] as String? ??
        (abs != null ? abs.split(RegExp(r'[/\\]')).last : '');
    return ExportEntry(
      filename: fname,
      displayPath: json['displayPath'] as String? ?? fname,
      storageUri: json['storageUri'] as String?,
      absolutePath: abs,
      kind: json['kind'] as String? ?? 'RAW MIX',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  /// Older sessions stored exports as plain filesystem paths.
  factory ExportEntry.fromLegacyPath(String path) {
    final name = path.split(RegExp(r'[/\\]')).last;
    final lower = name.toLowerCase();
    final kind = lower.contains('mastermix') || lower.contains('youtube_master')
        ? 'MASTERMIX'
        : 'RAW MIX';
    return ExportEntry(
      filename: name,
      displayPath: path,
      storageUri: null,
      absolutePath: path,
      kind: kind,
      createdAt: DateTime.now(),
    );
  }
}

List<ExportEntry> parseExportsFromJson(dynamic raw) {
  if (raw == null) return [];
  if (raw is! List) return [];
  final out = <ExportEntry>[];
  for (final item in raw) {
    if (item is String) {
      out.add(ExportEntry.fromLegacyPath(item));
    } else if (item is Map) {
      out.add(ExportEntry.fromJson(Map<String, dynamic>.from(item)));
    }
  }
  return out;
}

class _ExportBrowseSnapshot {
  const _ExportBrowseSnapshot({
    required this.entries,
    required this.footerHintText,
  });

  final List<ExportEntry> entries;

  /// Shown below the scroll list (empty library / Music scan caveat).
  final String? footerHintText;
}

double _parseClickVolumeFromJson(Map<String, dynamic> json) {
  final raw = json['clickVolume'] ?? json['metronomeVolume'];
  if (raw is num) {
    return raw.toDouble().clamp(0.0, 1.0);
  }
  return kOrpheusClickVolumeDefault;
}

class Session {
  String projectName;
  DateTime createdAt;
  DateTime updatedAt;
  List<String?> trackFiles;
  Map<String, List<double>> waveformCache;
  List<String?> trackIds;
  List<int> trackOffsets;
  List<int> trackTapeStartMs;

  /// N3F — per-track musician tape start @ [kOrpheusRecorderSampleRate] (native_test).
  List<int> trackTapeStartSamples;

  /// N3F — per-take record latency offset in samples (native_test).
  List<int> recordLatencyOffsetSamples;
  List<double> trackVolumes;
  List<bool> trackMutes;
  List<bool> trackSolos;
  List<ExportEntry> exports;
  int bpm;
  bool metronomeOn;
  String metronomeSound;

  /// Guide click monitor volume 0.0–1.0 (N6C UI; native bus in N6D).
  double clickVolume;

  /// P2 — 0 off, 4 = four-beat count-in before native REC.
  int clickCountInBeats;

  /// `legacy` (default/missing), `native` (new projects), or `native_test` (alias).
  String audioEngine;

  /// Optional custom labels per lane (`null` = default `TRK 0N`).
  List<String?> trackDisplayNames;

  /// TC-A — per-lane clip lists (metadata only until TC-B+).
  List<List<OrpheusTrackClip>> trackClips;
  int trackClipsVersion;

  Session({
    required this.projectName,
    required this.createdAt,
    required this.updatedAt,
    required this.trackFiles,
    required this.waveformCache,
    required this.trackIds,
    required this.trackOffsets,
    required this.trackTapeStartMs,
    List<int>? trackTapeStartSamples,
    List<int>? recordLatencyOffsetSamples,
    required this.trackVolumes,
    required this.trackMutes,
    required this.trackSolos,
    required this.exports,
    required this.bpm,
    required this.metronomeOn,
    required this.metronomeSound,
    this.clickVolume = kOrpheusClickVolumeDefault,
    this.clickCountInBeats = 0,
    this.audioEngine = kOrpheusAudioEngineLegacy,
    List<String?>? trackDisplayNames,
    List<List<OrpheusTrackClip>>? trackClips,
    this.trackClipsVersion = kOrpheusTrackClipsVersion,
  })  : trackDisplayNames = trackDisplayNames ?? [null, null, null, null],
        trackClips = trackClips ?? emptyTrackClipsLanes(),
        trackTapeStartSamples =
            trackTapeStartSamples ?? emptyNativeTimingList(),
        recordLatencyOffsetSamples =
            recordLatencyOffsetSamples ?? emptyNativeTimingList();

  Map<String, dynamic> toJson() {
    final legacyMirror = mirrorLegacyFieldsFromTrackClips(trackClips);
    final map = <String, dynamic>{
      'projectName': projectName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'trackFiles': legacyMirror.trackFiles,
      'waveformCache': waveformCache,
      'trackIds': trackIds,
      'trackOffsets': trackOffsets,
      'trackTapeStartMs': legacyMirror.trackTapeStartMs,
      kSessionKeyTrackClips: trackClipsToJson(trackClips),
      kSessionKeyTrackClipsVersion: trackClipsVersion,
      'trackVolumes': trackVolumes,
      'trackMutes': trackMutes,
      'trackSolos': trackSolos,
      'exports': exports.map((e) => e.toJson()).toList(),
      'bpm': bpm,
      'metronomeOn': metronomeOn,
      'metronomeSound': metronomeSound,
      'clickVolume': clickVolume,
      'clickCountInBeats': clickCountInBeats,
      'countInBeats': clickCountInBeats,
      'audioEngine': normalizeAudioEngineForSave(audioEngine),
      kSessionKeyTrackDisplayNames: trackDisplayNames,
    };
    if (isNativeAudioEngine(audioEngine)) {
      map[kSessionKeyTrackTapeStartSamples] =
          legacyMirror.trackTapeStartSamples;
      map[kSessionKeyRecordLatencyOffsetSamples] =
          legacyMirror.recordLatencyOffsetSamples;
      map[kSessionKeyEngineSampleRate] = kOrpheusRecorderSampleRate;
    }
    return map;
  }

  factory Session.fromJson(Map<String, dynamic> json) {
    final createdAt = json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String)
        : DateTime.now();
    final updatedAt = json['updatedAt'] != null
        ? DateTime.parse(json['updatedAt'] as String)
        : DateTime.now();
    final trackFiles = List<String?>.from(json['trackFiles'] as List);
    final waveformCache = (json['waveformCache'] as Map<String, dynamic>).map(
      (k, e) => MapEntry(k, List<double>.from(e as List)),
    );
    final trackTapeStartMs =
        List<int>.from(json['trackTapeStartMs'] as List? ?? [0, 0, 0, 0]);
    final trackTapeStartSamples = parseTrackTapeStartSamplesFromJson(json);
    final recordLatencyOffsetSamples =
        parseRecordLatencyOffsetSamplesFromJson(json);
    final parsedTrackClips = parseTrackClipsFromJson(json);
    final trackClips = parsedTrackClips ??
        hydrateTrackClipsFromLegacy(
          trackFiles: trackFiles,
          trackTapeStartSamples: trackTapeStartSamples,
          trackTapeStartMs: trackTapeStartMs,
          recordLatencyOffsetSamples: recordLatencyOffsetSamples,
          waveformCache: waveformCache,
          fallbackCreatedAt: updatedAt,
        );
    final trackClipsVersion =
        _readSessionInt(json[kSessionKeyTrackClipsVersion]) ??
            kOrpheusTrackClipsVersion;

    return Session(
      projectName: json['projectName'] as String? ?? 'SESSION_001',
      createdAt: createdAt,
      updatedAt: updatedAt,
      trackFiles: trackFiles,
      waveformCache: waveformCache,
      trackIds: List<String?>.from(
          json['trackIds'] as List? ?? [null, null, null, null]),
      trackOffsets:
          List<int>.from(json['trackOffsets'] as List? ?? [0, 0, 0, 0]),
      trackTapeStartMs: trackTapeStartMs,
      trackTapeStartSamples: trackTapeStartSamples,
      recordLatencyOffsetSamples: recordLatencyOffsetSamples,
      trackVolumes: List<double>.from(
          json['trackVolumes'] as List? ?? [1.0, 1.0, 1.0, 1.0]),
      trackMutes: List<bool>.from(
          json['trackMutes'] as List? ?? [false, false, false, false]),
      trackSolos: List<bool>.from(
          json['trackSolos'] as List? ?? [false, false, false, false]),
      exports: parseExportsFromJson(json['exports']),
      bpm: json['bpm'] as int? ?? 120,
      metronomeOn: json['metronomeOn'] as bool? ?? false,
      metronomeSound: normalizeMetronomeSound(
        json['metronomeSound'] as String?,
      ),
      clickVolume: _parseClickVolumeFromJson(json),
      clickCountInBeats: _parseClickCountInBeatsFromJson(json),
      audioEngine: parseProjectAudioEngineFromSessionJson(json),
      trackDisplayNames: parseTrackDisplayNamesFromJson(json),
      trackClips: trackClips,
      trackClipsVersion: trackClipsVersion,
    );
  }
}

int? _readSessionInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.round();
  return null;
}

int _parseClickCountInBeatsFromJson(Map<String, dynamic> json) {
  final dynamic raw = json['clickCountInBeats'] ?? json['countInBeats'];
  if (raw is int) {
    return raw == 4 ? 4 : 0;
  }
  if (raw is num) {
    return raw.round() == 4 ? 4 : 0;
  }
  return 0;
}

class OrpheusDeckApp extends StatefulWidget {
  const OrpheusDeckApp({super.key});

  @override
  State<OrpheusDeckApp> createState() => _OrpheusDeckAppState();
}

class _OrpheusDeckAppState extends State<OrpheusDeckApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(OrpheusBillingService.instance.checkSubscription());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Orpheus Deck',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          secondary: Colors.white,
          surface: Colors.black,
        ),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/home': (context) => const CassetteHomeScreen(),
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return JunkfeathersGlitchSplash(
      onComplete: () {
        Navigator.pushReplacementNamed(context, '/home');
      },
    );
  }
}

class JunkfeathersGlitchSplash extends StatefulWidget {
  final VoidCallback onComplete;
  const JunkfeathersGlitchSplash({super.key, required this.onComplete});

  @override
  State<JunkfeathersGlitchSplash> createState() =>
      _JunkfeathersGlitchSplashState();
}

/// ~4.4s total: clean logo fade-in → light glitch → strong glitch → glitch/fade-out.
const int _kJunkfeathersSplashTotalMs = 4400;

/// Longer clean intro before any interference (phase 0).
const double _kSpEndFade = 0.20;
const double _kSpEndLight = 0.42;
const double _kSpEndHeavy = 0.70;

/// Phases: 0 clean fade-in, 1 light interference, 2 strong interference, 3 glitch-out.
void _splashPhasesFour(
  double t,
  void Function(int phase, double phaseProgress) out,
) {
  if (t < _kSpEndFade) {
    out(0, t / _kSpEndFade);
  } else if (t < _kSpEndLight) {
    out(1, (t - _kSpEndFade) / (_kSpEndLight - _kSpEndFade));
  } else if (t < _kSpEndHeavy) {
    out(2, (t - _kSpEndLight) / (_kSpEndHeavy - _kSpEndLight));
  } else {
    out(3, (t - _kSpEndHeavy) / (1.0 - _kSpEndHeavy));
  }
}

/// Logo layer opacity — hides mark before transition to avoid ghost flash.
double _splashLogoOpacity(double t) {
  int phase = 0;
  double phaseProgress = 0;
  _splashPhasesFour(t, (p, pp) {
    phase = p;
    phaseProgress = pp;
  });
  if (phase == 0) {
    return (0.04 + 0.96 * phaseProgress).clamp(0.0, 1.0);
  }
  if (phase == 3 && phaseProgress > 0.62) {
    return (1.0 - ((phaseProgress - 0.62) / 0.38)).clamp(0.0, 1.0);
  }
  return 1.0;
}

class _JunkfeathersGlitchSplashState extends State<JunkfeathersGlitchSplash>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late final String _splashTip;

  @override
  void initState() {
    super.initState();
    _splashTip = pickOrpheusSplashTipForLaunch();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _kJunkfeathersSplashTotalMs),
    );
    _ctrl.forward().then((_) {
      if (mounted) widget.onComplete();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          final t = _ctrl.value;
          final logoOpacity = _splashLogoOpacity(t);
          return Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: JunkfeathersSplashBackdropPainter(t),
                child: const SizedBox.expand(),
              ),
              if (logoOpacity > 0.02)
                Center(
                  child: Opacity(
                    opacity: logoOpacity,
                    child: SizedBox(
                      width: 236,
                      height: 118,
                      child: CustomPaint(
                        painter: JunkfeathersLogoMarkPainter(t),
                      ),
                    ),
                  ),
                ),
              if (_splashTip.isNotEmpty)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SafeArea(
                    minimum: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                    child: Opacity(
                      opacity: 0.88,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Text(
                          _splashTip,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white38,
                            fontFamily: 'monospace',
                            fontSize: 8,
                            letterSpacing: 0.3,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Full-bleed boot interference: bands, tear, scanlines — no random specks.
class JunkfeathersSplashBackdropPainter extends CustomPainter {
  JunkfeathersSplashBackdropPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    int phase = 0;
    double phaseProgress = 0;
    _splashPhasesFour(progress, (p, pp) {
      phase = p;
      phaseProgress = pp;
    });

    final int globalStep = (progress * 240).floor();
    final Random globalR = Random(globalStep);

    final double w = size.width;
    final double h = size.height;

    // Master visibility (fade-in/out ends of sequence).
    double master = 1.0;
    if (phase == 0) {
      master = 0.04 + 0.96 * phaseProgress;
    } else if (phase == 3) {
      master = 1.0 - 0.97 * phaseProgress;
    }

    // Phase 0: clean black — no band interference until logo has faded in.
    if (phase == 0) {
      return;
    }

    // Phase-dependent corruption strength (no "star" noise).
    int coverBase;
    double tearAmp;
    int scanMul; // 1 = every 3px, 2 = denser in heavy phases
    if (phase == 1) {
      coverBase = 18 + (globalR.nextInt(15));
      tearAmp = 3.0 + phaseProgress * 4.0;
      scanMul = 1;
    } else if (phase == 2) {
      coverBase = 48 + (globalR.nextInt(22));
      tearAmp = 10.0 + phaseProgress * 12.0;
      scanMul = 2;
    } else {
      coverBase = 72 + (globalR.nextInt(25));
      tearAmp = 22.0 + phaseProgress * 26.0;
      scanMul = 2;
    }

    final Paint bandPaint = Paint()
      ..color = Colors.black.withValues(alpha: master);
    final Paint fastLine = Paint()
      ..color = Colors.white.withValues(alpha: 0.82 * master);
    final Paint tearWhite = Paint()
      ..color = Colors.white.withValues(alpha: 0.35 * master);

    int y = 0;
    while (y < h) {
      int bandH = globalR.nextInt(14) + 4;
      if (y + bandH > h) bandH = max(0, (h - y).floor());
      if (bandH <= 0) break;

      final rowRand = Random(globalStep ^ (y * 9973));
      final tearDx = (rowRand.nextDouble() - 0.5) * 2.0 * tearAmp * master;

      int coverChance = (coverBase + rowRand.nextInt(12)).clamp(0, 98);
      if (globalR.nextInt(100) < coverChance) {
        canvas.drawRect(
          Rect.fromLTWH(tearDx, y.toDouble(), w, bandH.toDouble()),
          bandPaint,
        );
      } else {
        if (globalR.nextInt(100) < (phase >= 2 ? 22 : 12)) {
          canvas.drawRect(
              Rect.fromLTWH(tearDx, y.toDouble(), w, 1.2), fastLine);
        }
        if (phase >= 2 && globalR.nextInt(100) < 18) {
          canvas.drawRect(
            Rect.fromLTWH(tearDx + w * 0.35, y.toDouble(), w * 0.12, 1),
            tearWhite,
          );
        }
      }
      y += bandH;
    }

    final Paint scan = Paint()
      ..color = Colors.black.withValues(alpha: 0.14 * master);
    for (double sy = 0; sy < h; sy += (3 / scanMul)) {
      canvas.drawRect(Rect.fromLTWH(0, sy, w, 1), scan);
    }
  }

  @override
  bool shouldRepaint(covariant JunkfeathersSplashBackdropPainter old) =>
      old.progress != progress;
}

/// Logo wordmark + outline dead birds (full-screen glitch lives in backdrop only).
class JunkfeathersLogoMarkPainter extends CustomPainter {
  JunkfeathersLogoMarkPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 128, size.height / 64);

    int phase = 0;
    double phaseProgress = 0;
    _splashPhasesFour(progress, (p, pp) {
      phase = p;
      phaseProgress = pp;
    });

    const int totalSteps = 240;
    final int globalStep = (progress * totalSteps).floor();
    final Random globalR = Random(globalStep);

    if (phase == 3 && phaseProgress > 0.88) {
      return;
    }

    double jMag = 0;
    if (phase == 1) jMag = 1.0;
    if (phase == 2) jMag = 2.0;
    if (phase == 3) {
      jMag = (3.2 + phaseProgress * 3.5) * (1.0 - phaseProgress * 0.55);
    }

    double jitterX = 0;
    double jitterY = 0;
    if (phase >= 1) {
      jitterX = (globalR.nextDouble() - 0.5) * 2.0 * jMag;
      jitterY = (globalR.nextDouble() - 0.5) * 2.0 * jMag;
    }

    if (jitterX != 0 || jitterY != 0) {
      canvas.translate(jitterX, jitterY);
    }

    double master = 1.0;
    if (phase == 0) {
      master = 0.06 + 0.94 * phaseProgress;
    }
    if (phase == 3) {
      master = 1.0 - 0.98 * phaseProgress;
    }
    if (phase == 1 || phase == 2) {
      if (globalR.nextInt(100) < 8) {
        master *= 0.5 + globalR.nextDouble() * 0.5;
      }
    }

    const double wordPx = 12.0;
    final bool sliceGlitch = phase >= 1;
    _drawWordmarkGlitch(
      canvas,
      'JUNKFEATHERS',
      7,
      master,
      wordPx,
      globalStep ^ 31,
      sliceGlitch: sliceGlitch,
    );
    _drawWordmarkGlitch(
      canvas,
      'TECH',
      22,
      master,
      wordPx,
      globalStep ^ 997,
      sliceGlitch: sliceGlitch,
    );

    _drawBirdOutlined(canvas, 32, 45, 10.8, master);
    _drawBirdOutlined(canvas, 96, 45, 10.8, master);

    // Final phase: slice the mark itself (backdrop already carries interference).
    if (phase == 3) {
      final Random corruptR = Random(globalStep ^ 0x5fce);
      final int cov = (36 + phaseProgress * 58).round().clamp(32, 98).toInt();
      for (int yy = 0; yy < 64; yy += 3) {
        if (corruptR.nextInt(100) >= cov) continue;
        final bh = corruptR.nextInt(5) + 1;
        canvas.drawRect(
          Rect.fromLTWH(0, yy.toDouble(), 128, bh.toDouble()),
          Paint()..color = Colors.black.withValues(alpha: master),
        );
      }
    }

    if (jitterX != 0 || jitterY != 0) {
      canvas.translate(-jitterX, -jitterY);
    }
  }

  void _drawWordmarkGlitch(
    Canvas canvas,
    String text,
    double y,
    double m,
    double fontPx,
    int lineSalt, {
    bool sliceGlitch = true,
  }) {
    final double shimmer =
        sin(progress * pi * 2.6 + y * 0.08).clamp(-1.0, 1.0) * 0.045;
    final double textAlpha = (m * (0.72 + shimmer)).clamp(0.12, 1.0);

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white.withValues(alpha: textAlpha),
          fontFamily: 'monospace',
          fontSize: fontPx,
          fontWeight: FontWeight.bold,
          height: 1.05,
          letterSpacing: 0.3,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: 124);
    final double x = (128 - textPainter.width) * 0.5;
    textPainter.paint(canvas, Offset(x, y));

    final double w = textPainter.width;
    final double h = textPainter.height;
    final Random sliceR = Random(
      lineSalt ^ ((progress * 100000).floor()) ^ text.hashCode ^ 0x9e3779b9,
    );

    if (!sliceGlitch) {
      return;
    }

    double gy = y;
    final double bottom = y + h;
    while (gy < bottom) {
      if (sliceR.nextInt(100) < 48) {
        final double gap = 0.85 + sliceR.nextDouble() * 0.55;
        canvas.drawRect(
          Rect.fromLTRB(x - 1, gy, x + w + 1, gy + gap),
          Paint()
            ..color = Colors.black
                .withValues(alpha: m * (0.38 + sliceR.nextDouble() * 0.28)),
        );
      }
      if (sliceR.nextInt(100) < 12) {
        canvas.drawRect(
          Rect.fromLTRB(
              x + sliceR.nextDouble() * w * 0.08, gy, x + w, gy + 0.85),
          Paint()
            ..color = Colors.black
                .withValues(alpha: m * (0.18 + sliceR.nextDouble() * 0.12)),
        );
      }
      if (sliceR.nextInt(100) < 8) {
        canvas.drawRect(
          Rect.fromLTWH(x - 1, gy, w + 2, 0.65),
          Paint()
            ..color = Colors.white
                .withValues(alpha: m * (0.1 + sliceR.nextDouble() * 0.08)),
        );
      }
      gy += 2.0 + sliceR.nextDouble() * 2.4;
    }
  }

  void _drawBirdOutlined(
      Canvas canvas, double cx, double cy, double r, double m) {
    final Paint interior = Paint()
      ..color = Colors.black.withValues(alpha: m)
      ..style = PaintingStyle.fill;

    final Paint ring = Paint()
      ..color = Colors.white.withValues(alpha: m * 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25;

    final Paint eyeStroke = Paint()
      ..color = Colors.white.withValues(alpha: m * 0.88)
      ..strokeWidth = 1.45
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(Offset(cx, cy), r, interior);
    canvas.drawCircle(Offset(cx, cy), r, ring);

    final double exL = cx - (r / 2);
    final double exR = cx + (r / 2);
    final double eyeY = cy - (r / 4);
    const double s = 2.0;

    canvas.drawLine(
        Offset(exL - s, eyeY - s), Offset(exL + s, eyeY + s), eyeStroke);
    canvas.drawLine(
        Offset(exL - s, eyeY + s), Offset(exL + s, eyeY - s), eyeStroke);
    canvas.drawLine(
        Offset(exR - s, eyeY - s), Offset(exR + s, eyeY + s), eyeStroke);
    canvas.drawLine(
        Offset(exR - s, eyeY + s), Offset(exR + s, eyeY - s), eyeStroke);

    final double bx = cx;
    final double by = cy + (r / 3);

    final Path beak = Path()
      ..moveTo(bx, by + 2.8)
      ..lineTo(bx - 3.8, by - 1.8)
      ..lineTo(bx + 3.8, by - 1.8)
      ..close();

    final Paint beakFill = Paint()
      ..color = Colors.white.withValues(alpha: m * 0.82)
      ..style = PaintingStyle.fill;
    canvas.drawPath(beak, beakFill);
    canvas.drawPath(
      beak,
      Paint()
        ..color = Colors.white.withValues(alpha: m * 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.85,
    );
  }

  @override
  bool shouldRepaint(covariant JunkfeathersLogoMarkPainter old) =>
      old.progress != progress;
}

class CassetteHomeScreen extends StatefulWidget {
  const CassetteHomeScreen({super.key});

  @override
  State<CassetteHomeScreen> createState() => _CassetteHomeScreenState();
}

class _CassetteHomeScreenState extends State<CassetteHomeScreen>
    with SingleTickerProviderStateMixin {
  String? _lastProjectName;
  final List<String> _allProjects = [];
  late AnimationController _idleCtrl;

  @override
  void initState() {
    super.initState();
    OrpheusFeatureGate.instance.addListener(_onFeatureGateChanged);
    _idleCtrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 10))
          ..repeat();
    _scanProjects();
    scheduleOrpheusWelcomeIfNeeded(
      context,
      hasSeenWelcome: () => OrpheusSettings.instance.hasSeenWelcome,
      onPersistDontShowAgain: () =>
          OrpheusSettings.instance.setHasSeenWelcome(true),
      onAfterWelcomeFlow: () {
        scheduleOrpheusReviewPromptIfNeeded(
          context,
          appOpenCount: OrpheusSettings.instance.appOpenCount,
          reviewPromptCompleted: OrpheusSettings.instance.reviewPromptCompleted,
          onCompleted: () =>
              OrpheusSettings.instance.setReviewPromptCompleted(true),
        );
      },
    );
  }

  @override
  void dispose() {
    OrpheusFeatureGate.instance.removeListener(_onFeatureGateChanged);
    _idleCtrl.dispose();
    super.dispose();
  }

  void _onFeatureGateChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _scanProjects() async {
    try {
      final deck = await orpheusDeckRootDirectory(create: false);
      final lastFile = await orpheusLastProjectFile();
      if (await lastFile.exists()) {
        _lastProjectName = (await lastFile.readAsString()).trim();
      }

      if (await deck.exists()) {
        _allProjects.clear();
        for (final e in deck.listSync()) {
          if (e is Directory) {
            final String name = e.path.split(RegExp(r'[/\\]')).last;
            if (name.startsWith('.')) continue;
            _allProjects.add(name);
          }
        }
        _allProjects.sort();
      }

      if (mounted) setState(() {});
    } catch (e, s) {
      orpheusReleaseLogError('scanProjects', e, s);
    }
  }

  String _sanitizeName(String input) {
    String clean = input.replaceAll(RegExp(r'[\\/:*?"<>|]'), '').trim();
    if (clean.isEmpty) return "SESSION_001";
    return clean;
  }

  Future<void> _showViewProjectsFromHome() async {
    await showOrpheusViewProjectsDialog(
      context,
      currentProjectName: null,
      isTransportBusy: () => false,
      onToast: (msg) => showOrpheusOledToast(context, msg),
      onOpenProject: (name) async {
        if (await projectFolderIsLegacyUnsupported(name)) {
          if (mounted) {
            showOrpheusOledToast(context, kLegacyProjectUnsupportedMessage);
          }
          return;
        }
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RecorderScreen(
              projectName: name,
              isNewProject: false,
            ),
          ),
        );
      },
      onRenameProject: (oldName, newName, refresh) async {
        final safeName = sanitizeOrpheusProjectFolderName(newName);
        if (safeName.isEmpty || safeName == oldName) return;
        final existing = await listOrpheusDeckProjectNames();
        final err = validateOrpheusProjectFolderName(
          newName,
          existingNames: existing,
          allowSameAs: oldName,
        );
        if (err != null) {
          if (mounted) showOrpheusOledToast(context, err);
          return;
        }
        try {
          await applyOrpheusProjectRenameOffDisk(
            oldName,
            safeName,
            onMessage: (msg) {
              if (mounted) showOrpheusOledToast(context, msg);
            },
          );
          await refresh();
          if (mounted) await _scanProjects();
        } catch (e) {
          if (mounted) showOrpheusOledToast(context, 'ERR: RENAME FAILED');
        }
      },
      onDeleteProject: (name, dialogContext, refresh) async {
        showOrpheusDeleteProjectConfirmDialog(
          context,
          projectName: name,
          onDelete: () async {
            final hostContext = context;
            try {
              await deleteOrpheusProjectFolder(name);
              if (!hostContext.mounted) return;
              await refresh();
              if (!hostContext.mounted) return;
              await _scanProjects();
              showOrpheusOledToast(hostContext, 'PROJECT DELETED');
            } catch (e) {
              if (hostContext.mounted) {
                showOrpheusOledToast(hostContext, 'ERR: DELETE FAILED');
              }
            }
          },
        );
      },
    );
    if (mounted) await _scanProjects();
  }

  Future<void> _startNewProject() async {
    final rawName = await showOrpheusNewProjectNameRoute(context);
    if (!mounted || rawName == null) {
      return;
    }
    final safeName = _sanitizeName(rawName);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RecorderScreen(
          projectName: safeName,
          isNewProject: true,
        ),
      ),
    );
  }

  Future<void> _openTemplate() async {
    if (!requestOrpheusProFeature(
      context,
      OrpheusProFeature.trackNameTemplates,
    )) {
      return;
    }
    await showOrpheusOpenTemplateFlow(
      context,
      onToast: (msg) => showOrpheusOledToast(context, msg),
      onTemplateSelected: _startProjectFromTemplate,
    );
  }

  Future<void> _startProjectFromTemplate(OrpheusTrackTemplate template) async {
    final rawName = await showOrpheusNewProjectNameRoute(context);
    if (!mounted || rawName == null) return;

    final safeName = sanitizeOrpheusProjectFolderName(rawName);
    if (safeName.isEmpty) {
      showOrpheusOledToast(context, 'NAME CANNOT BE EMPTY');
      return;
    }
    final existing = await listOrpheusDeckProjectNames();
    final err = validateOrpheusProjectFolderName(
      safeName,
      existingNames: existing,
    );
    if (!mounted) return;
    if (err != null) {
      showOrpheusOledToast(context, err);
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => RecorderScreen(
          projectName: safeName,
          isNewProject: true,
          initialTrackDisplayNames: template.appliedTrackDisplayNames(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool hasProjects = _allProjects.isNotEmpty;

    return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
            child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AnimatedBuilder(
                        animation: _idleCtrl,
                        builder: (context, child) {
                          return SizedBox(
                              height: 180,
                              child:
                                  Stack(alignment: Alignment.center, children: [
                                CustomPaint(
                                  size: const Size(double.infinity, 180),
                                  painter: CassettePainter(_idleCtrl.value),
                                ),
                                Positioned(
                                    top: 24,
                                    left: 0,
                                    right: 0,
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            color: Colors.black,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            child: const Text("ORPHEUS DECK",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'monospace',
                                                    fontWeight: FontWeight.w900,
                                                    fontSize: 18,
                                                    letterSpacing: 2),
                                                textAlign: TextAlign.center),
                                          ),
                                          const SizedBox(height: 8),
                                          Container(
                                            color: Colors.black,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            child: const Text(
                                                "Four-Track Audio Recorder",
                                                style: TextStyle(
                                                    color: Colors.white54,
                                                    fontFamily: 'monospace',
                                                    fontSize: 10),
                                                textAlign: TextAlign.center),
                                          ),
                                        ]))
                              ]));
                        }),
                    const SizedBox(height: 48),
                    if (_lastProjectName != null &&
                        _allProjects.contains(_lastProjectName)) ...[
                      Text("LAST PROJECT: $_lastProjectName",
                          style: const TextStyle(
                              color: Colors.white54,
                              fontFamily: 'monospace',
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      _MenuBtn("RESUME LAST PROJECT", () async {
                        final name = _lastProjectName!;
                        if (await projectFolderIsLegacyUnsupported(name)) {
                          if (context.mounted) {
                            showOrpheusOledToast(
                              context,
                              kLegacyProjectUnsupportedMessage,
                            );
                          }
                          return;
                        }
                        if (!context.mounted) return;
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => RecorderScreen(
                                    projectName: name, isNewProject: false)));
                      }),
                      const SizedBox(height: 16),
                    ],
                    _MenuBtn("START NEW PROJECT", _startNewProject),
                    if (hasProjects) ...[
                      const SizedBox(height: 16),
                      _MenuBtn("VIEW PROJECTS", () {
                        unawaited(_showViewProjectsFromHome());
                      }),
                    ],
                    const SizedBox(height: 16),
                    _MenuBtn(
                      "OPEN TEMPLATE",
                      _openTemplate,
                      proFeature: OrpheusProFeature.trackNameTemplates,
                    ),
                    const SizedBox(height: 16),
                    _MenuBtn("SETTINGS", () {
                      showOrpheusDeckSettingsDialog(context);
                    }),
                  ],
                ))));
  }
}

class CassettePainter extends CustomPainter {
  final double spinProgress;

  CassettePainter(this.spinProgress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final RRect outerRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(2, 2, size.width - 4, size.height - 4),
        const Radius.circular(8));
    canvas.drawRRect(outerRect, paint);

    final RRect labelRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(12, 12, size.width - 24, size.height * 0.45),
        const Radius.circular(4));
    canvas.drawRRect(labelRect, paint);

    double lineY1 = size.height * 0.35;
    double lineY2 = size.height * 0.42;
    canvas.drawLine(Offset(20, lineY1), Offset(size.width - 20, lineY1), paint);
    canvas.drawLine(Offset(20, lineY2), Offset(size.width - 20, lineY2), paint);

    double winW = size.width * 0.60;
    double winH = size.height * 0.22;
    double winX = (size.width - winW) / 2;
    double winY = size.height * 0.55;

    final RRect windowRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(winX, winY, winW, winH), const Radius.circular(4));

    // Reel window visuals match [TapeReelTransport] / [_CassetteWindowPainter]
    // (static tape-at-start: left pack large, right pack small).
    final rect = windowRect.outerRect;
    final midY = rect.center.dy;
    final leftCx = rect.left + rect.width * 0.21;
    final rightCx = rect.left + rect.width * 0.79;
    const leftFill = 1.0;
    const rightFill = 0.0;

    final tapeMaxR = min(rect.height * 0.46, rect.width * 0.2);
    final tapeMinR = tapeMaxR * 0.22;
    final tapeLeftR = tapeMinR + (tapeMaxR - tapeMinR) * leftFill;
    final tapeRightR = tapeMinR + (tapeMaxR - tapeMinR) * rightFill;

    final hubR = tapeMaxR * 0.14;
    final spokeInner = hubR * 1.15;
    final spokeOuter = tapeMaxR * 0.34;

    canvas.save();
    canvas.clipRRect(windowRect);

    canvas.drawRRect(
      windowRect,
      Paint()
        ..color = Colors.black
        ..style = PaintingStyle.fill,
    );

    final tapeFill = Paint()
      ..color = Colors.white.withValues(alpha: 0.14)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(leftCx, midY), tapeLeftR, tapeFill);
    canvas.drawCircle(Offset(rightCx, midY), tapeRightR, tapeFill);

    final lip = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(Offset(leftCx, midY), tapeLeftR, lip);
    canvas.drawCircle(Offset(rightCx, midY), tapeRightR, lip);

    final yLow = midY + min(tapeLeftR, tapeRightR) * 0.72;
    final yHigh = midY - min(tapeLeftR, tapeRightR) * 0.72;
    final leftEdgeX = leftCx + tapeLeftR;
    final rightEdgeX = rightCx - tapeRightR;
    if (rightEdgeX > leftEdgeX + 4) {
      final pathPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.12)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.square;
      canvas.drawLine(
          Offset(leftEdgeX, yHigh), Offset(rightEdgeX, yHigh), pathPaint);
      canvas.drawLine(
          Offset(leftEdgeX, yLow), Offset(rightEdgeX, yLow), pathPaint);
      final pathFlow = spinProgress;
      if (pathFlow > 0) {
        const dash = 4.0;
        final off = pathFlow * dash * 2;
        final thin = Paint()
          ..color = Colors.white.withValues(alpha: 0.09)
          ..strokeWidth = 1;
        double x = leftEdgeX - off % (dash * 2);
        while (x < rightEdgeX) {
          canvas.drawLine(
              Offset(x, yHigh - 1), Offset(x + dash, yHigh - 1), thin);
          x += dash * 2;
        }
      }
    }

    final base = spinProgress * 2 * pi;
    final rotL = base * (0.52 + 0.48 * (0.35 + 0.65 * (1.0 - leftFill)));
    final rotR = base * (0.52 + 0.48 * (0.35 + 0.65 * (1.0 - rightFill)));

    void drawHub(double cx, double cy, double rot) {
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(rot);
      final sp = Paint()
        ..color = Colors.white.withValues(alpha: 0.55)
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.square;
      for (int k = 0; k < 3; k++) {
        final a = k * 2 * pi / 3;
        final p1 = Offset(cos(a), sin(a)) * spokeInner;
        final p2 = Offset(cos(a), sin(a)) * spokeOuter;
        canvas.drawLine(p1, p2, sp);
      }
      canvas.restore();

      canvas.drawCircle(
        Offset(cx, cy),
        hubR,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        Offset(cx, cy),
        hubR,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.75)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }

    drawHub(leftCx, midY, rotL);
    drawHub(rightCx, midY, rotR);

    canvas.restore();

    canvas.drawRRect(
      windowRect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.38)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    void drawScrew(double cx, double cy) {
      canvas.drawCircle(Offset(cx, cy), 3, paint);
      canvas.drawLine(Offset(cx - 2, cy - 2), Offset(cx + 2, cy + 2), paint);
    }

    drawScrew(8, 8);
    drawScrew(size.width - 8, 8);
    drawScrew(8, size.height - 8);
    drawScrew(size.width - 8, size.height - 8);

    double trapTopW = size.width * 0.6;
    double trapBotW = size.width * 0.7;
    double trapX = (size.width - trapBotW) / 2;
    double trapTopX = (size.width - trapTopW) / 2;
    double trapY = size.height - 18;

    Path trapPath = Path()
      ..moveTo(trapTopX, trapY)
      ..lineTo(trapTopX + trapTopW, trapY)
      ..lineTo(trapX + trapBotW, size.height)
      ..lineTo(trapX, size.height)
      ..close();

    canvas.drawPath(trapPath, paint);

    canvas.drawCircle(Offset(size.width * 0.3, size.height - 8), 4, paint);
    canvas.drawCircle(Offset(size.width * 0.7, size.height - 8), 4, paint);
    canvas.drawCircle(Offset(size.width * 0.5, size.height - 8), 4, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CassettePainter old) =>
      old.spinProgress != spinProgress;
}

class _MenuBtn extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  final OrpheusProFeature? proFeature;
  const _MenuBtn(this.text, this.onTap, {this.proFeature});

  @override
  State<_MenuBtn> createState() => _MenuBtnState();
}

class _MenuBtnState extends State<_MenuBtn> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final locked = widget.proFeature != null &&
        orpheusProFeatureButtonLocked(widget.proFeature!);
    final borderColor =
        locked ? Colors.white38 : (_isPressed ? Colors.white : Colors.white70);
    final textColor =
        locked ? Colors.white38 : (_isPressed ? Colors.black : Colors.white);

    return GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 50),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: locked
                ? Colors.black
                : (_isPressed ? Colors.white : Colors.black),
            border: Border.all(
                color: borderColor, width: _isPressed && !locked ? 3 : 2),
          ),
          child: Text(widget.text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 1,
              )),
        ));
  }
}

class RecorderScreen extends StatefulWidget {
  final String projectName;
  final bool isNewProject;
  final List<String?>? initialTrackDisplayNames;

  const RecorderScreen({
    super.key,
    required this.projectName,
    required this.isNewProject,
    this.initialTrackDisplayNames,
  });

  @override
  State<RecorderScreen> createState() => _RecorderScreenState();
}

class OrpheusConsole extends RecorderScreen {
  const OrpheusConsole({
    super.key,
    required super.projectName,
    required super.isNewProject,
  });
}

class _RecorderScreenState extends State<RecorderScreen> {
  /// N3E-G/H: native playback + record bridge when selector is native.
  NativeOboeRecorderEngine? _nativeOboeEngine;
  bool _nativePlaybackActive = false;
  bool _nativeRecordingActive = false;
  bool _nativeRecordingFinalized = false;
  bool _nativeRecordingFinalizing = false;
  int _nativeRecordTakeCounter = 0;
  NativeRecordTakeSnapshot? _nativeRecordTakePending;
  Completer<void>? _nativeRecordFinalizeCompleter;

  bool _isPlaying = false;
  bool _isRecording = false;
  bool _isExporting = false;
  int? _exportSessionId;

  Timer? _tickerTimer;
  Timer? _autosaveTimer;

  late String _projectName;
  DateTime _sessionCreatedAt = DateTime.now();
  String _projectAudioEngine = kOrpheusAudioEngineLegacy;

  final List<bool> _armedTracks = [false, false, false, false];
  final List<String?> _trackFiles = [null, null, null, null];
  final List<int> _trackOffsets = [
    0,
    0,
    0,
    0
  ]; // ms offset per track (measured at overdub start)
  final List<int> _trackTapeStartMs = [0, 0, 0, 0];
  final List<int> _trackTapeStartSamples = emptyNativeTimingList();
  final List<int> _recordLatencyOffsetSamples = emptyNativeTimingList();
  final List<double> _trackVolumes = [1.0, 1.0, 1.0, 1.0];
  final List<bool> _trackMutes = [false, false, false, false];
  final List<bool> _trackSolos = [false, false, false, false];
  final List<String?> _trackDisplayNames = [null, null, null, null];
  List<List<OrpheusTrackClip>> _trackClips = emptyTrackClipsLanes();
  List<ExportEntry> _exports = [];

  static const MethodChannel _androidExportChannel =
      MethodChannel('com.junkfeathers.orpheusdeck/export');

  int _bpm = 120;
  bool _metronomeOn = false;
  String _metronomeSound = kOrpheusDefaultMetronomeSound;
  double _clickVolume = kOrpheusClickVolumeDefault;
  int _clickCountInBeats = 0;
  bool _nativeCountInActive = false;
  int _countInBeatsRemaining = 0;

  final Map<String, List<double>> _waveformCache = {};
  double _playbackProgress = 0.0;

  /// Cassette tape head (ms); header clock, locator/reel, and waveform playhead
  /// all read this field from parent rebuilds (`setState` every transport tick).
  int _playbackMs = 0;
  int? _activeRecordTapeStartMs;

  final UndoState _lastUndo = UndoState();

  @override
  void initState() {
    super.initState();
    OrpheusFeatureGate.instance.addListener(_onFeatureGateChanged);
    _projectName = widget.projectName;
    _initAudioSession();

    if (widget.isNewProject) {
      _initializeNewProject(
        _projectName,
        trackDisplayNames: widget.initialTrackDisplayNames,
      );
    } else {
      _loadSession();
    }

    _autosaveTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isPlaying || _isRecording) _saveSession();
    });
  }

  void _onFeatureGateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    OrpheusFeatureGate.instance.removeListener(_onFeatureGateChanged);
    _tickerTimer?.cancel();
    _autosaveTimer?.cancel();
    unawaited(_nativeOboeEngine?.dispose());

    if (_isExporting && _exportSessionId != null) {
      orpheusFfmpegCancel(_exportSessionId);
    }
    super.dispose();
  }

  /// Upper bound for [_playbackMs] during transport (play or record).
  /// Always the physical tape side — never the longest recorded clip.
  int _tapeTransportMaxMs() => tapeLengthMs;

  /// Updates [_playbackMs] and [_playbackProgress] without [setState].
  /// Use inside existing [setState] blocks, or call [_setTapeHeadMs] from UI.
  void _applyTapeHeadClamped(int ms) {
    final int maxMs = _tapeTransportMaxMs();
    _playbackMs = ms.clamp(0, maxMs);
    _playbackProgress = maxMs > 0 ? _playbackMs / maxMs : 0.0;
    if (_playbackProgress > 1.0) _playbackProgress = 1.0;
  }

  /// Single entry point for moving the tape head (transport clock + reel + dial).
  void _setTapeHeadMs(int ms) {
    if (!mounted) return;
    setState(() => _applyTapeHeadClamped(ms));
  }

  List<OrpheusTrackClip> _clipsForLane(int laneIndex) {
    if (laneIndex < 0 || laneIndex >= _trackClips.length) {
      return const [];
    }
    return _trackClips[laneIndex];
  }

  bool _laneHasAudio(int laneIndex) {
    return _clipsForLane(laneIndex).isNotEmpty ||
        (laneIndex >= 0 &&
            laneIndex < _trackFiles.length &&
            _trackFiles[laneIndex] != null);
  }

  void _syncLegacyMirrorForLane(int laneIndex) {
    final mirror = mirrorLegacyFieldsFromTrackClips(_trackClips);
    _trackFiles[laneIndex] = mirror.trackFiles[laneIndex];
    _trackTapeStartMs[laneIndex] = mirror.trackTapeStartMs[laneIndex];
    _trackTapeStartSamples[laneIndex] = mirror.trackTapeStartSamples[laneIndex];
    _recordLatencyOffsetSamples[laneIndex] =
        mirror.recordLatencyOffsetSamples[laneIndex];
  }

  void _clearLegacyMirrorForLane(int laneIndex) {
    _trackFiles[laneIndex] = null;
    _trackTapeStartMs[laneIndex] = 0;
    _trackTapeStartSamples[laneIndex] = 0;
    _recordLatencyOffsetSamples[laneIndex] = 0;
    _trackOffsets[laneIndex] = 0;
  }

  /// Longest clip on the deck (ms), for diagnostics only — not the tape clock cap.
  int _getMaxPlaybackDuration() {
    int maxMs = 0;
    for (int i = 0; i < 4; i++) {
      if (_trackFiles[i] != null &&
          _waveformCache.containsKey(_trackFiles[i]!)) {
        int ms = _waveformCache[_trackFiles[i]!]!.length * 50;
        if (ms > maxMs) maxMs = ms;
      }
    }
    return maxMs;
  }

  /// N4 — native_test export timing from sample session fields.
  Future<({int durationMs, int durationSamples})?>
      _ffprobeAudioDurationForExport(
    String path, {
    int sampleRate = kOrpheusRecorderSampleRate,
  }) async {
    try {
      final session = await orpheusFfprobeGetMediaInformation(path);
      final info = session.getMediaInformation();
      final durStr = info?.getDuration();
      final durSec = double.tryParse(durStr ?? '');
      if (durSec == null || durSec <= 0) return null;
      final int samples = (durSec * sampleRate).round();
      final int ms = (durSec * 1000).round();
      return (durationMs: ms, durationSamples: samples);
    } catch (e) {
      debugPrint('Orpheus N4: ffprobe duration failed path=$path err=$e');
      return null;
    }
  }

  /// Metronome click assets must never be mixed into deck exports.
  bool _isMetronomeClickAssetPath(String path) {
    final name = path.split(RegExp(r'[/\\]')).last.toLowerCase();
    return name.startsWith('click_') && name.endsWith('.wav');
  }

  /// Waveform lane horizontal offset only; unchanged when compensation is OFF.
  int _waveformLaneTapeStartMs(int storedTapeStartMs) {
    if (!OrpheusSettings.instance.latencyCompensationEnabled) {
      return storedTapeStartMs.clamp(0, tapeLengthMs);
    }
    final m = OrpheusSettings.instance.manualLatencyAdjustMs;
    return (storedTapeStartMs - m).clamp(0, tapeLengthMs);
  }

  List<OrpheusWaveformClipView> _waveformClipViewsForTrack(int trackIndex) {
    OrpheusWaveformClipView? liveView;
    if (_isRecording &&
        _armedTracks[trackIndex] &&
        _activeRecordTapeStartMs != null) {
      final int startMs = _activeRecordTapeStartMs!;
      liveView = OrpheusWaveformClipView(
        tapeStartMs: _waveformLaneTapeStartMs(startMs),
        clipDurationMs: max(0, _playbackMs - startMs),
        amplitudes: const [],
      );
    }

    return buildWaveformClipViewsForLane(
      trackClips: _clipsForLane(trackIndex),
      legacyFilePath: _trackFiles[trackIndex],
      legacyTapeStartMs: _trackTapeStartMs[trackIndex],
      waveformCache: _waveformCache,
      mapTapeStartMsForLane: _waveformLaneTapeStartMs,
      tapeLengthMs: tapeLengthMs,
      liveRecordingView: liveView,
    );
  }

  void _onTapeHeadSeekFromReel(int ms) {
    if (_isPlaying || _isRecording || _isExporting) return;
    _setTapeHeadMs(ms);
    debugPrint(
      'Orpheus Deck: TAPE_HEAD_SEEK playbackMs=$_playbackMs tapeLengthMs=$tapeLengthMs',
    );
  }

  Future<void> _setLastProjectName(String name) async {
    try {
      final file = await orpheusLastProjectFile();
      final ok = await writeOrpheusTextFileAtomic(file, contents: name);
      logOrpheusProjectSaveAttempt(
        phase: ok ? 'lastProjectOk' : 'lastProjectFailed',
        projectName: name,
        lastProjectPath: file.path,
        fileExistsAfterWrite: await file.exists(),
        fileLengthAfterWrite: await file.exists() ? await file.length() : 0,
        payloadBytes: name.length,
      );
      if (!ok) {
        orpheusReleaseLog('last_project save failed path=${file.path}');
      }
    } catch (e, s) {
      orpheusReleaseLogError('last_project save', e, s);
    }
  }

  Future<void> _cleanTrash() async {
    try {
      final projDir =
          await orpheusProjectDirectory(_projectName, create: false);
      if (await projDir.exists()) {
        final files = projDir.listSync();
        for (var file in files) {
          if (file is File && file.path.endsWith('.trash')) {
            file.deleteSync();
          }
        }
      }
    } catch (e, s) {
      debugPrint('Error cleaning trash: $e\n$s');
    }
  }

  Future<void> _recoverOrphanedRecordings() async {
    try {
      final projDir =
          await orpheusProjectDirectory(_projectName, create: false);
      if (await projDir.exists()) {
        final files = projDir.listSync();
        bool recovered = false;
        for (var file in files) {
          if (file is! File || !file.path.contains('track_')) {
            continue;
          }
          final bool isNativeWav = file.path.toLowerCase().endsWith('.wav') &&
              !_isMetronomeClickAssetPath(file.path);
          if (!isNativeWav) {
            continue;
          }
          if (!_trackFiles.contains(file.path)) {
            String filename = file.path.split(RegExp(r'[/\\]')).last;
            final nameParts = filename.split('_');
            if (nameParts.length >= 2) {
              int? trackIndex = int.tryParse(nameParts[1]);
              if (trackIndex != null && trackIndex >= 0 && trackIndex < 4) {
                if (_trackFiles[trackIndex] == null) {
                  _trackFiles[trackIndex] = file.path;
                  _waveformCache[file.path] = [];
                  recovered = true;
                  debugPrint(
                      "Orpheus Deck: RECOVERY LOG - Recovered orphaned recording to track $trackIndex: ${file.path}");
                }
              }
            }
          }
        }
        if (recovered) {
          _saveSession();
          _showSnackbar("RECOVERED UNFINISHED RECORDING");
        }
      }
    } catch (e, s) {
      debugPrint('Error recovering recordings: $e\n$s');
    }
  }

  bool get _isNativeProject => isNativeAudioEngine(_projectAudioEngine);

  bool get _projectIsSupported => !isLegacyUnsupportedProject(
        audioEngine: _projectAudioEngine,
        trackFiles: _trackFiles,
      );

  Future<void> _handleLegacyUnsupportedProject() async {
    if (!mounted) return;
    showOrpheusOledToast(context, kLegacyProjectUnsupportedMessage);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/home');
  }

  void _scheduleNativeTestAliasToastIfNeeded() {
    if (!kDebugMode || _projectAudioEngine != kOrpheusAudioEngineNativeTest) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      showOrpheusOledToast(context, 'DEV TEST ALIAS PROJECT');
    });
  }

  Future<void> _initializeNewProject(
    String name, {
    List<String?>? trackDisplayNames,
  }) async {
    _projectName = name;
    _sessionCreatedAt = DateTime.now();
    _projectAudioEngine = kOrpheusAudioEngineNative;
    for (int i = 0; i < 4; i++) {
      _trackFiles[i] = null;
      _armedTracks[i] = false;
      _trackOffsets[i] = 0;
      _trackTapeStartMs[i] = 0;
      _trackTapeStartSamples[i] = 0;
      _recordLatencyOffsetSamples[i] = 0;
      _trackVolumes[i] = 1.0;
      _trackMutes[i] = false;
      _trackSolos[i] = false;
      if (trackDisplayNames != null && i < trackDisplayNames.length) {
        _trackDisplayNames[i] = trackDisplayNames[i];
      } else {
        _trackDisplayNames[i] = null;
      }
    }
    _trackClips = emptyTrackClipsLanes();
    _waveformCache.clear();
    _exports.clear();
    _applyTapeHeadClamped(0);
    _lastUndo.clear();

    _updateMixerState();
    final saved = await _saveSession();
    orpheusReleaseLog(
      'newProject init name=$name saved=$saved engine=$_projectAudioEngine',
    );
    if (!saved && mounted) {
      _showSnackbar('ERR: PROJECT SAVE FAILED');
    }
    _scheduleNativeTestAliasToastIfNeeded();
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadSession() async {
    try {
      await _cleanTrash();

      final file = await orpheusSessionJsonFile(_projectName);

      if (await file.exists()) {
        final jsonString = await file.readAsString();
        final sessionJson = jsonDecode(jsonString) as Map<String, dynamic>;
        final session = Session.fromJson(sessionJson);
        final bool sessionHadSampleFields =
            sessionJsonHasNativeSampleTiming(sessionJson);

        for (int i = 0; i < 4; i++) {
          final trackPath = session.trackFiles[i];
          if (trackPath != null) {
            final f = File(trackPath);
            if (!await f.exists()) {
              session.trackFiles[i] = null;
              session.waveformCache.remove(trackPath);
            }
          }
        }

        final keptExports = <ExportEntry>[];
        for (final e in session.exports) {
          if (await _exportEntryStillValid(e)) keptExports.add(e);
        }

        setState(() {
          _projectName = session.projectName;
          _sessionCreatedAt = session.createdAt;
          _projectAudioEngine = session.audioEngine;
          for (int i = 0; i < 4; i++) {
            _trackFiles[i] = session.trackFiles[i];
            _trackOffsets[i] = session.trackOffsets[i];
            _trackTapeStartMs[i] = session.trackTapeStartMs[i];
            _trackTapeStartSamples[i] = session.trackTapeStartSamples[i];
            _recordLatencyOffsetSamples[i] =
                session.recordLatencyOffsetSamples[i];
            _trackVolumes[i] = session.trackVolumes[i];
            _trackMutes[i] = session.trackMutes[i];
            _trackSolos[i] = session.trackSolos[i];
            _trackDisplayNames[i] = session.trackDisplayNames[i];
          }
          _trackClips = cloneTrackClipsLanes(session.trackClips);
          _waveformCache.addAll(session.waveformCache);

          _exports = keptExports;

          _bpm = session.bpm;
          _metronomeOn = session.metronomeOn;
          _metronomeSound = normalizeMetronomeSound(session.metronomeSound);
          _clickVolume = session.clickVolume;
          _clickCountInBeats = session.clickCountInBeats;
        });
        hydrateNativeTrackSampleTiming(
          audioEngine: _projectAudioEngine,
          trackTapeStartMs: _trackTapeStartMs,
          trackOffsetsMs: _trackOffsets,
          trackTapeStartSamples: _trackTapeStartSamples,
          recordLatencyOffsetSamples: _recordLatencyOffsetSamples,
          sessionHadSampleFields: sessionHadSampleFields,
        );
        debugLogNativeSessionTrackMetadata(
          projectName: _projectName,
          audioEngine: _projectAudioEngine,
          trackFiles: _trackFiles,
          trackTapeStartMs: _trackTapeStartMs,
          trackTapeStartSamples: _trackTapeStartSamples,
          recordLatencyOffsetSamples: _recordLatencyOffsetSamples,
          tag: 'N3F_LOAD',
        );
      }

      if (!_projectIsSupported) {
        await _handleLegacyUnsupportedProject();
        return;
      }

      _lastUndo.clear();
      await _recoverOrphanedRecordings();
      _updateMixerState();
      await _setLastProjectName(_projectName);
      _scheduleNativeTestAliasToastIfNeeded();
    } catch (e) {
      debugPrint("Orpheus Deck: Error loading session: $e");
    }
  }

  Future<bool> _saveSession() async {
    String? deckPath;
    String? projectPath;
    String? sessionPath;
    try {
      final clipsForSave = reconcileTrackClipsForSave(
        existing: _trackClips,
        trackFiles: _trackFiles,
        trackTapeStartSamples: _trackTapeStartSamples,
        recordLatencyOffsetSamples: _recordLatencyOffsetSamples,
        waveformCache: _waveformCache,
        fallbackCreatedAt: _sessionCreatedAt,
      );
      _trackClips = cloneTrackClipsLanes(clipsForSave);

      final session = Session(
        projectName: _projectName,
        createdAt: _sessionCreatedAt,
        updatedAt: DateTime.now(),
        trackFiles: _trackFiles,
        waveformCache: _waveformCache,
        trackIds: [null, null, null, null],
        trackOffsets: List<int>.from(_trackOffsets),
        trackTapeStartMs: List<int>.from(_trackTapeStartMs),
        trackTapeStartSamples: List<int>.from(_trackTapeStartSamples),
        recordLatencyOffsetSamples: List<int>.from(_recordLatencyOffsetSamples),
        trackVolumes: _trackVolumes,
        trackMutes: _trackMutes,
        trackSolos: _trackSolos,
        trackDisplayNames: List<String?>.from(_trackDisplayNames),
        trackClips: clipsForSave,
        trackClipsVersion: kOrpheusTrackClipsVersion,
        exports: _exports,
        bpm: _bpm,
        metronomeOn: _metronomeOn,
        metronomeSound: _metronomeSound,
        clickVolume: _clickVolume,
        clickCountInBeats: _clickCountInBeats,
        audioEngine: _projectAudioEngine,
      );

      final deck = await orpheusDeckRootDirectory();
      deckPath = deck.path;
      final projDir = await orpheusProjectDirectory(_projectName);
      projectPath = projDir.path;
      final finalFile = File('${projDir.path}/session.json');
      sessionPath = finalFile.path;

      logOrpheusProjectSaveAttempt(
        phase: 'beforeWrite',
        projectName: _projectName,
        deckPath: deckPath,
        projectPath: projectPath,
        sessionPath: sessionPath,
        deckExists: await deck.exists(),
        projectExists: await projDir.exists(),
      );

      final String payload;
      try {
        payload = jsonEncode(session.toJson());
      } catch (encodeError, encodeSt) {
        logOrpheusProjectSaveAttempt(
          phase: 'jsonEncodeFailed',
          projectName: _projectName,
          deckPath: deckPath,
          projectPath: projectPath,
          sessionPath: sessionPath,
          error: encodeError,
          stackTrace: encodeSt,
        );
        return false;
      }

      final ok = await writeOrpheusTextFileAtomic(
        finalFile,
        contents: payload,
      );
      final fileExists = await finalFile.exists();
      final fileLen = fileExists ? await finalFile.length() : 0;

      logOrpheusProjectSaveAttempt(
        phase: ok ? 'afterWriteOk' : 'afterWriteFailed',
        projectName: _projectName,
        deckPath: deckPath,
        projectPath: projectPath,
        sessionPath: sessionPath,
        payloadBytes: payload.length,
        fileExistsAfterWrite: fileExists,
        fileLengthAfterWrite: fileLen,
      );

      if (!ok || !fileExists || fileLen != payload.length) {
        orpheusReleaseLog(
          'session save failed project=$_projectName path=$sessionPath '
          'ok=$ok exists=$fileExists len=$fileLen expected=${payload.length}',
        );
        return false;
      }

      await _setLastProjectName(_projectName);
      orpheusReleaseLog(
        'session saved project=$_projectName path=$sessionPath',
      );
      return true;
    } catch (e, s) {
      logOrpheusProjectSaveAttempt(
        phase: 'exception',
        projectName: _projectName,
        deckPath: deckPath,
        projectPath: projectPath,
        sessionPath: sessionPath,
        error: e,
        stackTrace: s,
      );
      return false;
    }
  }

  void _performUndo() async {
    if (_isRecording || _isPlaying) {
      _showSnackbar("ERR: STOP TRANSPORT TO UNDO");
      return;
    }

    if (_lastUndo.action == UndoAction.clearTrack) {
      int idx = _lastUndo.trackIndex!;
      String file = _lastUndo.trackFile!;
      if (_laneHasAudio(idx)) {
        _showSnackbar("ERR: TRACK 0${idx + 1} NOT EMPTY");
        return;
      }

      File trash = File('$file.trash');
      if (trash.existsSync()) {
        trash.renameSync(file);
        setState(() {
          _trackFiles[idx] = file;
          _trackTapeStartMs[idx] = _lastUndo.trackTapeStartMs ?? 0;
          if (_isNativeProject) {
            _trackTapeStartSamples[idx] =
                orpheusSessionMsToSamples(_trackTapeStartMs[idx]);
            _recordLatencyOffsetSamples[idx] = 0;
          }
          if (_lastUndo.trackWaveform != null) {
            _waveformCache[file] = _lastUndo.trackWaveform!;
          }
          _trackClips[idx] = [
            buildLegacyMirrorClip(
              trackIndex: idx,
              filePath: file,
              tapeStartSamples: _trackTapeStartSamples[idx],
              recordLatencyOffsetSamples: _recordLatencyOffsetSamples[idx],
              waveformCache: _waveformCache,
              createdAt: _sessionCreatedAt,
            ),
          ];
        });
        _showSnackbar("TRACK 0${idx + 1} RESTORED");
      }
    } else if (_lastUndo.action == UndoAction.mixer) {
      setState(() {
        _trackVolumes.setAll(0, _lastUndo.volumes!);
        _trackMutes.setAll(0, _lastUndo.mutes!);
        _trackSolos.setAll(0, _lastUndo.solos!);
      });
      _updateMixerState();
      _showSnackbar("MIXER SETTINGS RESTORED");
    } else if (_lastUndo.action == UndoAction.rename) {
      try {
        final currentDir =
            await orpheusProjectDirectory(_lastUndo.newName!, create: false);
        final oldDir =
            await orpheusProjectDirectory(_lastUndo.oldName!, create: false);
        if (await currentDir.exists()) {
          await currentDir.rename(oldDir.path);

          Map<String, List<double>> newCache = {};
          for (int i = 0; i < 4; i++) {
            if (_trackFiles[i] != null) {
              String currentPath = _trackFiles[i]!;
              String oldPath = currentPath.replaceFirst(
                  '/OrpheusDeck/${_lastUndo.newName}/',
                  '/OrpheusDeck/${_lastUndo.oldName}/');
              _trackFiles[i] = oldPath;
              if (_waveformCache.containsKey(currentPath)) {
                newCache[oldPath] = _waveformCache[currentPath]!;
              }
            }
          }
          _waveformCache.clear();
          _waveformCache.addAll(newCache);

          final newExports = <ExportEntry>[];
          for (final e in _exports) {
            final ap = e.absolutePath;
            if (ap != null &&
                ap.contains('/OrpheusDeck/${_lastUndo.newName}/')) {
              newExports.add(e.copyWith(
                  absolutePath: ap.replaceFirst(
                      '/OrpheusDeck/${_lastUndo.newName}/',
                      '/OrpheusDeck/${_lastUndo.oldName}/')));
            } else {
              newExports.add(e);
            }
          }
          _exports.clear();
          _exports.addAll(newExports);

          setState(() {
            _projectName = _lastUndo.oldName!;
          });
          await _setLastProjectName(_projectName);
          _showSnackbar("PROJECT RENAME UNDONE");
        }
      } catch (e) {
        _showSnackbar("ERR: UNDO RENAME FAILED");
      }
    }

    setState(() {
      _lastUndo.clear();
    });
    _saveSession();
  }

  bool _transportBusy() => _isRecording || _isPlaying || _isExporting;

  Future<void> _renameProject(String newName) async {
    final safeName = sanitizeOrpheusProjectFolderName(newName);
    if (safeName.isEmpty || safeName == _projectName) return;
    final existing = await listOrpheusDeckProjectNames();
    final err = validateOrpheusProjectFolderName(
      newName,
      existingNames: existing,
      allowSameAs: _projectName,
    );
    if (err != null) {
      _showSnackbar(err);
      return;
    }
    await _stop();
    try {
      final oldDir = await orpheusProjectDirectory(_projectName, create: false);
      final newDir = await orpheusProjectDirectory(safeName, create: false);

      if (await oldDir.exists()) {
        _lastUndo.clear();
        _lastUndo.action = UndoAction.rename;
        _lastUndo.oldName = _projectName;
        _lastUndo.newName = safeName;

        await oldDir.rename(newDir.path);

        Map<String, List<double>> newCache = {};
        for (int i = 0; i < 4; i++) {
          if (_trackFiles[i] != null) {
            String oldPath = _trackFiles[i]!;
            String newPath = oldPath.replaceFirst(
                '/OrpheusDeck/$_projectName/', '/OrpheusDeck/$safeName/');
            _trackFiles[i] = newPath;
            if (_waveformCache.containsKey(oldPath)) {
              newCache[newPath] = _waveformCache[oldPath]!;
            }
          }
        }
        _waveformCache.clear();
        _waveformCache.addAll(newCache);

        final newExports = <ExportEntry>[];
        for (final e in _exports) {
          final ap = e.absolutePath;
          if (ap != null && ap.contains('/OrpheusDeck/$_projectName/')) {
            newExports.add(e.copyWith(
                absolutePath: ap.replaceFirst(
                    '/OrpheusDeck/$_projectName/', '/OrpheusDeck/$safeName/')));
          } else {
            newExports.add(e);
          }
        }
        _exports.clear();
        _exports.addAll(newExports);
      }

      setState(() {
        _projectName = safeName;
      });
      await _saveSession();
      _showSnackbar("PROJECT RENAMED");
    } catch (e) {
      _showSnackbar("ERR: RENAME FAILED");
    }
  }

  Future<void> _applyProjectRenameOffDisk(
      String oldName, String safeName) async {
    await applyOrpheusProjectRenameOffDisk(
      oldName,
      safeName,
      onMessage: _showSnackbar,
    );
  }

  Future<void> _renameProjectFromList(
    String oldName,
    String newName,
    Future<void> Function() onListChanged,
  ) async {
    final safeName = sanitizeOrpheusProjectFolderName(newName);
    if (safeName.isEmpty || safeName == oldName) return;
    final existing = await listOrpheusDeckProjectNames();
    final err = validateOrpheusProjectFolderName(
      newName,
      existingNames: existing,
      allowSameAs: oldName,
    );
    if (err != null) {
      _showSnackbar(err);
      return;
    }
    if (oldName == _projectName) {
      await _renameProject(safeName);
      await onListChanged();
      return;
    }
    try {
      await _applyProjectRenameOffDisk(oldName, safeName);
      await onListChanged();
    } catch (e) {
      _showSnackbar('ERR: RENAME FAILED');
    }
  }

  Future<void> _deleteProjectFromList(
    String name,
    BuildContext projectsDialogContext,
    Future<void> Function() onListChanged,
  ) async {
    final isCurrent = name == _projectName;
    if (isCurrent && _transportBusy()) {
      showOrpheusOledToast(context, 'STOP PLAY/REC FIRST');
      return;
    }
    showOrpheusDeleteProjectConfirmDialog(
      context,
      projectName: name,
      onDelete: () async {
        final navigator = Navigator.of(context);
        try {
          if (isCurrent) {
            await _stop();
          }
          await deleteOrpheusProjectFolder(name);
          if (!context.mounted) return;
          if (isCurrent) {
            Navigator.pop(projectsDialogContext);
            navigator.pushReplacementNamed('/home');
            return;
          }
          await onListChanged();
          _showSnackbar('PROJECT DELETED');
        } catch (e) {
          _showSnackbar('ERR: DELETE FAILED');
        }
      },
    );
  }

  Future<void> _newProject(String name) async {
    String safeName = sanitizeOrpheusProjectFolderName(name);
    if (safeName.isEmpty) safeName = "SESSION_001";
    final existing = await listOrpheusDeckProjectNames();
    final err = validateOrpheusProjectFolderName(
      name,
      existingNames: existing,
    );
    if (err != null) {
      _showSnackbar(err);
      return;
    }
    await _cleanTrash();
    _stop();
    await _initializeNewProject(safeName);
    setState(() {});
    _showSnackbar("NEW PROJECT CREATED");
  }

  Future<bool> _exportEntryStillValid(ExportEntry e) async {
    if (e.absolutePath != null) {
      return File(e.absolutePath!).existsSync();
    }
    if (Platform.isAndroid &&
        e.storageUri != null &&
        e.storageUri!.startsWith('content://')) {
      try {
        final ok = await _androidExportChannel
            .invokeMethod<bool>('contentUriExists', {'uri': e.storageUri});
        return ok ?? true;
      } catch (_) {
        return true;
      }
    }
    return false;
  }

  Future<Directory> _nonAndroidExportDirectory() async {
    final downloads = await getDownloadsDirectory();
    if (downloads != null) {
      return Directory(
          '${downloads.path}${Platform.pathSeparator}Orpheus Deck');
    }
    final docs = await getApplicationDocumentsDirectory();
    return Directory('${docs.path}${Platform.pathSeparator}OrpheusDeckExports');
  }

  String _nonAndroidDisplayPath(String fileName, Directory destDir) {
    final p = destDir.path;
    if (p.contains('Download')) {
      return 'Downloads/Orpheus Deck/$fileName';
    }
    return 'Documents/OrpheusDeckExports/$fileName';
  }

  Future<ExportEntry?> _finalizeExportAfterFfmpeg({
    required String tempPath,
    required String fileName,
    required String kind,
  }) async {
    if (Platform.isAndroid) {
      try {
        final dynamic raw = await _androidExportChannel.invokeMethod(
          'publishToMusicFolder',
          <String, dynamic>{
            'sourcePath': tempPath,
            'fileName': fileName,
          },
        );
        await _deleteExportIfExists(tempPath);
        if (raw is! Map) return null;
        final uri = raw['uri']?.toString();
        final displayPath =
            raw['displayPath']?.toString() ?? 'Music/Orpheus Deck/$fileName';
        if (uri == null) return null;
        debugPrint(
            'Orpheus Deck: published Android uri=$uri displayPath=$displayPath');
        return ExportEntry(
          filename: fileName,
          displayPath: displayPath,
          storageUri: uri,
          absolutePath: null,
          kind: kind,
          createdAt: DateTime.now(),
        );
      } on PlatformException catch (e, st) {
        debugPrint(
            'Orpheus Deck: publishToMusicFolder ${e.code} ${e.message}\n$st');
        await _deleteExportIfExists(tempPath);
        return null;
      }
    }

    final destDir = await _nonAndroidExportDirectory();
    await destDir.create(recursive: true);
    final destPath = '${destDir.path}${Platform.pathSeparator}$fileName';
    await File(tempPath).copy(destPath);
    await _deleteExportIfExists(tempPath);
    debugPrint('Orpheus Deck: published non-Android path=$destPath');
    return ExportEntry(
      filename: fileName,
      displayPath: _nonAndroidDisplayPath(fileName, destDir),
      storageUri: null,
      absolutePath: destPath,
      kind: kind,
      createdAt: DateTime.now(),
    );
  }

  Future<void> _shareExportEntry(ExportEntry e) async {
    try {
      final uriStr = e.storageUri;
      // share_plus on Android treats paths as java.io.File and wraps FileProvider;
      // MediaStore content:// URIs must be sent via ACTION_SEND + EXTRA_STREAM.
      if (uriStr != null &&
          uriStr.startsWith('content://') &&
          Platform.isAndroid) {
        debugPrint('Orpheus Deck: share export — MediaStore URI: $uriStr');
        await _androidExportChannel.invokeMethod<void>('shareMusicExport', {
          'uri': uriStr,
        });
        debugPrint('Orpheus Deck: share export — native share sheet launched');
        return;
      }
      if (e.absolutePath != null && File(e.absolutePath!).existsSync()) {
        final path = e.absolutePath!;
        debugPrint('Orpheus Deck: share export — filesystem path: $path');
        await SharePlus.instance.share(ShareParams(
          files: [XFile(path)],
          text: 'Exported from Orpheus Deck',
        ));
        return;
      }
      debugPrint(
          'Orpheus Deck: share export — nothing to share for ${e.filename}');
    } catch (err, st) {
      debugPrint('Orpheus Deck: share export failed: $err\n$st');
      if (mounted) {
        _showSnackbar('SHARE FAILED');
      }
    }
  }

  Future<void> _tryOpenExportLocation(ExportEntry entry) async {
    if (Platform.isAndroid && entry.storageUri != null) {
      try {
        final opened = await _androidExportChannel
            .invokeMethod<bool>('tryOpenExportLocation', {
          'uri': entry.storageUri,
        });
        if (opened == true && mounted) return;
      } catch (_) {}
      if (mounted) {
        _showSnackbar('Saved to Music / Orpheus Deck');
      }
      return;
    }
    if (entry.absolutePath != null) {
      final dir = File(entry.absolutePath!).parent.path;
      final OpenResult r = await OpenFile.open(dir);
      debugPrint(
          'Orpheus Deck: OpenFile dir type=${r.type} message=${r.message}');
      if (r.type != ResultType.done && mounted) {
        _showSnackbar('Saved to ${entry.displayPath}');
      }
    }
  }

  bool _exportEntrySameLogicalTarget(ExportEntry a, ExportEntry b) {
    final ua = a.storageUri;
    final ub = b.storageUri;
    if (ua != null && ua.isNotEmpty && ub != null && ua == ub) return true;
    final pa = a.absolutePath;
    final pb = b.absolutePath;
    if (pa != null &&
        pb != null &&
        pa.isNotEmpty &&
        pb.isNotEmpty &&
        pa == pb) {
      return true;
    }
    return a.filename.toLowerCase() == b.filename.toLowerCase();
  }

  Future<_ExportBrowseSnapshot> _loadExportsBrowseSnapshot() async {
    bool scanErrored = false;
    final scanMaps = <Map<String, dynamic>>[];

    if (Platform.isAndroid) {
      try {
        final dynamic raw =
            await _androidExportChannel.invokeMethod('scanOrpheusMusicExports');
        if (raw is List) {
          for (final item in raw) {
            if (item is Map) {
              scanMaps.add(Map<String, dynamic>.from(item));
            }
          }
        }
      } catch (e, st) {
        scanErrored = true;
        debugPrint('Orpheus Deck: scanOrpheusMusicExports err $e\n$st');
      }
    }

    ExportEntry scannedRow(Map<String, dynamic> m) {
      final fn = (m['filename']?.toString() ?? '').trim();
      final uri = m['storageUri']?.toString();
      final sec = (m['dateAddedSec'] as num?)?.toInt();
      final lower = fn.toLowerCase();
      final kind =
          lower.contains('mastermix') || lower.contains('youtube_master')
              ? 'MASTERMIX'
              : 'RAW MIX';
      final DateTime when;
      if (sec != null) {
        when = DateTime.fromMillisecondsSinceEpoch(sec * 1000, isUtc: true)
            .toLocal();
      } else {
        when = DateTime.fromMillisecondsSinceEpoch(0);
      }
      return ExportEntry(
        filename: fn,
        displayPath: 'Music/Orpheus Deck/$fn',
        storageUri: uri,
        absolutePath: null,
        kind: kind,
        createdAt: when,
      );
    }

    final fromScan =
        scanMaps.map(scannedRow).where((e) => e.filename.isNotEmpty).toList();

    final byUri = <String, ExportEntry>{};
    final byName = <String, ExportEntry>{};
    for (final e in _exports) {
      if (e.storageUri != null) byUri[e.storageUri!] = e;
      byName[e.filename.toLowerCase()] = e;
    }

    final merged = List<ExportEntry>.from(_exports);
    for (final e in fromScan) {
      if (e.storageUri != null && byUri.containsKey(e.storageUri)) continue;
      if (byName.containsKey(e.filename.toLowerCase())) continue;
      merged.add(e);
    }
    merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    String? footer;
    if (merged.isEmpty) {
      footer = 'EXPORTS SAVED TO MUSIC/ORPHEUS DECK';
    } else if (Platform.isAndroid && scanErrored && fromScan.isEmpty) {
      footer =
          'EXPORT SCAN UNAVAILABLE • EXPORTS ALSO SAVED TO MUSIC/ORPHEUS DECK';
    }

    return _ExportBrowseSnapshot(entries: merged, footerHintText: footer);
  }

  Future<bool> _deleteExportBrowsedEntry(ExportEntry e) async {
    bool removed = false;
    if (Platform.isAndroid &&
        e.storageUri != null &&
        e.storageUri!.startsWith('content://')) {
      try {
        final ok = await _androidExportChannel.invokeMethod<bool>(
                'deleteMusicExport', {'uri': e.storageUri}) ??
            false;
        if (ok == true) removed = true;
      } catch (err) {
        debugPrint('Orpheus Deck: deleteMusicExport $err');
      }
    }
    final ap = e.absolutePath;
    if (ap != null && File(ap).existsSync()) {
      try {
        await _deleteExportIfExists(ap);
        removed = true;
      } catch (_) {}
    }
    if (!mounted) return removed;
    setState(() {
      _exports.removeWhere((x) => _exportEntrySameLogicalTarget(x, e));
    });
    await _saveSession();
    if (mounted) {
      removed
          ? _showSnackbar('EXPORT REMOVED')
          : _showSnackbar('DELETE FAILED OR EXPORT NOT FOUND');
    }
    return removed;
  }

  Future<void> _showExportsBrowseDialog() async {
    await showDialog<void>(
      context: context,
      builder: (_) => _ExportsBrowseHost(recorder: this),
    );
  }

  Future<void> _deleteExportIfExists(String path) async {
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } catch (e) {
      debugPrint('Orpheus Deck: delete export failed: $e');
    }
  }

  Future<int?> _awaitStableExportSize(File file) async {
    const attempts = 10;
    const delay = Duration(milliseconds: 50);
    int? last;
    for (var i = 0; i < attempts; i++) {
      if (!await file.exists()) return null;
      final len = await file.length();
      if (last != null && len == last && len > 48) return len;
      last = len;
      await Future<void>.delayed(delay);
    }
    return await file.exists() ? await file.length() : null;
  }

  bool _wavRiffWaveHeaderLooksValid(File file) {
    RandomAccessFile? raf;
    try {
      if (file.lengthSync() < 12) return false;
      raf = file.openSync(mode: FileMode.read);
      final b = raf.readSync(12);
      if (b.length < 12) return false;
      final riff = String.fromCharCodes(b.sublist(0, 4));
      final wave = String.fromCharCodes(b.sublist(8, 12));
      return riff == 'RIFF' && wave == 'WAVE';
    } catch (e) {
      debugPrint('Orpheus Deck: WAV header check failed: $e');
      return false;
    } finally {
      raf?.closeSync();
    }
  }

  Future<({bool ok, String detail, String? durationSec})> _verifyExportedWav(
      String path) async {
    final file = File(path);
    final size = await _awaitStableExportSize(file);
    debugPrint('Orpheus Deck: export output path: $path');
    debugPrint('Orpheus Deck: export output size (stable): $size bytes');
    if (size == null || size <= 48) {
      return (
        ok: false,
        detail: 'missing_or_tiny_file size=$size',
        durationSec: null,
      );
    }
    if (!_wavRiffWaveHeaderLooksValid(file)) {
      return (ok: false, detail: 'invalid_riff_wave_header', durationSec: null);
    }
    try {
      final session = await orpheusFfprobeGetMediaInformation(path);
      final info = session.getMediaInformation();
      if (info == null) {
        return (
          ok: false,
          detail: 'ffprobe_no_media_information',
          durationSec: null
        );
      }
      final durStr = info.getDuration();
      final durSec = double.tryParse(durStr ?? '');
      debugPrint(
          'Orpheus Deck: ffprobe format=${info.getFormat()} duration=$durStr format_size=${info.getSize()}');
      final audioStreams =
          info.getStreams().where((s) => s.getType() == 'audio').toList();
      final a0 = audioStreams.isNotEmpty ? audioStreams.first : null;
      final codec = a0?.getCodec();
      final sampleRate = a0?.getSampleRate();
      debugPrint(
          'Orpheus Deck: ffprobe audio0 codec=$codec sample_rate=$sampleRate');
      final codecOk = codec == 'pcm_s16le';
      final durOk = durSec != null && durSec > 0.004;
      final ok = codecOk && durOk;
      final detail =
          'codec=$codec duration=$durStr codecOk=$codecOk durOk=$durOk';
      return (ok: ok, detail: detail, durationSec: durStr);
    } catch (e, st) {
      debugPrint('Orpheus Deck: ffprobe error: $e\n$st');
      return (ok: false, detail: 'ffprobe: $e', durationSec: null);
    }
  }

  /// Single path segment for exported WAV names; lowercase [a-z0-9._-].
  String _exportFilenameSlug(String projectName) =>
      orpheusProjectExportSlug(projectName);

  /// Matches examples like 2026-05-09_103045 (date + time with seconds for uniqueness).
  String _exportFileTimestamp() {
    final n = DateTime.now();
    String z2(int v) => v.toString().padLeft(2, '0');
    return '${n.year}-${z2(n.month)}-${z2(n.day)}_${z2(n.hour)}${z2(n.minute)}${z2(n.second)}';
  }

  /// FFprobe one export input file (diagnostic only).
  Future<void> _logExportInputFfprobe({
    required int deckTrackIndex,
    required int ffmpegInputIndex,
    required String path,
  }) async {
    try {
      final session = await orpheusFfprobeGetMediaInformation(path);
      final info = session.getMediaInformation();
      if (info == null) {
        debugPrint(
          'Orpheus Deck: EXPORT INPUT_PROBE deck=$deckTrackIndex '
          'ffmpegInput=$ffmpegInputIndex path=$path -> no media information',
        );
        return;
      }
      final streams = info.getStreams();
      final audioStreams =
          streams.where((s) => s.getType() == 'audio').toList();
      debugPrint(
        'Orpheus Deck: EXPORT INPUT_PROBE deck=$deckTrackIndex '
        'ffmpegInput=$ffmpegInputIndex path=$path '
        'format=${info.getFormat()} duration=${info.getDuration()} '
        'startTime=${info.getStartTime()} size=${info.getSize()} '
        'audioStreamCount=${audioStreams.length}',
      );
      for (int s = 0; s < audioStreams.length; s++) {
        final a = audioStreams[s];
        debugPrint(
          'Orpheus Deck: EXPORT INPUT_PROBE deck=$deckTrackIndex '
          'stream#$s codec=${a.getCodec()} '
          'sampleRate=${a.getSampleRate()} '
          'channelLayout=${a.getChannelLayout()} '
          'bitrate=${a.getBitrate()} timeBase=${a.getTimeBase()}',
        );
      }
    } catch (e, st) {
      debugPrint(
        'Orpheus Deck: EXPORT INPUT_PROBE deck=$deckTrackIndex '
        'ffmpegInput=$ffmpegInputIndex path=$path error=$e\n$st',
      );
    }
  }

  /// Diagnostic: synthetic 440/660/880 Hz tones at tape 0s / 5s / 10s using the
  /// same adelay → amix → optional loudnorm mapping as [_exportMix].
  /// Publishes Music/Orpheus Deck/export_alignment_test.wav
  /// Not shown in PROJECT MGMT (beta UI); method kept for tooling / future gates.
  // ignore: unused_element
  Future<void> _testExportAlignment({bool masterMix = false}) async {
    if (_isRecording || _isPlaying) _stop();
    if (_isExporting) {
      _showSnackbar('ERR: EXPORT ALREADY RUNNING');
      return;
    }

    setState(() => _isExporting = true);

    const String fileName = 'export_alignment_test.wav';
    const List<int> tapeStartsMs = [0, 5000, 10000];
    const List<int> freqsHz = [440, 660, 880];
    const String rawOutPad = '[export_raw]';
    const String masterOutPad = '[export_master]';

    try {
      final tempDir = await getTemporaryDirectory();
      final outPath =
          '${tempDir.path}/orpheus_alignment_test_${DateTime.now().millisecondsSinceEpoch}.wav';

      final List<String> inputs = [];
      for (final hz in freqsHz) {
        inputs.addAll(['-f', 'lavfi', '-i', 'sine=frequency=$hz:duration=2']);
      }

      final List<String> filterParts = [];
      for (int j = 0; j < tapeStartsMs.length; j++) {
        final int delayMs = tapeStartsMs[j];
        if (delayMs > 0) {
          filterParts.add('[$j:a]adelay=$delayMs:all=1,volume=1[a$j]');
        } else {
          filterParts.add('[$j:a]volume=1[a$j]');
        }
      }

      final String mixInputs =
          List<String>.generate(tapeStartsMs.length, (j) => '[a$j]').join();
      String filterGraph =
          '${filterParts.join(';')};${mixInputs}amix=inputs=${tapeStartsMs.length}:duration=longest:normalize=0$rawOutPad';
      String finalMappedPad = rawOutPad;
      if (masterMix) {
        filterGraph += ';${rawOutPad}loudnorm=I=-14:TP=-1:LRA=11$masterOutPad';
        finalMappedPad = masterOutPad;
      }

      final List<String> command = [
        ...inputs,
        '-filter_complex',
        filterGraph,
        '-map',
        finalMappedPad,
        '-vn',
        '-sn',
        '-dn',
        '-map_metadata',
        '-1',
        '-acodec',
        'pcm_s16le',
        '-ar',
        '44100',
        '-ac',
        '1',
        '-f',
        'wav',
        '-y',
        outPath,
      ];

      final String cmdLogged = command
          .map((a) => (a.contains(' ') || a.contains('"'))
              ? '"${a.replaceAll('"', r'\"')}"'
              : a)
          .join(' ');

      debugPrint(
          'Orpheus Deck: TEST_EXPORT_ALIGNMENT start masterMix=$masterMix');
      debugPrint(
        'Orpheus Deck: TEST_EXPORT_ALIGNMENT expected: '
        '440Hz 0-2s, silence 2-5s, 660Hz 5-7s, silence 7-10s, 880Hz 10-12s',
      );
      debugPrint(
        'Orpheus Deck: TEST_EXPORT_ALIGNMENT tapeStartsMs=$tapeStartsMs '
        'finalMappedPad=$finalMappedPad rawInputAudioMapped=false',
      );
      debugPrint(
          'Orpheus Deck: TEST_EXPORT_ALIGNMENT filter_complex: $filterGraph');
      debugPrint('Orpheus Deck: TEST_EXPORT_ALIGNMENT ffmpeg $cmdLogged');

      final session = await orpheusFfmpegExecuteWithArguments(command);
      final returnCode = await session.getReturnCode();
      final rcVal = returnCode?.getValue();
      final logText = await session.getLogsAsString();
      debugPrint('Orpheus Deck: TEST_EXPORT_ALIGNMENT ffmpeg exit=$rcVal');
      if (logText.isNotEmpty) {
        debugPrint('Orpheus Deck: TEST_EXPORT_ALIGNMENT ffmpeg log:\n$logText');
      }

      if (!ReturnCode.isSuccess(returnCode)) {
        await _deleteExportIfExists(outPath);
        if (mounted) {
          _showSnackbar('ERR: ALIGNMENT TEST FAILED (ffmpeg $rcVal)');
        }
        return;
      }

      final ver = await _verifyExportedWav(outPath);
      int outBytes = -1;
      try {
        final f = File(outPath);
        if (f.existsSync()) outBytes = f.lengthSync();
      } catch (_) {}
      debugPrint(
        'Orpheus Deck: TEST_EXPORT_ALIGNMENT result ok=${ver.ok} '
        'detail=${ver.detail} duration=${ver.durationSec ?? "?"} bytes=$outBytes',
      );

      if (!ver.ok) {
        await _deleteExportIfExists(outPath);
        if (mounted) _showSnackbar('ERR: ALIGNMENT TEST VERIFY FAILED');
        return;
      }

      final entry = await _finalizeExportAfterFfmpeg(
        tempPath: outPath,
        fileName: fileName,
        kind: 'TEST_EXPORT_ALIGNMENT',
      );
      if (entry == null) {
        if (mounted) {
          _showSnackbar(Platform.isAndroid
              ? 'ERR: ALIGNMENT TEST SAVE FAILED'
              : 'ERR: ALIGNMENT TEST SAVE FAILED');
        }
        return;
      }

      debugPrint(
        'Orpheus Deck: TEST_EXPORT_ALIGNMENT saved '
        'displayPath=${entry.displayPath} uri=${entry.storageUri ?? entry.absolutePath}',
      );
      if (mounted) {
        _showSnackbar(
          'ALIGNMENT TEST SAVED\n${entry.displayPath}\n'
          'dur=${ver.durationSec ?? "?"}s — check logcat',
        );
      }
    } catch (e, st) {
      debugPrint('Orpheus Deck: TEST_EXPORT_ALIGNMENT error $e\n$st');
      if (mounted) {
        if (e is OrpheusFfmpegUnavailableException) {
          _showSnackbar(orpheusFfmpegUnavailableUserMessage(e.reason));
        } else {
          _showSnackbar('ERR: ALIGNMENT TEST FAILED');
        }
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  List<OrpheusExportClip> _sessionExportClips() {
    return buildExportClipsForLanes(
      trackClips: _trackClips,
      trackFiles: _trackFiles,
      trackTapeStartSamples: _trackTapeStartSamples,
      recordLatencyOffsetSamples: _recordLatencyOffsetSamples,
      tapeLengthMs: tapeLengthMs,
    );
  }

  Future<void> _exportMix(bool isMasterMix) async {
    if (_isRecording || _isPlaying) _stop();

    if (!_isNativeProject) {
      _showSnackbar('ERR: WAV PROJECT REQUIRED');
      return;
    }

    setState(() {
      _isExporting = true;
    });

    try {
      final tempDir = await getTemporaryDirectory();
      debugPrint('Orpheus Deck: FFmpeg temp write dir: ${tempDir.path}');

      final slug = _exportFilenameSlug(_projectName);
      final mixSeg = isMasterMix ? 'mastermix' : 'raw_mix';
      final stamp = _exportFileTimestamp();
      final outName = '${slug}_${mixSeg}_$stamp.wav';
      final tempId = DateTime.now().millisecondsSinceEpoch;
      final outPath = '${tempDir.path}/orpheus_exp_$tempId.wav';

      final List<String> inputs = [];
      final List<String> filterParts = [];
      final List<int> trackDelayMs = [];
      final List<int> trackIdxs = [];
      final List<double> targetVolList = [];
      int activeCount = 0;
      int expectedDurationMs = 0;

      final bool anySolo = _trackSolos.contains(true);

      final bool nativeTestExport = _isNativeProject;
      if (nativeTestExport) {
        debugPrint(
          'Orpheus N4: EXPORT_NATIVE_TEST_START project=$_projectName '
          'audioEngine=$_projectAudioEngine '
          'engineSampleRate=$kOrpheusRecorderSampleRate '
          'isMaster=$isMasterMix playbackMs=$_playbackMs '
          'delayMode=${NativeExportDelayMode.msRoundedAdelay.name} '
          '(FFmpeg adelay ms-rounded; not sub-ms sample exact) '
          'mutes=$_trackMutes solos=$_trackSolos vols=$_trackVolumes '
          'legacyLatencyCompIgnored=true',
        );
      }

      debugPrint(
        'Orpheus Deck: EXPORT_REAL_PROJECT project=$_projectName '
        'isMaster=$isMasterMix playbackMs=$_playbackMs '
        'trackTapeStartMs=$_trackTapeStartMs nativeTest=$nativeTestExport',
      );

      final allExportClips = _sessionExportClips();
      final mixInputs = selectAudibleMixExportInputs(
        allClips: allExportClips,
        volumes: _trackVolumes,
        mutes: _trackMutes,
        solos: _trackSolos,
        fileExists: (path) => File(path).existsSync(),
        fileByteLength: (path) => File(path).lengthSync(),
        isClickAsset: _isMetronomeClickAssetPath,
      );

      if (nativeTestExport) {
        for (final clip in allExportClips) {
          final skip = skipReasonForExportClip(
            clip: clip,
            fileExists: (path) => File(path).existsSync(),
            fileByteLength: (path) => File(path).lengthSync(),
            isClickAsset: _isMetronomeClickAssetPath,
          );
          final vol = resolveLaneExportVolume(
            laneIndex: clip.laneIndex,
            volumes: _trackVolumes,
            mutes: _trackMutes,
            solos: _trackSolos,
            anySolo: anySolo,
          );
          final included = skip == null && vol != null;
          if (!included) {
            debugPrint(
              'Orpheus N4: EXPORT_CLIP lane=${clip.laneIndex} '
              'id=${clip.clipId} SKIP path=${clip.filePath} '
              'reason=${skip ?? (vol == null ? "MUTE_SOLO" : "unknown")}',
            );
          }
        }
      }

      for (final input in mixInputs) {
        final clip = input.clip;
        final file = File(clip.filePath);
        final int fileBytes = file.lengthSync();
        final String ext = clip.filePath.contains('.')
            ? clip.filePath.split('.').last.toLowerCase()
            : 'none';

        debugPrint(
          'Orpheus Deck: EXPORT CLIP lane=${clip.laneIndex} id=${clip.clipId} '
          'path=${clip.filePath} ext=$ext '
          'tapeStartSamples=${clip.tapeStartSamples} '
          'effectiveTapeStartSamples=${clip.effectiveTapeStartSamples} '
          'adelayMs=${clip.adelayMs} sourceStart=${clip.sourceStartSamples} '
          'lengthSamples=${clip.lengthSamples} '
          'solo=${_trackSolos[clip.laneIndex]} mute=${_trackMutes[clip.laneIndex]} '
          'vol=${input.volume} fileBytes=$fileBytes included=true',
        );

        inputs.add('-i');
        inputs.add(clip.filePath);

        if (clip.hadNegativeEffective) {
          debugPrint(
            'Orpheus N4: EXPORT_CLIP lane=${clip.laneIndex} id=${clip.clipId} '
            'WARN negative effectiveTapeStartSamples '
            '(tapeStartSamples=${clip.tapeStartSamples} '
            'recordLatencyOffsetSamples=${clip.recordLatencyOffsetSamples}) '
            'clamped to 0 for adelay',
          );
        }

        final nativeTiming = resolveNativeExportTrackTiming(
          trackTapeStartSamples: clip.tapeStartSamples,
          recordLatencyOffsetSamples: clip.recordLatencyOffsetSamples,
          tapeLengthMs: tapeLengthMs,
        );
        final probed = await _ffprobeAudioDurationForExport(clip.filePath);
        final inputDurSamples = exportClipInputDurationSamples(
          clip: clip,
          probedFileSamples: probed?.durationSamples,
        );
        final int inputDurMs = probed?.durationMs ??
            (inputDurSamples > 0
                ? orpheusSessionSamplesToMs(inputDurSamples)
                : 0);
        final end = nativeExportExpectedEnd(
          timing: nativeTiming,
          inputDurationMs: inputDurMs,
          inputDurationSamples: inputDurSamples > 0 ? inputDurSamples : null,
        );
        if (end.expectedEndMs > expectedDurationMs) {
          expectedDurationMs = end.expectedEndMs;
        }
        debugLogNativeExportTrackTiming(
          deckIndex: clip.laneIndex,
          path: clip.filePath,
          timing: nativeTiming,
          targetVol: input.volume,
          mute: _trackMutes[clip.laneIndex],
          solo: _trackSolos[clip.laneIndex],
          inputDurationMs: inputDurMs,
          inputDurationSamples: inputDurSamples > 0 ? inputDurSamples : null,
          expectedEndMs: end.expectedEndMs,
          expectedEndSamples: end.expectedEndSamples,
        );

        trackDelayMs.add(clip.adelayMs);
        trackIdxs.add(clip.laneIndex);
        targetVolList.add(input.volume);
        filterParts.add(
          buildExportClipStageFilter(
            ffmpegInputIndex: input.ffmpegInputIndex,
            outputPadIndex: input.ffmpegInputIndex,
            clip: clip,
            volume: input.volume,
          ),
        );
        activeCount++;
      }

      for (int j = 0; j < activeCount; j++) {
        await _logExportInputFfprobe(
          deckTrackIndex: trackIdxs[j],
          ffmpegInputIndex: j,
          path: inputs[(j * 2) + 1],
        );
      }

      debugPrint(
        'Orpheus Deck: EXPORT_REAL inputOrder '
        'clipLanes=$trackIdxs ffmpegDelaysMs=$trackDelayMs '
        'clipCount=$activeCount tempOut=$outPath',
      );

      if (activeCount == 0) {
        _showSnackbar("ERR: NO AUDIBLE TRACKS");
        setState(() => _isExporting = false);
        return;
      }

      String filterGraph = filterParts.join(';');
      const String rawOutPad = "[export_raw]";
      const String masterOutPad = "[export_master]";
      String finalMappedPad = rawOutPad;

      if (activeCount > 1) {
        // amix with normalize=0 sums inputs straight (no 1/N scaling and no
        // dropout-transition gain bumps when one delayed track ends earlier
        // than another). duration=longest guarantees the output runs until
        // the last audible track's tape end.
        final String mixInputs = List<String>.generate(
          activeCount,
          (j) => "[a$j]",
        ).join();
        filterGraph +=
            ';${mixInputs}amix=inputs=$activeCount:duration=longest:normalize=0$rawOutPad';
      } else {
        // Even one-track exports go through a named final pad so FFmpeg never
        // has a chance to fall back to an unfiltered input stream.
        filterGraph += ';[a0]anull$rawOutPad';
      }

      if (isMasterMix) {
        filterGraph += ";${rawOutPad}loudnorm=I=-14:TP=-1:LRA=11$masterOutPad";
        finalMappedPad = masterOutPad;
      }

      final List<String> command = [
        ...inputs,
        "-filter_complex",
        filterGraph,
        "-map",
        finalMappedPad,
        "-vn",
        "-sn",
        "-dn",
        "-map_metadata",
        "-1",
        "-acodec",
        "pcm_s16le",
        "-ar",
        "44100",
        "-ac",
        "1",
        "-f",
        "wav",
        "-y",
        outPath,
      ];

      final String cmdLogged = command
          .map((a) => (a.contains(' ') || a.contains('"'))
              ? '"${a.replaceAll('"', r'\"')}"'
              : a)
          .join(' ');
      debugPrint(
        'Orpheus Deck: EXPORT_SUMMARY isMaster=$isMasterMix '
        'activeCount=$activeCount activeTracks=$trackIdxs '
        'delaysMs=$trackDelayMs manualMs=${OrpheusSettings.instance.manualLatencyAdjustMs} '
        'vols=$targetVolList '
        'expectedDurationMs=$expectedDurationMs tapeLengthMs=$tapeLengthMs '
        'nativeTest=$nativeTestExport',
      );
      if (nativeTestExport) {
        debugPrint(
          'Orpheus N4: EXPORT_NATIVE_TEST_SUMMARY outName=$outName '
          'tempOut=$outPath activeTracks=$trackIdxs delaysMs=$trackDelayMs '
          'expectedDurationMs=$expectedDurationMs delayMode='
          '${NativeExportDelayMode.msRoundedAdelay.name}',
        );
      }
      debugPrint(
        'Orpheus Deck: EXPORT final mapped pad: $finalMappedPad '
        'rawInputAudioMapped=false explicitFilterOutputOnly=true',
      );
      debugPrint('Orpheus Deck: EXPORT filter chain: $filterGraph');
      debugPrint('Orpheus Deck: FFmpeg full command: ffmpeg $cmdLogged');

      orpheusFfmpegExecuteWithArgumentsAsync(command, (session) async {
        try {
          final returnCode = await session.getReturnCode();
          final rcVal = returnCode?.getValue();
          final logText = await session.getLogsAsString();
          debugPrint('Orpheus Deck: FFmpeg exit code: $rcVal');
          if (logText.isNotEmpty) {
            debugPrint('Orpheus Deck: FFmpeg output:\n$logText');
          }

          if (ReturnCode.isCancel(returnCode)) {
            await _deleteExportIfExists(outPath);
            if (mounted) _showSnackbar("EXPORT CANCELED");
            return;
          }
          if (!ReturnCode.isSuccess(returnCode)) {
            await _deleteExportIfExists(outPath);
            if (mounted) {
              _showSnackbar("ERR: EXPORT FAILED (ffmpeg $rcVal)");
            }
            return;
          }

          final ver = await _verifyExportedWav(outPath);
          int outBytes = -1;
          try {
            final outFile = File(outPath);
            if (outFile.existsSync()) outBytes = outFile.lengthSync();
          } catch (_) {}
          debugPrint(
              'Orpheus Deck: EXPORT result ok=${ver.ok} detail=${ver.detail} '
              'duration=${ver.durationSec ?? "?"} bytes=$outBytes '
              'expectedDurationMs=$expectedDurationMs');
          if (nativeTestExport) {
            debugPrint(
              'Orpheus N4: EXPORT_NATIVE_TEST_VERIFY ok=${ver.ok} '
              'detail=${ver.detail} duration=${ver.durationSec ?? "?"} '
              'bytes=$outBytes expectedDurationMs=$expectedDurationMs '
              'tempOut=$outPath',
            );
          }

          if (!ver.ok) {
            await _deleteExportIfExists(outPath);
            if (mounted) _showSnackbar("ERR: EXPORT VERIFY FAILED");
            return;
          }

          if (!mounted) return;
          final kind = isMasterMix ? 'MASTERMIX' : 'RAW MIX';
          final entry = await _finalizeExportAfterFfmpeg(
            tempPath: outPath,
            fileName: outName,
            kind: kind,
          );
          debugPrint(
            'Orpheus Deck: EXPORT_PUBLISH temp=$outPath fileName=$outName '
            'saved=${entry?.displayPath} uri=${entry?.storageUri ?? entry?.absolutePath}',
          );
          if (nativeTestExport) {
            debugPrint(
              'Orpheus N4: EXPORT_NATIVE_TEST_PUBLISH fileName=$outName '
              'kind=$kind saved=${entry?.displayPath}',
            );
          }
          if (entry == null) {
            if (mounted) {
              _showSnackbar(Platform.isAndroid
                  ? 'ERR: SAVE TO MUSIC FAILED (ANDROID 10+)'
                  : 'ERR: EXPORT SAVE FAILED');
            }
            return;
          }

          setState(() {
            _exports.add(entry);
          });
          await _saveSession();
          if (!mounted) return;
          _showExportSuccessDialog(
            entry: entry,
            durationSec: ver.durationSec,
          );
        } catch (e, st) {
          debugPrint('Orpheus Deck: export callback error: $e\n$st');
          await _deleteExportIfExists(outPath);
          if (mounted) {
            if (e is OrpheusFfmpegUnavailableException) {
              _showSnackbar(orpheusFfmpegUnavailableUserMessage(e.reason));
            } else {
              _showSnackbar("ERR: EXPORT FAILED");
            }
          }
        } finally {
          if (mounted) {
            setState(() {
              _isExporting = false;
              _exportSessionId = null;
            });
          }
        }
      }).then((session) {
        _exportSessionId = session.getSessionId();
      });
    } catch (e) {
      debugPrint('Orpheus Deck: export setup error: $e');
      if (e is OrpheusFfmpegUnavailableException) {
        _showSnackbar(orpheusFfmpegUnavailableUserMessage(e.reason));
      } else {
        _showSnackbar("ERR: EXPORT FAILED");
      }
      setState(() {
        _isExporting = false;
      });
    }
  }

  void _showExportSuccessDialog({
    required ExportEntry entry,
    String? durationSec,
  }) {
    if (entry.storageUri != null) {
      debugPrint('Orpheus Deck: export storageUri=${entry.storageUri}');
    }
    showDialog(
        context: context,
        builder: (context) {
          final String body =
              'Saved:\n${entry.displayPath}\n\nKind: ${entry.kind}\nDuration (ffprobe): ${durationSec ?? '?'}\n';
          return AlertDialog(
            backgroundColor: Colors.black,
            shape: Border.all(color: Colors.white, width: 2),
            title: const Text("EXPORT COMPLETE",
                style: TextStyle(color: Colors.white, fontFamily: 'monospace')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SelectableText(
                  body,
                  style: const TextStyle(
                      color: Colors.white54,
                      fontFamily: 'monospace',
                      fontSize: 10),
                ),
                const SizedBox(height: 12),
                const Text(
                  'EXPORT USES CURRENT MIXER STATE',
                  style: TextStyle(
                    color: Colors.white38,
                    fontFamily: 'monospace',
                    fontSize: 9,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  if (!_exportShareLooksValid(entry)) {
                    _showSnackbar("ERR: EXPORT FILE INVALID");
                    return;
                  }
                  await _shareExportEntry(entry);
                },
                child: const Text("SHARE",
                    style: TextStyle(
                        color: Colors.white, fontFamily: 'monospace')),
              ),
              TextButton(
                onPressed: () async {
                  await _tryOpenExportLocation(entry);
                },
                child: const Text("OPEN EXPORT LOCATION",
                    style: TextStyle(
                        color: Colors.white70, fontFamily: 'monospace')),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK",
                    style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold)),
              ),
            ],
          );
        });
  }

  bool _quickExportLooksValidSync(File file) {
    try {
      if (!file.existsSync()) return false;
      if (file.lengthSync() <= 48) return false;
      return _wavRiffWaveHeaderLooksValid(file);
    } catch (_) {
      return false;
    }
  }

  bool _exportShareLooksValid(ExportEntry e) {
    if (e.storageUri != null && e.storageUri!.startsWith('content://')) {
      return true;
    }
    if (e.absolutePath != null) {
      return _quickExportLooksValidSync(File(e.absolutePath!));
    }
    return false;
  }

  void _syncNativeGuideClickToEngine({
    required String mode,
    int? transportStartSample,
  }) {
    if (!_isNativeProject) return;
    final eng = _nativeOboeEngine;
    if (eng == null) {
      debugPrint(
        'Orpheus NATIVE_CLICK: sync deferred mode=$mode (no engine)',
      );
      return;
    }
    if (!eng.n3cSessionOpen && !eng.n3dSessionOpen) {
      debugPrint(
        'Orpheus NATIVE_CLICK: sync deferred mode=$mode (session closed)',
      );
      return;
    }
    eng.syncGuideClick(
      enabled: _metronomeOn,
      bpm: _bpm,
      clickVolume: _clickVolume,
      metronomeSound: _metronomeSound,
      originSample: 0,
      mode: mode,
      transportStartSample: transportStartSample,
    );
  }

  void _onClickTransportTap() {
    if (_metronomeOn) {
      setState(() => _metronomeOn = false);
      _syncNativeGuideClickToEngine(
        mode: 'transport_off',
        transportStartSample: orpheusMsToNativeSamples(_playbackMs),
      );
      _saveSession();
      debugPrint(
        'Orpheus Deck: CLICK TRACK DISABLED (transport tap) '
        'recording=$_isRecording playing=$_isPlaying',
      );
      return;
    }
    _showClickTrackSettings();
  }

  void _showClickVolumeQuickPopup() {
    showOrpheusClickVolumeQuickPopup(
      context: context,
      initialVolume: _clickVolume,
      onVolumeChanged: (v) {
        setState(() => _clickVolume = v);
        _syncNativeGuideClickToEngine(mode: 'quick_vol');
      },
      onDone: _saveSession,
    );
  }

  Widget _clickCountInChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.black,
          border: Border.all(color: Colors.white),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white,
            fontFamily: 'monospace',
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showClickTrackSettings() {
    final bool previewAllowed =
        _isNativeProject && !_isRecording && !_isPlaying;
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.black,
              shape: Border.all(color: Colors.white, width: 2),
              title: const Text("CLICK TRACK",
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CLICK PLAYS A GUIDE RHYTHM WHILE YOU RECORD. IT IS NOT INCLUDED IN EXPORTS.',
                        style: TextStyle(
                            color: Colors.white70,
                            fontFamily: 'monospace',
                            fontSize: 11,
                            height: 1.4,
                            letterSpacing: 0.3),
                      ),
                      const SizedBox(height: 18),
                      OrpheusClickVolumeControl(
                        volume: _clickVolume,
                        onChanged: (v) {
                          setState(() => _clickVolume = v);
                          setDialogState(() {});
                          _syncNativeGuideClickToEngine(mode: 'dialog_vol');
                        },
                        onChangeEnd: () => _saveSession(),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'BEAT DOTS ARE ON THE MAIN SCREEN (UNDER THE CLOCK). '
                        'LONG-PRESS DOTS WHILE RECORDING FOR QUICK VOLUME.',
                        style: TextStyle(
                          color: Colors.white38,
                          fontFamily: 'monospace',
                          fontSize: 9,
                          height: 1.35,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("CLICK",
                                style: TextStyle(
                                    color: Colors.white54,
                                    fontFamily: 'monospace')),
                            GestureDetector(
                                onTap: () async {
                                  final next = !_metronomeOn;
                                  if (next) {
                                    setState(() => _metronomeOn = true);
                                    setDialogState(() {});
                                    debugPrint(
                                        'Orpheus Deck: CLICK TRACK ENABLED '
                                        'bpm=$_bpm recording=$_isRecording playing=$_isPlaying');
                                    _saveSession();
                                    _syncNativeGuideClickToEngine(
                                      mode: 'dialog_on',
                                      transportStartSample:
                                          orpheusMsToNativeSamples(
                                        _playbackMs,
                                      ),
                                    );
                                  } else {
                                    setState(() => _metronomeOn = false);
                                    setDialogState(() {});
                                    _syncNativeGuideClickToEngine(
                                      mode: 'dialog_off',
                                    );
                                    debugPrint(
                                        'Orpheus Deck: CLICK TRACK DISABLED '
                                        'recording=$_isRecording playing=$_isPlaying');
                                    _saveSession();
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _metronomeOn
                                        ? Colors.white
                                        : Colors.black,
                                    border: Border.all(color: Colors.white),
                                  ),
                                  child: Text(_metronomeOn ? "ON" : "OFF",
                                      style: TextStyle(
                                          color: _metronomeOn
                                              ? Colors.black
                                              : Colors.white,
                                          fontFamily: 'monospace',
                                          fontWeight: FontWeight.bold)),
                                ))
                          ]),
                      const SizedBox(height: 16),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("BPM",
                                style: TextStyle(
                                    color: Colors.white54,
                                    fontFamily: 'monospace')),
                            Row(children: [
                              OrpheusBpmStepButton(
                                icon: Icons.remove,
                                delta: -1,
                                enabled: _bpm > kOrpheusBpmMin,
                                onStep: () {
                                  if (_bpm <= kOrpheusBpmMin) return;
                                  setState(() => _bpm--);
                                  setDialogState(() {});
                                  debugPrint(
                                      'Orpheus Deck: CLICK TRACK BPM $_bpm '
                                      'recording=$_isRecording playing=$_isPlaying');
                                  _saveSession();
                                  _syncNativeGuideClickToEngine(
                                    mode: 'dialog_bpm',
                                  );
                                },
                              ),
                              GestureDetector(
                                onTap: () async {
                                  final next = await showOrpheusBpmEntryRoute(
                                    context,
                                    initialBpm: _bpm,
                                  );
                                  if (next == null || next == _bpm) return;
                                  setState(() => _bpm = next);
                                  setDialogState(() {});
                                  debugPrint(
                                      'Orpheus Deck: CLICK TRACK BPM $_bpm (numeric)');
                                  _saveSession();
                                  _syncNativeGuideClickToEngine(
                                    mode: 'dialog_bpm',
                                  );
                                },
                                child: Text(
                                  '$_bpm',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'monospace',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.white38,
                                  ),
                                ),
                              ),
                              OrpheusBpmStepButton(
                                icon: Icons.add,
                                delta: 1,
                                enabled: _bpm < kOrpheusBpmMax,
                                onStep: () {
                                  if (_bpm >= kOrpheusBpmMax) return;
                                  setState(() => _bpm++);
                                  setDialogState(() {});
                                  debugPrint(
                                      'Orpheus Deck: CLICK TRACK BPM $_bpm '
                                      'recording=$_isRecording playing=$_isPlaying');
                                  _saveSession();
                                  _syncNativeGuideClickToEngine(
                                    mode: 'dialog_bpm',
                                  );
                                },
                              ),
                            ])
                          ]),
                      const SizedBox(height: 16),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("SOUND",
                                style: TextStyle(
                                    color: Colors.white54,
                                    fontFamily: 'monospace')),
                            DropdownButton<String>(
                              value: _metronomeSound,
                              dropdownColor: Colors.black,
                              style: const TextStyle(
                                  color: Colors.white, fontFamily: 'monospace'),
                              underline:
                                  Container(height: 1, color: Colors.white54),
                              items: const [
                                DropdownMenuItem(
                                  value: 'WOOD',
                                  child: Text('Wood Block'),
                                ),
                                DropdownMenuItem(
                                  value: 'CLICK',
                                  child: Text('Click'),
                                ),
                                DropdownMenuItem(
                                  value: 'BEEP',
                                  child: Text('Beep'),
                                ),
                              ],
                              onChanged: (val) async {
                                if (val != null) {
                                  setState(() => _metronomeSound = val);
                                  setDialogState(() {});
                                  debugPrint(
                                      'Orpheus Deck: CLICK TRACK sound=$val bpm=$_bpm');
                                  _saveSession();
                                  _syncNativeGuideClickToEngine(
                                    mode: 'dialog_sound',
                                  );
                                }
                              },
                            )
                          ]),
                      if (_isNativeProject) ...[
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'COUNT-IN',
                              style: TextStyle(
                                color: Colors.white54,
                                fontFamily: 'monospace',
                              ),
                            ),
                            Row(
                              children: [
                                _clickCountInChip(
                                  label: 'OFF',
                                  selected: _clickCountInBeats == 0,
                                  onTap: () {
                                    setState(() => _clickCountInBeats = 0);
                                    setDialogState(() {});
                                    _saveSession();
                                  },
                                ),
                                const SizedBox(width: 8),
                                _clickCountInChip(
                                  label: '4 BEATS',
                                  selected: _clickCountInBeats == 4,
                                  onTap: () {
                                    setState(() => _clickCountInBeats = 4);
                                    setDialogState(() {});
                                    _saveSession();
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 12),
                      Text(
                        previewAllowed
                            ? 'LONG-PRESS ± FOR ±5 BPM'
                            : _isNativeProject
                                ? 'STOP PLAY/REC TO PREVIEW CLICK'
                                : 'PREVIEW CLICK: WAV PROJECTS ONLY',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontFamily: 'monospace',
                          fontSize: 9,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ]),
              ),
              actions: [
                TextButton(
                  onPressed: previewAllowed
                      ? () async {
                          try {
                            await OrpheusClickPreview.playNativeFourBeats(
                              bpm: _bpm,
                              clickVolume: _clickVolume,
                              metronomeSound: _metronomeSound,
                              transportBusy: _isRecording || _isPlaying,
                            );
                          } catch (_) {
                            if (mounted) {
                              _showSnackbar('ERR: CLICK PREVIEW FAILED');
                            }
                          }
                        }
                      : null,
                  child: Text(
                    'PREVIEW CLICK',
                    style: TextStyle(
                      color: previewAllowed ? Colors.white : Colors.white24,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("CLOSE",
                      style: TextStyle(
                          color: Colors.white54, fontFamily: 'monospace')),
                ),
              ],
            );
          });
        }).then((_) {
      unawaited(OrpheusClickPreview.stop());
    });
  }

  Future<void> _showViewProjectsDialog() async {
    if (!mounted) return;
    await showOrpheusViewProjectsDialog(
      context,
      currentProjectName: _projectName,
      isTransportBusy: _transportBusy,
      onToast: (msg) => showOrpheusOledToast(context, msg),
      onOpenProject: (name) async {
        await _stop();
        if (!mounted) return;
        if (await projectFolderIsLegacyUnsupported(name)) {
          if (mounted) {
            showOrpheusOledToast(context, kLegacyProjectUnsupportedMessage);
          }
          return;
        }
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => RecorderScreen(
              projectName: name,
              isNewProject: false,
            ),
          ),
        );
      },
      onRenameProject: _renameProjectFromList,
      onDeleteProject: _deleteProjectFromList,
    );
  }

  void _showProjectMenu() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.black,
            shape: Border.all(color: Colors.white, width: 2),
            title: const Text("PROJECT MGMT",
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _menuButton("RENAME PROJECT", () {
                    Navigator.pop(context);
                    if (_transportBusy()) {
                      showOrpheusOledToast(this.context, 'STOP PLAY/REC FIRST');
                      return;
                    }
                    unawaited(() async {
                      final existing = await listOrpheusDeckProjectNames();
                      if (!mounted) return;
                      final rawName = await showOrpheusProjectRenameRoute(
                        this.context,
                        initialName: _projectName,
                      );
                      if (!mounted || rawName == null) return;
                      final err = validateOrpheusProjectFolderName(
                        rawName,
                        existingNames: existing,
                        allowSameAs: _projectName,
                      );
                      if (err != null) {
                        _showSnackbar(err);
                        return;
                      }
                      await _renameProject(rawName);
                    }());
                  }),
                  const SizedBox(height: 8),
                  _menuButton("NEW PROJECT", () {
                    Navigator.pop(context);
                    if (_transportBusy()) {
                      showOrpheusOledToast(this.context, 'STOP PLAY/REC FIRST');
                      return;
                    }
                    unawaited(() async {
                      final existing = await listOrpheusDeckProjectNames();
                      if (!mounted) return;
                      final rawName = await showOrpheusNewProjectNameRoute(
                        this.context,
                      );
                      if (!mounted || rawName == null) return;
                      final err = validateOrpheusProjectFolderName(
                        rawName,
                        existingNames: existing,
                      );
                      if (err != null) {
                        _showSnackbar(err);
                        return;
                      }
                      await _newProject(rawName);
                    }());
                  }),
                  const SizedBox(height: 8),
                  _menuButton("VIEW PROJECTS", () {
                    Navigator.pop(context);
                    unawaited(_showViewProjectsDialog());
                  }),
                  const SizedBox(height: 8),
                  _menuButton(
                    'SAVE AS TEMPLATE',
                    () {
                      Navigator.pop(context);
                      if (_transportBusy()) {
                        showOrpheusOledToast(
                            this.context, 'STOP PLAY/REC FIRST');
                        return;
                      }
                      unawaited(
                        showOrpheusSaveProjectAsTemplateFlow(
                          this.context,
                          currentTrackDisplayNames:
                              List<String?>.from(_trackDisplayNames),
                          onToast: (msg) =>
                              showOrpheusOledToast(this.context, msg),
                        ),
                      );
                    },
                    proFeature: OrpheusProFeature.trackNameTemplates,
                  ),
                  const SizedBox(height: 8),
                  _menuButton("SETTINGS", () {
                    Navigator.pop(context);
                    showOrpheusDeckSettingsDialog(
                      this.context,
                      isTransportBusy: _transportBusy,
                      onGenerateDebugWavTracks: _isNativeProject
                          ? () => unawaited(_generateNativeTestTracks())
                          : null,
                    );
                  }),
                  const SizedBox(height: 8),
                  _menuButton(kOrpheusProMenuButtonLabel, () {
                    Navigator.pop(context);
                    showOrpheusProUserDialog(this.context);
                  }),
                  const SizedBox(height: 16),
                  Container(height: 1, color: Colors.white24),
                  const SizedBox(height: 16),
                  _menuButton("EXPORT PROJECT", () {
                    Navigator.pop(context);
                    _showExportDialog();
                  }),
                  const SizedBox(height: 16),
                  Container(height: 1, color: Colors.white24),
                  const SizedBox(height: 16),
                  _menuButton("EXPORT HISTORY", () async {
                    Navigator.pop(context);
                    await _showExportsBrowseDialog();
                  }),
                  const SizedBox(height: 24),
                  _menuButton("EXIT TO MENU", () {
                    _stop();
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/home');
                  }),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("CLOSE",
                    style: TextStyle(
                        color: Colors.white54, fontFamily: 'monospace')),
              ),
            ],
          );
        });
  }

  void _showExportDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.black,
          shape: Border.all(color: Colors.white, width: 2),
          title: const Text(
            'EXPORT PROJECT',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _exportDialogExplain(
                'Raw Mix exports tracks as-is • 44.1 kHz mono WAV',
              ),
              _menuButton('RAW MIX', () {
                Navigator.pop(dialogContext);
                _exportMix(false);
              }),
              const SizedBox(height: 12),
              _exportDialogExplain(
                'Master creates a louder share-ready version • '
                '-14 LUFS • -1 dBTP • LRA 11 • 44.1 kHz mono WAV',
              ),
              _menuButton('MASTER MIX', () {
                Navigator.pop(dialogContext);
                _exportMix(true);
              }),
              const SizedBox(height: 12),
              _exportDialogExplain(
                'Export All Tracks exports each track with audio '
                'as an individual 48 kHz mono WAV',
              ),
              _menuButton(
                'EXPORT ALL TRACKS',
                () {
                  Navigator.pop(dialogContext);
                  if (!requestOrpheusProFeature(
                    context,
                    OrpheusProFeature.exportAllTracks,
                  )) {
                    return;
                  }
                  unawaited(_exportAllTracksWav());
                },
                proFeature: OrpheusProFeature.exportAllTracks,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'CLOSE',
                style:
                    TextStyle(color: Colors.white54, fontFamily: 'monospace'),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _exportDialogExplain(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white54,
          fontFamily: 'monospace',
          fontSize: 10,
          height: 1.35,
        ),
      ),
    );
  }

  Widget _menuButton(
    String text,
    VoidCallback onTap, {
    OrpheusProFeature? proFeature,
  }) {
    final locked =
        proFeature != null && orpheusProFeatureButtonLocked(proFeature);
    final borderColor = locked ? Colors.white38 : Colors.white54;
    final textColor = locked ? Colors.white38 : Colors.white;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showSnackbar(String message) {
    showOrpheusOledToast(context, message);
  }

  String _trackTitle(int index) => orpheusTrackTitle(index, _trackDisplayNames);

  void _openTrackFx(int trackIndex) {
    if (!requestOrpheusTrackFxPreview(context)) {
      return;
    }
    openOrpheusFxPlayerScreen(
      context,
      trackLabel: _trackTitle(trackIndex),
      trackIndex: trackIndex,
      tapeTransportMs: _playbackMs,
      deckStatusLabel: _deckStatus,
      clickEnabled: _metronomeOn,
      bpm: _bpm,
      transportActive: _isPlaying || _isRecording,
    );
  }

  String _trackExportSlug(int index) =>
      orpheusTrackExportSlug(index, _trackDisplayNames);

  Future<void> _beginRenameTrack(int trackIndex) async {
    if (_transportBusy()) {
      _showSnackbar('STOP PLAY/REC FIRST');
      return;
    }
    final raw = await showOrpheusTrackRenameRoute(
      context,
      initialName: _trackTitle(trackIndex),
    );
    if (!mounted || raw == null) {
      return;
    }
    setState(() {
      _trackDisplayNames[trackIndex] = orpheusSanitizeTrackDisplayName(raw);
    });
    await _saveSession();
    if (mounted) {
      _showSnackbar('TRACK RENAMED');
    }
  }

  String _trackImportTimestamp() =>
      DateTime.now().millisecondsSinceEpoch.toString();

  Future<void> _deleteImportPickerCacheIfSafe(String path) async {
    final normalized = path.replaceAll('\\', '/');
    if (!normalized.contains('/import_wav_picker/')) return;
    await _deleteExportIfExists(path);
  }

  Future<Directory> _currentProjectDirectory() async =>
      orpheusProjectDirectory(_projectName);

  String _importSourceExtension(String? displayName, String path) {
    final name = (displayName == null || displayName.trim().isEmpty)
        ? path.split(RegExp(r'[/\\]')).last
        : displayName.trim();
    final dot = name.lastIndexOf('.');
    if (dot < 0 || dot == name.length - 1) return '';
    return name.substring(dot + 1).toLowerCase();
  }

  bool _mimeLooksLikeWav(String? mimeType) {
    final mime = mimeType?.trim().toLowerCase();
    return mime == 'audio/wav' ||
        mime == 'audio/x-wav' ||
        mime == 'audio/wave' ||
        mime == 'audio/vnd.wave';
  }

  Future<({String hex, String ascii, bool riffWave})> _readImportFirst12Bytes(
    String path,
  ) async {
    final file = File(path);
    final raf = await file.open(mode: FileMode.read);
    try {
      final bytes = await raf.read(12);
      final hex =
          bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ');
      final ascii = bytes
          .map((b) => b >= 32 && b <= 126 ? String.fromCharCode(b) : '.')
          .join();
      final riffWave = bytes.length >= 12 &&
          String.fromCharCodes(bytes.sublist(0, 4)) == 'RIFF' &&
          String.fromCharCodes(bytes.sublist(8, 12)) == 'WAVE';
      return (hex: hex, ascii: ascii, riffWave: riffWave);
    } finally {
      await raf.close();
    }
  }

  String _importFfmpegLogSummary(String logText) {
    final cleaned = logText
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .take(12)
        .join(' | ');
    if (cleaned.length <= 1600) return cleaned;
    return cleaned.substring(0, 1600);
  }

  bool _ffmpegLogLooksLikeUnsupportedWav(String logText) {
    final lower = logText.toLowerCase();
    return lower.contains('invalid data found') ||
        lower.contains('could not find codec') ||
        lower.contains('unknown format') ||
        lower.contains('invalid wav') ||
        lower.contains('not a wave') ||
        lower.contains('no such file or directory');
  }

  void _recordImportDiagnostics(List<String> lines) {
    final text = lines.join('\n');
    OrpheusImportWavDiagnosticsStore.instance.record(text);
    debugPrint(text);
  }

  Future<OrpheusWavImportPlacement?> _showWavImportPlacementDialog(
    int trackIndex,
  ) async {
    return showDialog<OrpheusWavImportPlacement>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.black,
          shape: Border.all(color: Colors.white, width: 2),
          title: const Text(
            'IMPORT WAV',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'TRACK: ${_trackTitle(trackIndex)}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontFamily: 'monospace',
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'IF RECENT IS EMPTY, TAP THIS WEEK OR BROWSE TO LOCATE YOUR WAV.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white38,
                  fontFamily: 'monospace',
                  fontSize: 9,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'PLACE AT:',
                style: TextStyle(
                  color: Colors.white54,
                  fontFamily: 'monospace',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _menuButton('00:00', () {
                Navigator.pop(dialogContext, OrpheusWavImportPlacement.zero);
              }),
              const SizedBox(height: 8),
              _menuButton('CURRENT TIME ${_tapeClockMmSs(_playbackMs)}', () {
                Navigator.pop(dialogContext, OrpheusWavImportPlacement.current);
              }),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'CLOSE',
                style:
                    TextStyle(color: Colors.white54, fontFamily: 'monospace'),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<_PickedImportWav?> _pickWavFileForImport() async {
    if (!Platform.isAndroid) {
      _showSnackbar('IMPORT WAV ANDROID ONLY');
      return null;
    }
    final raw = await _androidExportChannel.invokeMethod<dynamic>(
      'pickImportWav',
    );
    if (raw == null) return null;
    if (raw is String) return _PickedImportWav(path: raw);
    if (raw is Map) {
      final path = raw['path']?.toString();
      if (path == null || path.isEmpty) return null;
      return _PickedImportWav(
        path: path,
        displayName: raw['displayName']?.toString(),
        mimeType: raw['mimeType']?.toString(),
        uri: raw['uri']?.toString(),
      );
    }
    return null;
  }

  Future<_ImportedProjectWav> _copyOrConvertWavIntoProject({
    required String sourcePath,
    required String? sourceName,
    required String? sourceMimeType,
    required String? sourceUri,
    required int trackIndex,
    required int placementStartMs,
  }) async {
    const int tapeFitToleranceMs = 250;
    final diagnostics = <String>[
      'Orpheus IMPORT_WAV',
      'track=$trackIndex',
      'sourceName=${sourceName ?? "<unknown>"}',
      'sourceMimeType=${sourceMimeType ?? "<unknown>"}',
      'sourceUri=${sourceUri ?? "<none>"}',
      'sourcePath=$sourcePath',
      'placementStartMs=$placementStartMs',
    ];

    final sourceFile = File(sourcePath);
    final sourceExists = await sourceFile.exists();
    final int sourceBytes = sourceExists ? await sourceFile.length() : 0;
    final extension = _importSourceExtension(sourceName, sourcePath);
    ({String hex, String ascii, bool riffWave}) first12 =
        (hex: '<unread>', ascii: '<unread>', riffWave: false);
    if (sourceExists && sourceBytes >= 12) {
      try {
        first12 = await _readImportFirst12Bytes(sourcePath);
      } catch (e) {
        diagnostics.add('first12ReadError=$e');
      }
    }
    final bool mimeWav = _mimeLooksLikeWav(sourceMimeType);
    final bool nameWav = extension == 'wav';
    final sourceRegion = parseWavPcmDataRegion(sourcePath);
    final sourceChunkIds = sourceRegion?.chunkIds ?? const <String>[];
    final metadataChunks = sourceChunkIds
        .where((id) => id != 'fmt ' && id != 'data')
        .toList(growable: false);
    final bool acceptedSourceHint =
        mimeWav || nameWav || first12.riffWave || sourceRegion != null;
    diagnostics.addAll([
      'sourceExists=$sourceExists',
      'sourceBytes=$sourceBytes',
      'sourceExtension=$extension',
      'first12Hex=${first12.hex}',
      'first12Ascii=${first12.ascii}',
      'riffWave=${first12.riffWave}',
      'mimeLooksWav=$mimeWav',
      'nameLooksWav=$nameWav',
      'sourceProbe=skipped_permissive',
      'sourceHeaderParsed=${sourceRegion != null}',
      'sourceSampleRate=${sourceRegion?.sampleRate ?? "<unknown>"}',
      'sourceChannels=${sourceRegion?.channels ?? "<unknown>"}',
      'sourceBitsPerSample=${sourceRegion?.bitsPerSample ?? "<unknown>"}',
      'sourceAudioFormat=${sourceRegion?.audioFormat ?? "<unknown>"}',
      'sourceChunkIds=${sourceChunkIds.isEmpty ? "<unknown>" : sourceChunkIds.join(",")}',
      'sourceMetadataChunks=${metadataChunks.isEmpty ? "none" : metadataChunks.join(",")}',
      'ffmpegConversionUsed=true',
    ]);

    if (!sourceExists || sourceBytes <= 0) {
      diagnostics.add('failureReason=could_not_read_source');
      _recordImportDiagnostics(diagnostics);
      throw const _WavImportFailure(
        'IMPORT FAILED - COULD NOT READ FILE',
        'could_not_read_source',
      );
    }
    if (sourceBytes < 44) {
      diagnostics.add('failureReason=source_too_small_for_wav');
      _recordImportDiagnostics(diagnostics);
      throw const _WavImportFailure(
        'IMPORT FAILED - WAV NOT SUPPORTED',
        'source_too_small_for_wav',
      );
    }
    if (!acceptedSourceHint) {
      diagnostics.add('failureReason=source_not_wav_like');
      _recordImportDiagnostics(diagnostics);
      throw const _WavImportFailure(
        'IMPORT FAILED - WAV NOT SUPPORTED',
        'source_not_wav_like',
      );
    }

    final projDir = await _currentProjectDirectory();
    final outPath =
        '${projDir.path}/track_${trackIndex}_import_${_trackImportTimestamp()}.wav';
    final command = <String>[
      '-y',
      '-i',
      sourcePath,
      '-vn',
      '-sn',
      '-dn',
      '-map_metadata',
      '-1',
      '-ac',
      '1',
      '-ar',
      '$kOrpheusRecorderSampleRate',
      '-c:a',
      'pcm_s16le',
      '-f',
      'wav',
      outPath,
    ];
    final commandText =
        command.map((a) => a.contains(' ') ? '"$a"' : a).join(' ');
    diagnostics.add('ffmpegCommand=$commandText');
    final session = await orpheusFfmpegExecuteWithArguments(command);
    final returnCode = await session.getReturnCode();
    final rcVal = returnCode?.getValue();
    final logText = await session.getLogsAsString();
    diagnostics.add('ffmpegReturnCode=$rcVal');
    if (logText.isNotEmpty) {
      diagnostics.add('ffmpegLogSummary=${_importFfmpegLogSummary(logText)}');
    }
    if (!ReturnCode.isSuccess(returnCode)) {
      await _deleteExportIfExists(outPath);
      final unsupported = _ffmpegLogLooksLikeUnsupportedWav(logText);
      diagnostics.add(
        'failureReason=${unsupported ? "ffmpeg_could_not_decode" : "ffmpeg_convert_failed"}',
      );
      _recordImportDiagnostics(diagnostics);
      throw _WavImportFailure(
        unsupported
            ? 'IMPORT FAILED - WAV NOT SUPPORTED'
            : 'IMPORT FAILED - CONVERSION ERROR',
        unsupported ? 'ffmpeg_could_not_decode' : 'ffmpeg_convert_failed',
      );
    }

    final probe = probeNativeDeckWav(outPath);
    final outFile = File(outPath);
    final outBytes = await outFile.exists() ? await outFile.length() : 0;
    diagnostics.addAll([
      'outputPath=$outPath',
      'outputBytes=$outBytes',
      'outputValidationOk=${probe.ok}',
      'outputValidationReason=${probe.reason}',
      'outputSampleRate=${probe.sampleRate}',
      'outputChannels=${probe.channels}',
      'outputBits=${probe.bitsPerSample}',
      'outputFrames=${probe.frameCount}',
      'outputDurationMs=${probe.durationMs}',
    ]);
    if (!probe.ok) {
      await _deleteExportIfExists(outPath);
      diagnostics.add('failureReason=normalized_wav_invalid');
      _recordImportDiagnostics(diagnostics);
      throw const _WavImportFailure(
        'IMPORT FAILED - CONVERSION ERROR',
        'normalized_wav_invalid',
      );
    }
    if (probe.durationMs > tapeLengthMs + tapeFitToleranceMs) {
      await _deleteExportIfExists(outPath);
      diagnostics.add(
        'tapeFit=false reason=output_duration_exceeds_tape '
        'tapeLengthMs=$tapeLengthMs toleranceMs=$tapeFitToleranceMs',
      );
      diagnostics.add('failureReason=output_duration_exceeds_tape');
      _recordImportDiagnostics(diagnostics);
      throw const _WavImportFailure(
        'WAV TOO LONG FOR TAPE',
        'output_duration_exceeds_tape',
      );
    }
    if (placementStartMs + probe.durationMs >
        tapeLengthMs + tapeFitToleranceMs) {
      await _deleteExportIfExists(outPath);
      diagnostics.add(
        'tapeFit=false reason=output_duration_exceeds_remaining_tape '
        'tapeLengthMs=$tapeLengthMs toleranceMs=$tapeFitToleranceMs',
      );
      diagnostics.add('failureReason=output_duration_exceeds_remaining_tape');
      _recordImportDiagnostics(diagnostics);
      throw const _WavImportFailure(
        'WAV DOES NOT FIT AT CURRENT TIME',
        'output_duration_exceeds_remaining_tape',
      );
    }
    diagnostics.add(
      'tapeFit=true tapeLengthMs=$tapeLengthMs toleranceMs=$tapeFitToleranceMs',
    );

    final waveformResult = await waveformForSavedNativeWav(
      path: outPath,
      fallbackDurationMs: probe.durationMs,
    );
    diagnostics
        .add('result=success waveformBuckets=${waveformResult.bucketCount}');
    _recordImportDiagnostics(diagnostics);
    return _ImportedProjectWav(
      path: outPath,
      waveform: waveformResult.amplitudes,
      durationMs: probe.durationMs,
      converted: true,
    );
  }

  Future<void> _beginImportWavToTrack(int trackIndex) async {
    if (_transportBusy()) {
      _showSnackbar('STOP PLAY/REC FIRST');
      return;
    }
    if (!_isNativeProject) {
      _showSnackbar('IMPORT: ANDROID WAV PROJECTS ONLY');
      return;
    }

    final placement = await _showWavImportPlacementDialog(trackIndex);
    if (placement == null || !mounted) return;

    final picked = await _pickWavFileForImport();
    if (picked == null || !mounted) return;
    final sourcePath = picked.path;

    _showSnackbar('IMPORTING WAV...');
    try {
      final int tapeStartMs = placement == OrpheusWavImportPlacement.current
          ? _playbackMs.clamp(0, tapeLengthMs)
          : 0;
      final imported = await _copyOrConvertWavIntoProject(
        sourcePath: sourcePath,
        sourceName: picked.displayName,
        sourceMimeType: picked.mimeType,
        sourceUri: picked.uri,
        trackIndex: trackIndex,
        placementStartMs: tapeStartMs,
      );
      if (!mounted) return;
      final int tapeStartSamples = orpheusSessionMsToSamples(tapeStartMs);
      final probe = probeNativeDeckWav(imported.path);
      if (!probe.ok) {
        await _deleteExportIfExists(imported.path);
        _showSnackbar('IMPORT FAILED - CONVERSION ERROR');
        return;
      }

      final importedClip = buildImportedTrackClip(
        id: 'import_${trackIndex}_${_trackImportTimestamp()}',
        filePath: imported.path,
        tapeStartSamples: tapeStartSamples,
        lengthSamples: probe.frameCount,
        createdAt: DateTime.now().toUtc(),
      );
      final overwrite = tapeIntervalFromClip(importedClip);
      var splitSeq = 0;
      final commitResult = commitClipWithOverwrite(
        lane: _clipsForLane(trackIndex),
        newClip: importedClip,
        overwrite: overwrite,
        newClipId: () => 'split_import_${trackIndex}_${splitSeq++}',
      );
      if (!commitResult.ok) {
        await _deleteExportIfExists(imported.path);
        _recordImportDiagnostics([
          'Orpheus PRO-I1: IMPORT_COMMIT_REJECTED track=$trackIndex '
              '${overwriteCommitFailureDebugDetail(
            failure: commitResult.failure!,
            newClip: importedClip,
            overwrite: overwrite,
            laneClipCount: _clipsForLane(trackIndex).length,
            outputPath: imported.path,
            probeFrameCount: probe.frameCount,
          )}',
        ]);
        _showSnackbar(
          overwriteClipFailureUserMessage(
            commitResult.failure!,
            isImport: true,
          ),
        );
        return;
      }

      setState(() {
        _lastUndo.clear();
        _trackClips[trackIndex] =
            List<OrpheusTrackClip>.from(commitResult.clips!);
        _waveformCache[imported.path] = imported.waveform;
        _syncLegacyMirrorForLane(trackIndex);
        _armedTracks[trackIndex] = false;
      });
      await _saveSession();
      debugPrint(
        'Orpheus PRO-I1: IMPORT_OK track=$trackIndex '
        'placementMs=$tapeStartMs placementSamples=$tapeStartSamples '
        'durationMs=${imported.durationMs} converted=${imported.converted} '
        'path=${imported.path}',
      );
      _showSnackbar(
        imported.converted ? 'WAV IMPORTED + CONVERTED' : 'WAV IMPORTED',
      );
    } catch (e, st) {
      debugPrint('Orpheus IMPORT_WAV: FAILED track=$trackIndex $e\n$st');
      if (mounted) {
        final message = e is _WavImportFailure
            ? e.userMessage
            : e is OrpheusFfmpegUnavailableException
                ? orpheusFfmpegUnavailableUserMessage(e.reason)
                : 'IMPORT FAILED - COULD NOT READ FILE';
        _showSnackbar(message);
      }
    } finally {
      await _deleteImportPickerCacheIfSafe(sourcePath);
    }
  }

  Future<void> _exportTrackWav(int trackIndex) async {
    if (_transportBusy()) {
      _showSnackbar('STOP PLAY/REC FIRST');
      return;
    }

    final laneClips = validatedLaneExportClips(
      laneClips: clipsForLane(_sessionExportClips(), trackIndex),
      fileExists: (path) => File(path).existsSync(),
      fileByteLength: (path) => File(path).lengthSync(),
    );
    if (laneClips.isEmpty) {
      _showSnackbar('NO TRACK WAV');
      return;
    }

    try {
      final entry = await _exportTrackWavInternal(trackIndex);
      if (!mounted) return;
      if (entry == null) {
        _showSnackbar(Platform.isAndroid
            ? 'ERR: SAVE TO MUSIC FAILED (ANDROID 10+)'
            : 'ERR: TRACK EXPORT FAILED');
        return;
      }
      setState(() {
        _exports.add(entry);
      });
      await _saveSession();
      _showExportSuccessDialog(entry: entry);
    } catch (e, st) {
      debugPrint(
        'Orpheus PRO-I1: TRACK_EXPORT_FAILED track=$trackIndex $e\n$st',
      );
      if (mounted) {
        _showSnackbar('ERR: TRACK EXPORT FAILED');
      }
    }
  }

  /// One lane → export folder; reuses TC-F bounce/copy. No UI side effects.
  Future<ExportEntry?> _exportTrackWavInternal(int trackIndex) async {
    final laneClips = validatedLaneExportClips(
      laneClips: clipsForLane(_sessionExportClips(), trackIndex),
      fileExists: (path) => File(path).existsSync(),
      fileByteLength: (path) => File(path).lengthSync(),
    );
    if (laneClips.isEmpty) {
      return null;
    }

    final projDir = await _currentProjectDirectory();
    final fileName = orpheusTrackWavExportFileName(
      projectName: _projectName,
      trackIndex: trackIndex,
      displayNames: _trackDisplayNames,
      timestamp: _exportFileTimestamp(),
    );
    final tempPath =
        '${projDir.path}/export_${_trackExportSlug(trackIndex)}_${_trackImportTimestamp()}.wav';

    if (canFastCopyTrackExport(laneClips)) {
      final sourcePath = laneClips.single.filePath;
      final probe = probeNativeDeckWav(sourcePath);
      if (!probe.ok) {
        return null;
      }
      await File(sourcePath).copy(tempPath);
      debugPrint(
        'Orpheus TC-F: TRACK_EXPORT_COPY track=$trackIndex path=$sourcePath',
      );
    } else {
      final bounced = await _bounceTrackWavExport(
        laneClips: laneClips,
        tempPath: tempPath,
        trackIndex: trackIndex,
      );
      if (!bounced) {
        return null;
      }
    }

    return _finalizeExportAfterFfmpeg(
      tempPath: tempPath,
      fileName: fileName,
      kind: 'TRACK WAV',
    );
  }

  Future<void> _exportAllTracksWav() async {
    if (_transportBusy()) {
      _showSnackbar('STOP PLAY/REC FIRST');
      return;
    }

    final lanes = laneIndicesWithExportableAudio(
      allSessionClips: _sessionExportClips(),
      fileExists: (path) => File(path).existsSync(),
      fileByteLength: (path) => File(path).lengthSync(),
    );
    if (lanes.isEmpty) {
      _showSnackbar('NO TRACKS TO EXPORT');
      return;
    }

    final newEntries = <ExportEntry>[];
    var anyFailed = false;
    for (final lane in lanes) {
      try {
        final entry = await _exportTrackWavInternal(lane);
        if (entry == null) {
          anyFailed = true;
          debugPrint('Orpheus PRO-B: EXPORT_ALL lane=$lane failed');
          continue;
        }
        newEntries.add(entry);
      } catch (e, st) {
        anyFailed = true;
        debugPrint('Orpheus PRO-B: EXPORT_ALL lane=$lane error $e\n$st');
      }
    }

    if (!mounted) return;
    if (newEntries.isEmpty) {
      _showSnackbar('ERR: EXPORT ALL FAILED');
      return;
    }

    setState(() {
      _exports.addAll(newEntries);
    });
    await _saveSession();

    if (anyFailed) {
      _showSnackbar('EXPORTED ${newEntries.length} TRACKS · SOME FAILED');
    }
    _showExportAllTracksSuccessDialog(entries: newEntries);
  }

  void _showExportAllTracksSuccessDialog({
    required List<ExportEntry> entries,
  }) {
    if (entries.isEmpty) return;
    final primary = entries.first;
    final paths = entries.map((e) => e.displayPath).join('\n');
    showDialog(
      context: context,
      builder: (context) {
        final body =
            'Saved ${entries.length} track(s):\n$paths\n\nKind: TRACK WAV\n';
        return AlertDialog(
          backgroundColor: Colors.black,
          shape: Border.all(color: Colors.white, width: 2),
          title: const Text(
            'EXPORT COMPLETE',
            style: TextStyle(color: Colors.white, fontFamily: 'monospace'),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SelectableText(
                body,
                style: const TextStyle(
                  color: Colors.white54,
                  fontFamily: 'monospace',
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'EXPORT USES CURRENT MIXER STATE',
                style: TextStyle(
                  color: Colors.white38,
                  fontFamily: 'monospace',
                  fontSize: 9,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (!_exportShareLooksValid(primary)) {
                  _showSnackbar('ERR: EXPORT FILE INVALID');
                  return;
                }
                await _shareExportEntry(primary);
              },
              child: const Text(
                'SHARE',
                style: TextStyle(color: Colors.white, fontFamily: 'monospace'),
              ),
            ),
            TextButton(
              onPressed: () async {
                await _tryOpenExportLocation(primary);
              },
              child: const Text(
                'OPEN EXPORT LOCATION',
                style: TextStyle(
                  color: Colors.white70,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _bounceTrackWavExport({
    required List<OrpheusExportClip> laneClips,
    required String tempPath,
    required int trackIndex,
  }) async {
    const outPad = '[track_out]';
    final filterGraph = buildLaneTrackExportFilterGraph(
      laneClips: laneClips,
      outputPad: outPad,
    );
    final inputs = <String>[];
    for (final clip in laneClips) {
      inputs.add('-i');
      inputs.add(clip.filePath);
    }
    final command = <String>[
      ...inputs,
      '-filter_complex',
      filterGraph,
      '-map',
      outPad,
      '-vn',
      '-sn',
      '-dn',
      '-map_metadata',
      '-1',
      '-acodec',
      'pcm_s16le',
      '-ar',
      '$kOrpheusRecorderSampleRate',
      '-ac',
      '1',
      '-f',
      'wav',
      '-y',
      tempPath,
    ];
    debugPrint(
      'Orpheus TC-F: TRACK_EXPORT_BOUNCE track=$trackIndex '
      'clipCount=${laneClips.length} filter=$filterGraph',
    );
    final session = await orpheusFfmpegExecuteWithArguments(command);
    final returnCode = await session.getReturnCode();
    if (!ReturnCode.isSuccess(returnCode)) {
      await _deleteExportIfExists(tempPath);
      return false;
    }
    final ver = await _verifyExportedWav(tempPath);
    if (!ver.ok) {
      await _deleteExportIfExists(tempPath);
      return false;
    }
    return true;
  }

  void _showTrackOptions(int trackIndex) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.black,
          shape: Border.all(color: Colors.white, width: 2),
          title: const Text(
            'TRACK OPTIONS',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _trackTitle(trackIndex),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'monospace',
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _menuButton('RENAME TRACK', () {
                Navigator.pop(dialogContext);
                unawaited(_beginRenameTrack(trackIndex));
              }),
              const SizedBox(height: 8),
              _menuButton('EXPORT TRACK WAV', () {
                Navigator.pop(dialogContext);
                unawaited(_exportTrackWav(trackIndex));
              }),
              const SizedBox(height: 8),
              _menuButton(
                'EXPORT ALL TRACKS',
                () {
                  Navigator.pop(dialogContext);
                  if (!requestOrpheusProFeature(
                    context,
                    OrpheusProFeature.exportAllTracks,
                  )) {
                    return;
                  }
                  unawaited(_exportAllTracksWav());
                },
                proFeature: OrpheusProFeature.exportAllTracks,
              ),
              const SizedBox(height: 8),
              _menuButton(
                'IMPORT WAV',
                () {
                  Navigator.pop(dialogContext);
                  if (!requestOrpheusProFeature(
                    context,
                    OrpheusProFeature.importWav,
                  )) {
                    return;
                  }
                  unawaited(_beginImportWavToTrack(trackIndex));
                },
                proFeature: OrpheusProFeature.importWav,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'CLOSE',
                style:
                    TextStyle(color: Colors.white54, fontFamily: 'monospace'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _saveMixerUndo() {
    _lastUndo.clear();
    _lastUndo.action = UndoAction.mixer;
    _lastUndo.volumes = List.from(_trackVolumes);
    _lastUndo.mutes = List.from(_trackMutes);
    _lastUndo.solos = List.from(_trackSolos);
    setState(() {});
  }

  void _onVolumeChangeStart(int index, double value) {
    _saveMixerUndo();
  }

  void _updateMixerState() {
    if (_nativePlaybackActive || _nativeRecordingActive) {
      _nativeOboeEngine?.applyMixerState(
        volumes: _trackVolumes,
        mutes: _trackMutes,
        solos: _trackSolos,
      );
    }
  }

  void _setVolume(int index, double value) {
    setState(() {
      _trackVolumes[index] = value;
    });
    _updateMixerState();
    _saveSession();
  }

  void _toggleMute(int index) {
    _saveMixerUndo();
    setState(() {
      _trackMutes[index] = !_trackMutes[index];
    });
    _updateMixerState();
    _saveSession();
  }

  void _toggleSolo(int index) {
    _saveMixerUndo();
    setState(() {
      _trackSolos[index] = !_trackSolos[index];
    });
    _updateMixerState();
    _saveSession();
  }

  void _startTicker() {
    _tickerTimer?.cancel();
    _tickerTimer = Timer.periodic(const Duration(milliseconds: 50), (Timer t) {
      if (_nativeRecordingActive && _isRecording) {
        _pollNativeRecordingTransport(t);
        return;
      }
      if (_nativePlaybackActive && _isPlaying) {
        _pollNativePlaybackTransport(t);
        return;
      }
    });
  }

  bool get _isOverdubbing {
    if (!_isRecording) return false;
    return _trackFiles.any((file) => file != null);
  }

  String get _deckStatus {
    if (_isExporting) return "EXPORTING";
    if (_isRecording) {
      return _isOverdubbing ? "OVERDUB" : "RECORDING";
    } else if (_isPlaying) {
      return "PLAYBACK";
    }
    return "IDLE";
  }

  String _recorderEngineSubtitleLine() =>
      formatRecorderEngineSubtitleLine(_projectAudioEngine);

  bool _shouldAttemptNativeRecording() =>
      Platform.isAndroid &&
      _isNativeProject &&
      projectNonNullTracksAreWav(_trackFiles);

  bool _shouldAttemptNativePlayback() =>
      Platform.isAndroid &&
      _isNativeProject &&
      projectNonNullTracksAreWav(_trackFiles) &&
      projectHasAtLeastOneWavTrack(_trackFiles);

  Future<bool> _tryStartNativeRecording({
    required int armedIndex,
    required int recordTapeStartMs,
  }) async {
    try {
      try {
        OrpheusNativeBindings.instance;
        orpheusReleaseLog('native library ready for record');
      } catch (e, st) {
        orpheusReleaseLogError('native library load before record', e, st);
        rethrow;
      }

      int backingOnDisk = 0;
      for (int i = 0; i < 4; i++) {
        if (i == armedIndex) continue;
        final p = _trackFiles[i];
        if (p != null &&
            !_isMetronomeClickAssetPath(p) &&
            p.toLowerCase().endsWith('.wav')) {
          backingOnDisk++;
        }
      }
      debugPrint(
        'Orpheus NATIVE_REC_REGRESSION: REC_START_PREP '
        'armedTrack=$armedIndex recordStartMs=$recordTapeStartMs '
        'clickEnabled=$_metronomeOn clickVolume=$_clickVolume bpm=$_bpm '
        'nativeRecording=$_nativeRecordingActive '
        'backingOnDisk=$backingOnDisk playbackMs=$_playbackMs',
      );

      if (_nativePlaybackActive) {
        await _stopNativePlaybackOnly();
      }

      final projDir = await orpheusProjectDirectory(_projectName);
      final shortTimestamp =
          (DateTime.now().millisecondsSinceEpoch % 10000000).toString();
      final wavPath = '${projDir.path}/track_${armedIndex}_$shortTimestamp.wav';

      _nativeOboeEngine ??= NativeOboeRecorderEngine();
      final int startSample = orpheusMsToNativeSamples(recordTapeStartMs);
      final int latencyOffset =
          OrpheusSettings.instance.effectiveRecordLatencyOffsetSamples;

      _nativeRecordTakeCounter++;
      final int takeId = _nativeRecordTakeCounter;
      _nativeRecordTakePending = NativeRecordTakeSnapshot(
        takeId: takeId,
        armedTrack: armedIndex,
        recordStartMs: recordTapeStartMs,
        recordStartSample: startSample,
        outputPath: wavPath,
        recordLatencyOffsetSamples: latencyOffset,
      );

      final micRoute = await OrpheusMicRouteResolver.resolveForRecording(
        OrpheusSettings.instance.micSource,
      );
      debugPrint(
        'Orpheus MIC_SOURCE: setting=${micRoute.micSourceSetting} '
        'requested=${micRoute.requestedMicSource} '
        'requestedDeviceId=${micRoute.requestedInputDeviceId} '
        'requestedDeviceType=${micRoute.requestedInputDeviceType} '
        'selectedDeviceId=${micRoute.selectedInputDeviceId} '
        'selectedDeviceType=${micRoute.selectedInputDeviceType} '
        'fallback=${micRoute.fallbackReason} '
        'protectionMode=${micRoute.inputProtectionMode}',
      );
      if (mounted && micRoute.shouldShowToast) {
        showOrpheusOledToast(context, micRoute.toastMessage!);
      }

      await _nativeOboeEngine!.startNativeProjectRecording(
        armedTrack: armedIndex,
        startSample: startSample,
        outputPath: wavPath,
        defaultRecordLatencyOffsetSamples: latencyOffset,
        micRoute: micRoute,
        trackPaths: _trackFiles,
        trackClips: _trackClips,
        trackTapeStartMs: _trackTapeStartMs,
        trackTapeStartSamples: _trackTapeStartSamples,
        recordLatencyOffsetMs: const [0, 0, 0, 0],
        recordLatencyOffsetSamples: _recordLatencyOffsetSamples,
        preferSampleTiming: true,
        volumes: _trackVolumes,
        mutes: _trackMutes,
        solos: _trackSolos,
        guideClickEnabled: _metronomeOn,
        guideClickBpm: _bpm,
        guideClickVolume: _clickVolume,
        guideClickSound: _metronomeSound,
        countInBeats: _isNativeProject ? _clickCountInBeats : 0,
      );

      if (!mounted) return false;
      _activeRecordTapeStartMs = recordTapeStartMs;
      setState(() {
        _isRecording = true;
        _nativeRecordingActive = true;
        _nativeRecordingFinalized = false;
        _nativeCountInActive = _clickCountInBeats == 4;
        _countInBeatsRemaining = _clickCountInBeats == 4 ? 4 : 0;
        _applyTapeHeadClamped(recordTapeStartMs);
      });
      _startTicker();
      debugPrint(
        'Orpheus NATIVE_REC_SAVE: REC_START takeId=$takeId '
        'armedTrack=$armedIndex recordStartMs=$recordTapeStartMs '
        'recordStartSample=$startSample outputPath=$wavPath '
        'recordLatencyOffsetSamples=$latencyOffset '
        'effectiveRecordStartSample=${startSample - latencyOffset}',
      );
      return true;
    } catch (e, st) {
      debugPrint('Orpheus NATIVE_REC_SAVE: REC_START_FAILED $e\n$st');
      _nativeRecordTakePending = null;
      await _nativeOboeEngine?.stopN3cSession();
      _nativeRecordingActive = false;
      if (mounted) {
        _showSnackbar('ERR: RECORD FAILED');
      }
      return false;
    }
  }

  Future<void> _stopNativePlaybackOnly() async {
    if (_nativeOboeEngine != null) {
      await _nativeOboeEngine!.stopN3dSession();
    }
    _nativePlaybackActive = false;
  }

  void _pollNativeRecordingTransport(Timer t) {
    final engine = _nativeOboeEngine;
    if (engine == null || !engine.n3cSessionOpen) {
      return;
    }
    final countIn = engine.readCountInDiagnostics();
    if (countIn.isCounting) {
      final int holdMs = orpheusNativeSamplesToMs(countIn.recordStartSample);
      setState(() {
        _nativeCountInActive = true;
        _countInBeatsRemaining = countIn.beatsRemaining;
        _applyTapeHeadClamped(holdMs);
      });
      if (t.tick % 10 == 0) {
        debugPrint(
          'Orpheus NATIVE_COUNT_IN: state=counting beatsRemaining='
          '${countIn.beatsRemaining} countInSamples=${countIn.countInSamples} '
          'recordStartSample=${countIn.recordStartSample}',
        );
      }
      return;
    }
    if (_nativeCountInActive) {
      setState(() {
        _nativeCountInActive = false;
        _countInBeatsRemaining = 0;
      });
      debugPrint('Orpheus NATIVE_COUNT_IN: state=recording');
    }
    final int sample = engine.currentTransportSample;
    final int ms = orpheusNativeSamplesToMs(sample);
    final int maxMs = _tapeTransportMaxMs();
    final int clampedMs = ms.clamp(0, maxMs);
    if (engine.isRecordTransportAtTapeEnd || clampedMs >= maxMs) {
      setState(() => _applyTapeHeadClamped(clampedMs));
      scheduleMicrotask(() async {
        await _stop(transportStopReason: 'TAPE_END');
      });
      return;
    }
    setState(() => _applyTapeHeadClamped(clampedMs));
  }

  void _pollNativePlaybackTransport(Timer t) {
    final engine = _nativeOboeEngine;
    if (engine == null || !engine.sessionOpen) {
      return;
    }
    final int sample = engine.currentTransportSample;
    final int ms = orpheusNativeSamplesToMs(sample);
    final int maxMs = _tapeTransportMaxMs();
    final int clampedMs = ms.clamp(0, maxMs);
    if (engine.isPlaybackComplete || clampedMs >= maxMs) {
      setState(() => _applyTapeHeadClamped(clampedMs));
      scheduleMicrotask(() async {
        await _stop(
          transportStopReason: engine.isPlaybackComplete
              ? 'NATIVE_PLAYBACK_COMPLETE'
              : 'TAPE_END',
        );
      });
      return;
    }
    setState(() => _applyTapeHeadClamped(clampedMs));
  }

  Future<bool> _tryStartNativePlayback() async {
    final int startMs = _playbackMs.clamp(0, tapeLengthMs);
    final int startSample = orpheusMsToNativeSamples(startMs);
    try {
      _nativeOboeEngine ??= NativeOboeRecorderEngine();
      await _nativeOboeEngine!.stopN3cSession();
      await _nativeOboeEngine!.preparePlayback(
        trackPaths: _trackFiles,
        trackClips: _trackClips,
        trackTapeStartMs: _trackTapeStartMs,
        trackTapeStartSamples: _trackTapeStartSamples,
        recordLatencyOffsetMs: _trackOffsets,
        recordLatencyOffsetSamples: _recordLatencyOffsetSamples,
        preferSampleTiming: true,
        tapeLengthMs: tapeLengthMs,
        volumes: _trackVolumes,
        mutes: _trackMutes,
        solos: _trackSolos,
        guideClickEnabled: _metronomeOn,
        guideClickBpm: _bpm,
        guideClickVolume: _clickVolume,
        guideClickSound: _metronomeSound,
        guideClickOriginSample: 0,
        playbackStartSample: startSample,
      );
      await _nativeOboeEngine!.startPlayback(startSample: startSample);
      if (!mounted) return false;
      setState(() {
        _isPlaying = true;
        _nativePlaybackActive = true;
        _applyTapeHeadClamped(startMs);
      });
      _showSnackbar('PLAYBACK');
      _startTicker();
      debugPrint(
        'Orpheus N3E-G: PLAY_NATIVE startMs=$startMs startSample=$startSample',
      );
      return true;
    } catch (e, st) {
      final engine = _nativeOboeEngine;
      final err = engine?.lastNativeError ?? '';
      int? errorCode;
      int? tracksLoaded;
      try {
        final d = engine?.readMixerDiagnostics();
        errorCode = d?.errorCode;
        tracksLoaded = d?.tracksLoaded;
      } catch (_) {}
      debugPrint(
        'Orpheus N3E-G: native playback failed: $e '
        'nativeErr=$err errorCode=$errorCode tracksLoaded=$tracksLoaded\n$st',
      );
      await _stopNativePlaybackOnly();
      if (mounted) {
        _showSnackbar('PLAYBACK FAILED');
      }
      return false;
    }
  }

  Future<void> _play() async {
    if (_isRecording || _isExporting) return;
    if (_isPlaying) return;

    orpheusReleaseLog(
      'play tap engine=$_projectAudioEngine native=$_isNativeProject '
      'hasWav=${projectHasAtLeastOneWavTrack(_trackFiles)}',
    );

    if (!_shouldAttemptNativePlayback()) {
      _showSnackbar(
        Platform.isAndroid ? 'PLAYBACK FAILED' : 'ANDROID ONLY',
      );
      return;
    }

    await _tryStartNativePlayback();
  }

  void _showRecordingCheckReminder() {
    showOrpheusRecordingCheckReminderDialog(
      context,
      onOpenSettings: () {
        showOrpheusDeckSettingsDialog(
          context,
          isTransportBusy: () => _isRecording || _isPlaying || _isExporting,
        );
      },
      onPersistDoNotShowAgain: () =>
          OrpheusSettings.instance.setRecordingCheckReminderEnabled(false),
      onContinue: () => _record(skipRecordingCheckReminder: true),
    );
  }

  Future<void> _record({bool skipRecordingCheckReminder = false}) async {
    if (_isRecording || _isExporting) return;

    int armedCount = _armedTracks.where((isArmed) => isArmed).length;
    if (armedCount != 1) {
      orpheusReleaseLog('record blocked armedCount=$armedCount');
      _showSnackbar(kOrpheusErrArmTrackMessage);
      return;
    }

    int armedIndex = _armedTracks.indexOf(true);
    final int recordTapeStartMs = _playbackMs.clamp(0, tapeLengthMs);
    orpheusReleaseLog(
      'record tap armedTrack=$armedIndex skipReminder=$skipRecordingCheckReminder '
      'engine=$_projectAudioEngine native=$_isNativeProject',
    );
    debugPrint(
        'Orpheus Deck: RECORD_TAPE_START armedTrack=$armedIndex recordTapeStartMs=$recordTapeStartMs playbackMs=$_playbackMs');

    final lane = _clipsForLane(armedIndex);
    if (lane.isNotEmpty) {
      final int latencyOffset =
          OrpheusSettings.instance.effectiveRecordLatencyOffsetSamples;
      final int startSample = orpheusMsToNativeSamples(recordTapeStartMs);
      final gate = validateRecordStartOnLane(
        lane: lane,
        tapeStartSamples: startSample,
        recordLatencyOffsetSamples: latencyOffset,
        allowPunchInStart: true,
      );
      if (!gate.allowed) {
        _showSnackbar('ERR: RECORD FAILED');
        return;
      }
    }

    if (!skipRecordingCheckReminder &&
        OrpheusSettings.instance.recordingCheckReminderEnabled) {
      orpheusReleaseLog('record showing recordingCheckReminder');
      _showRecordingCheckReminder();
      return;
    }

    final status = await Permission.microphone.request();
    orpheusReleaseLog('record micPermission=$status');
    if (status != PermissionStatus.granted) {
      _showSnackbar('ERR: MIC PERMISSION DENIED');
      return;
    }

    if (!_shouldAttemptNativeRecording()) {
      orpheusReleaseLog(
        'record blocked nativeEligible=false engine=$_projectAudioEngine',
      );
      _showSnackbar(
        Platform.isAndroid ? 'ERR: RECORD UNAVAILABLE' : 'ANDROID ONLY',
      );
      return;
    }

    await _tryStartNativeRecording(
      armedIndex: armedIndex,
      recordTapeStartMs: recordTapeStartMs,
    );
  }

  /// Atomic native take save: finalize WAV, validate, then assign metadata + session.
  Future<bool> _finalizeAndCommitNativeRecording() async {
    final pending = _nativeRecordTakePending;
    if (pending == null) {
      debugPrint(
        'Orpheus NATIVE_REC_SAVE: ABORT no_pending_take_snapshot',
      );
      return false;
    }

    final int takeId = pending.takeId;
    final int armedIndex = pending.armedTrack;

    debugPrint(
      'Orpheus NATIVE_REC_SAVE: FINALIZE_BEGIN takeId=$takeId '
      'armedTrack=$armedIndex recordStartMs=${pending.recordStartMs} '
      'recordStartSample=${pending.recordStartSample} '
      'outputPath=${pending.outputPath}',
    );
    debugPrint(
      'Orpheus NATIVE_REC_REGRESSION: FINALIZE_BEGIN takeId=$takeId '
      'clickEnabled=$_metronomeOn nativeRecording=$_nativeRecordingActive',
    );

    final result = await _nativeOboeEngine!.finalizeRecording(
      expectedOutputPath: pending.outputPath,
      takeId: takeId,
    );

    if (result.path != pending.outputPath) {
      debugPrint(
        'Orpheus NATIVE_REC_SAVE: ABORT takeId=$takeId path_mismatch '
        'resultPath=${result.path} expected=${pending.outputPath}',
      );
      _nativeRecordTakePending = null;
      if (armedIndex >= 0 && armedIndex < 4) {
        setState(() => _armedTracks[armedIndex] = false);
      }
      _showSnackbar('ERR: RECORD FAILED');
      return false;
    }

    if (result.recordedFramesWritten == 0) {
      final f = File(pending.outputPath);
      if (f.existsSync()) {
        try {
          f.deleteSync();
        } catch (e) {
          debugPrint(
            'Orpheus NATIVE_REC_SAVE: delete_empty takeId=$takeId $e',
          );
        }
      }
      _nativeRecordTakePending = null;
      if (armedIndex >= 0 && armedIndex < 4) {
        setState(() => _armedTracks[armedIndex] = false);
      }
      debugPrint(
        'Orpheus NATIVE_COUNT_IN: REC_CANCELLED takeId=$takeId '
        '(no WAV, no track assigned)',
      );
      return false;
    }

    if (!result.success) {
      final f = File(pending.outputPath);
      final diag = result.diagnostics;
      if (f.existsSync()) {
        try {
          f.deleteSync();
        } catch (e) {
          debugPrint(
            'Orpheus NATIVE_REC_SAVE: delete_failed takeId=$takeId $e',
          );
        }
      }
      _nativeRecordTakePending = null;
      if (armedIndex >= 0 && armedIndex < 4) {
        setState(() => _armedTracks[armedIndex] = false);
      }
      debugPrint(
        'Orpheus LONG_REC_SAVE: FAILED takeId=$takeId armedTrack=$armedIndex '
        'recordStartSample=${pending.recordStartSample} '
        'path=${pending.outputPath} '
        'recordedFramesWritten=${result.recordedFramesWritten} '
        'nativeErr=${_nativeOboeEngine?.lastNativeError} '
        'wavWrite=${diag?.wavWriteSuccess} recordSuccess=${diag?.recordSuccess} '
        'errorCode=${diag?.errorCode} '
        'inputCb=${diag?.inputCallbackCount} outputCb=${diag?.outputCallbackCount} '
        'xRuns=${result.xRunCount} fileBytes=${f.existsSync() ? f.lengthSync() : 0}',
      );
      debugPrint(
        'Orpheus NATIVE_REC_SAVE: FAILED takeId=$takeId '
        'nativeErr=${_nativeOboeEngine?.lastNativeError} '
        'frames=${result.recordedFramesWritten} xruns=${result.xRunCount}',
      );
      _showSnackbar('ERR: RECORD FAILED');
      return false;
    }

    if (armedIndex < 0 || armedIndex >= 4) {
      debugPrint(
        'Orpheus NATIVE_REC_SAVE: ABORT takeId=$takeId invalid_armed=$armedIndex',
      );
      _nativeRecordTakePending = null;
      _showSnackbar('ERR: RECORD FAILED');
      return false;
    }

    final probe = validateRecordedNativeWav(
      path: pending.outputPath,
      nativeRecordedFramesWritten: result.recordedFramesWritten,
    );
    if (!probe.ok) {
      final f = File(pending.outputPath);
      if (f.existsSync()) {
        try {
          f.deleteSync();
        } catch (_) {}
      }
      _nativeRecordTakePending = null;
      setState(() => _armedTracks[armedIndex] = false);
      debugPrint(
        'Orpheus LONG_REC_SAVE: VALIDATION_FAILED takeId=$takeId '
        'reason=${probe.reason} wavFrames=${probe.frameCount} '
        'dataBytes=${probe.dataBytes} nativeFrames=${result.recordedFramesWritten}',
      );
      debugPrint(
        'Orpheus NATIVE_REC_SAVE: FAILED takeId=$takeId post_probe '
        'reason=${probe.reason}',
      );
      _showSnackbar('ERR: RECORD FAILED');
      return false;
    }

    final int durationMs = probe.durationMs;
    final int tapeStartMs = pending.recordStartMs;
    final int tapeStartSamples = pending.recordStartSample;
    final int latencyOffsetSamples = pending.recordLatencyOffsetSamples;

    final waveformResult = await waveformForSavedNativeWav(
      path: pending.outputPath,
      fallbackDurationMs: durationMs,
    );

    final recordedClip = buildRecordedTrackClip(
      id: 'rec_${takeId}_${DateTime.now().millisecondsSinceEpoch}',
      filePath: pending.outputPath,
      tapeStartSamples: tapeStartSamples,
      lengthSamples: probe.frameCount,
      recordLatencyOffsetSamples: latencyOffsetSamples,
      createdAt: DateTime.now().toUtc(),
    );
    final overwrite = tapeIntervalFromClip(recordedClip);
    var splitSeq = 0;
    final commitResult = commitClipWithOverwrite(
      lane: _clipsForLane(armedIndex),
      newClip: recordedClip,
      overwrite: overwrite,
      newClipId: () => 'split_${takeId}_${splitSeq++}',
    );
    if (!commitResult.ok) {
      final f = File(pending.outputPath);
      if (f.existsSync()) {
        try {
          f.deleteSync();
        } catch (_) {}
      }
      _nativeRecordTakePending = null;
      setState(() => _armedTracks[armedIndex] = false);
      _showSnackbar(
        overwriteClipFailureUserMessage(commitResult.failure!),
      );
      debugPrint(
        'Orpheus NATIVE_REC_SAVE: OVERWRITE_REJECTED takeId=$takeId '
        '${overwriteCommitFailureDebugDetail(
          failure: commitResult.failure!,
          newClip: recordedClip,
          overwrite: overwrite,
          laneClipCount: _clipsForLane(armedIndex).length,
          outputPath: pending.outputPath,
          probeFrameCount: probe.frameCount,
        )}',
      );
      return false;
    }

    setState(() {
      _trackClips[armedIndex] =
          List<OrpheusTrackClip>.from(commitResult.clips!);
      _waveformCache[pending.outputPath] = waveformResult.amplitudes;
      _syncLegacyMirrorForLane(armedIndex);
      _trackOffsets[armedIndex] = 0;
      _armedTracks[armedIndex] = false;
    });

    _nativeRecordTakePending = null;

    final int fileBytes = File(pending.outputPath).lengthSync();
    debugPrint(
      'Orpheus NATIVE_REC_REGRESSION: COMMIT_OK takeId=$takeId '
      'armedTrack=$armedIndex clickWasDisabledForNative=true '
      'recordedFramesWritten=${result.recordedFramesWritten} '
      'wavFrames=${probe.frameCount} fileBytes=$fileBytes '
      'xRunCount=${result.xRunCount} clickEnabled=$_metronomeOn',
    );

    debugPrint(
      'Orpheus NATIVE_REC_SAVE: SAVED takeId=$takeId armedTrack=$armedIndex '
      'recordStartMs=$tapeStartMs recordStartSample=$tapeStartSamples '
      'recordLatencyOffsetSamples=$latencyOffsetSamples '
      'effectiveTapeStartSamples='
      '${effectiveTapeStartSamples(trackTapeStartSamples: tapeStartSamples, recordLatencyOffsetSamples: latencyOffsetSamples)} '
      'nativeFrames=${result.recordedFramesWritten} wavFrames=${probe.frameCount} '
      'fileBytes=${probe.fileBytes} durationMs=$durationMs '
      'xruns=${result.xRunCount} path=${pending.outputPath}',
    );

    debugLogNativeSessionTrackMetadata(
      projectName: _projectName,
      audioEngine: _projectAudioEngine,
      trackFiles: _trackFiles,
      trackTapeStartMs: _trackTapeStartMs,
      trackTapeStartSamples: _trackTapeStartSamples,
      recordLatencyOffsetSamples: _recordLatencyOffsetSamples,
      tag: 'NATIVE_REC_SAVE',
    );

    await _saveSession();
    debugPrint(
      'Orpheus NATIVE_REC_SAVE: SESSION_SAVED takeId=$takeId project=$_projectName',
    );

    if (mounted) {
      _showSnackbar('RECORD SAVED');
      if (result.veryQuietWarning) {
        _showSnackbar('RECORDING WAS VERY QUIET');
      }
    }
    return true;
  }

  Future<void> _stop({String transportStopReason = 'USER_STOP'}) async {
    if (_isExporting && _exportSessionId != null) {
      orpheusFfmpegCancel(_exportSessionId);
      return;
    }

    final bool nativeRecInProgress =
        _nativeRecordingActive && _isRecording && !_nativeRecordingFinalized;

    debugPrint(
      'Orpheus Deck: TRANSPORT_STOP_ENTER '
      'reason=$transportStopReason '
      'recording=$_isRecording playing=$_isPlaying '
      'nativeRecActive=$_nativeRecordingActive '
      'nativePlaybackActive=$_nativePlaybackActive '
      'nativeRecFinalized=$_nativeRecordingFinalized '
      'nativeRecFinalizing=$_nativeRecordingFinalizing '
      'nativeRecInProgress=$nativeRecInProgress',
    );

    // Cassette: second STOP while already idle rewinds tape to 0:00.
    if (!_isRecording && !_isPlaying) {
      if (_nativeRecordTakePending != null) {
        debugPrint(
          'Orpheus NATIVE_REC_SAVE: IDLE_STOP_CLEAR_STALE_PENDING '
          'takeId=${_nativeRecordTakePending!.takeId} '
          '(metadata not committed)',
        );
        _nativeRecordTakePending = null;
      }
      if (_nativeRecordingActive) {
        debugPrint(
          'Orpheus Deck: TRANSPORT_STOP_IDLE_CLEAR_STALE_NATIVE_REC_FLAG',
        );
        _nativeRecordingActive = false;
      }
      debugPrint(
        'Orpheus Deck: TRANSPORT_STOP_IDLE_REWIND '
        'reason=$transportStopReason '
        'tapeLengthMs=$tapeLengthMs playbackMs=$_playbackMs -> 0',
      );
      _setTapeHeadMs(0);
      return;
    }

    final int contentMaxMs = _getMaxPlaybackDuration();
    debugPrint(
      'Orpheus Deck: TRANSPORT_STOP '
      'reason=$transportStopReason '
      'tapeLengthMs=$tapeLengthMs '
      'playbackMs=$_playbackMs '
      'contentMaxMs=$contentMaxMs '
      'recording=$_isRecording playing=$_isPlaying',
    );

    bool recordedSomething = false;
    bool nativeSessionSavedInFinalize = false;

    if (_nativeRecordingFinalizing && _nativeRecordFinalizeCompleter != null) {
      debugPrint(
        'Orpheus NATIVE_REC_SAVE: TRANSPORT_STOP_AWAIT_IN_FLIGHT_FINALIZE '
        'reason=$transportStopReason',
      );
      await _nativeRecordFinalizeCompleter!.future;
    } else if (nativeRecInProgress && _nativeOboeEngine != null) {
      _nativeRecordingFinalizing = true;
      _nativeRecordFinalizeCompleter = Completer<void>();
      try {
        recordedSomething = await _finalizeAndCommitNativeRecording();
        nativeSessionSavedInFinalize = recordedSomething;
        _nativeRecordingActive = false;
        _nativeRecordingFinalized = true;
      } finally {
        _nativeRecordingFinalizing = false;
        _activeRecordTapeStartMs = null;
        _nativeRecordFinalizeCompleter?.complete();
        _nativeRecordFinalizeCompleter = null;
      }
    } else if (_nativeRecordingActive && !_isRecording) {
      debugPrint(
        'Orpheus Deck: TRANSPORT_STOP_IGNORE_STALE_NATIVE_REC '
        '(already idle, not re-finalizing)',
      );
      _nativeRecordingActive = false;
    }

    if (_nativePlaybackActive) {
      await _stopNativePlaybackOnly();
    }

    _tickerTimer?.cancel();

    setState(() {
      _nativeCountInActive = false;
      _countInBeatsRemaining = 0;
      _isPlaying = false;
      _isRecording = false;
      _nativePlaybackActive = false;
      _nativeRecordingActive = false;
    });

    if (recordedSomething && !nativeSessionSavedInFinalize) {
      await _saveSession();
    }

    debugPrint(
      'Orpheus Deck: TRANSPORT_STOP_DONE reason=$transportStopReason '
      'nativeRecFinalized=$_nativeRecordingFinalized '
      'pendingTake=${_nativeRecordTakePending?.takeId}',
    );
  }

  void _resetTimer() {
    unawaited(_resetTimerAfterStop());
  }

  Future<void> _resetTimerAfterStop() async {
    await _stop(transportStopReason: 'LONG_PRESS_RESET');
    if (!mounted) return;
    _setTapeHeadMs(0);
    _showSnackbar('TIMER RESET');
  }

  void _toggleArmTrack(int index) {
    setState(() {
      _armedTracks[index] = !_armedTracks[index];
    });
  }

  /// Hidden beta tool: populate native project with 4 staggered WAV click tracks.
  Future<void> _generateNativeTestTracks() async {
    if (!_isNativeProject) {
      _showSnackbar('ERR: WAV PROJECT ONLY');
      return;
    }
    if (_isPlaying || _isRecording || _isExporting) {
      _showSnackbar('ERR: STOP TRANSPORT FIRST');
      return;
    }

    try {
      await _stopNativePlaybackOnly();
      final projDir = await orpheusProjectDirectory(_projectName);

      for (int i = 0; i < 4; i++) {
        final old = _trackFiles[i];
        if (old != null) {
          final f = File(old);
          if (f.existsSync()) {
            await f.delete();
          }
          _waveformCache.remove(old);
        }
      }

      const tapeStartsMs = [0, 1000, 2000, 3000];
      final newPaths = <String>[];

      for (int i = 0; i < 4; i++) {
        final path = '${projDir.path}/native_test_trk$i.wav';
        await writeNativeTestTrackWav(path: path, trackIndex: i);
        newPaths.add(path);
      }

      if (!mounted) return;
      setState(() {
        for (int i = 0; i < 4; i++) {
          _trackFiles[i] = newPaths[i];
          _trackTapeStartMs[i] = tapeStartsMs[i];
          _trackTapeStartSamples[i] =
              orpheusSessionMsToSamples(tapeStartsMs[i]);
          _recordLatencyOffsetSamples[i] = 0;
          _trackOffsets[i] = 0;
          _armedTracks[i] = false;
          _waveformCache[newPaths[i]] = nativeTestTrackWaveformPlaceholder(i);
        }
        if (!isNativeAudioEngine(_projectAudioEngine)) {
          _projectAudioEngine = kOrpheusAudioEngineNative;
        }
      });
      await _saveSession();
      _showSnackbar('DEBUG WAV TRACKS READY');
      debugPrint('Orpheus N3E-G: generated 4 native test WAV tracks');
    } catch (e, st) {
      debugPrint('Orpheus N3E-G: generate native test tracks failed: $e\n$st');
      _showSnackbar('ERR: DEBUG WAV TRACK GEN FAILED');
    }
  }

  Future<void> _clearTrack(int index) async {
    if (_isRecording || _isPlaying) {
      _showSnackbar('ERR: STOP TRANSPORT TO CLEAR');
      return;
    }
    if (!_laneHasAudio(index)) {
      debugPrint('Orpheus Deck: CLEAR TRK $index - no clips, nothing to do');
      return;
    }

    final laneClips = sortClipsByTapeStart(_clipsForLane(index));
    final pathsToTrash = <String>{
      for (final clip in laneClips) clip.filePath,
    };
    final String? legacyPath = _trackFiles[index];
    if (legacyPath != null) {
      pathsToTrash.add(legacyPath);
    }

    final String undoPath =
        laneClips.isNotEmpty ? laneClips.first.filePath : legacyPath!;
    debugPrint(
      'Orpheus Deck: CLEAR TRK $index START | clips=${laneClips.length} '
      'paths=${pathsToTrash.length}',
    );

    _lastUndo.clear();
    _lastUndo.action = UndoAction.clearTrack;
    _lastUndo.trackIndex = index;
    _lastUndo.trackFile = undoPath;
    _lastUndo.trackWaveform = _waveformCache[undoPath];
    _lastUndo.trackTapeStartMs = laneClips.isNotEmpty
        ? orpheusSessionSamplesToMs(laneClips.first.tapeStartSamples)
        : _trackTapeStartMs[index];

    for (final filePath in pathsToTrash) {
      final File file = File(filePath);
      if (!file.existsSync()) {
        debugPrint(
          'Orpheus Deck: CLEAR TRK $index - missing on disk: $filePath',
        );
        continue;
      }
      try {
        file.renameSync('${file.path}.trash');
        debugPrint(
          'Orpheus Deck: CLEAR TRK $index - renamed to .trash OK: $filePath',
        );
      } catch (e, s) {
        debugPrint('Orpheus Deck: CLEAR TRK $index - rename FAILED: $e\n$s');
        try {
          file.deleteSync();
          debugPrint(
            'Orpheus Deck: CLEAR TRK $index - fallback deleteSync OK: $filePath',
          );
        } catch (e2, s2) {
          debugPrint(
            'Orpheus Deck: CLEAR TRK $index - delete also FAILED: $e2\n$s2',
          );
        }
      }
    }

    setState(() {
      for (final path in pathsToTrash) {
        _waveformCache.remove(path);
      }
      _trackClips[index] = [];
      _clearLegacyMirrorForLane(index);
    });

    debugPrint(
      'Orpheus Deck: CLEAR TRK $index DONE - all lane clips cleared',
    );
    _showSnackbar('TRK 0${index + 1} CLEARED');
    _saveSession();
  }

  Future<void> _navigateBackToHome() async {
    if (_transportBusy()) {
      _showSnackbar('STOP PLAY/REC FIRST');
      return;
    }
    await _stop();
    try {
      await _saveSession();
    } catch (e, st) {
      orpheusReleaseLogError('backToHome session save', e, st);
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        unawaited(_navigateBackToHome());
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                DeckHeader(
                  statusLabel: _deckStatus,
                  tapeTransportMs: _playbackMs,
                  projectName: _projectName,
                  onProjectTap: _showProjectMenu,
                  hasUndo: _lastUndo.hasUndo,
                  onUndo: _performUndo,
                  engineSubtitleLine: _recorderEngineSubtitleLine(),
                  deckVersionLine: kOrpheusPublicVersionLine,
                  beatDots: OrpheusClickHeaderBeatDots(
                    clickEnabled: _metronomeOn,
                    bpm: _bpm,
                    playbackMs: _playbackMs,
                    transportActive: _isPlaying || _isRecording,
                    countInBeatsRemaining:
                        _nativeCountInActive ? _countInBeatsRemaining : 0,
                    onLongPressVolume: _showClickVolumeQuickPopup,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: 4,
                      separatorBuilder: (context, index) => const Divider(
                        color: Colors.white24,
                        height: 1,
                        thickness: 1,
                      ),
                      itemBuilder: (context, index) {
                        return TrackStrip(
                          trackNumber: index + 1,
                          trackLabel: _trackTitle(index),
                          isArmed: _armedTracks[index],
                          isPlaying: _isPlaying,
                          isRecording: _isRecording,
                          filePath: _trackFiles[index],
                          clipViews: _waveformClipViewsForTrack(index),
                          hasLaneAudio: _laneHasAudio(index),
                          tapeTransportMs: _playbackMs,
                          volume: _trackVolumes[index],
                          isMuted: _trackMutes[index],
                          isSoloed: _trackSolos[index],
                          onTitleTap: () => _showTrackOptions(index),
                          onArmToggled: () => _toggleArmTrack(index),
                          onClear: () => _clearTrack(index),
                          onVolumeChangeStart: (val) =>
                              _onVolumeChangeStart(index, val),
                          onVolumeChanged: (val) => _setVolume(index, val),
                          onMuteToggled: () => _toggleMute(index),
                          onSoloToggled: () => _toggleSolo(index),
                          onFxTap: () => _openTrackFx(index),
                          fxProLocked: orpheusProFxButtonLocked(),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TapeReelTransport(
                  playbackMs: _playbackMs,
                  tapeLengthMs: tapeLengthMs,
                  isPlaying: _isPlaying,
                  isRecording: _isRecording,
                  seekEnabled: !_isExporting,
                  onTapeSeekMs: _onTapeHeadSeekFromReel,
                ),
                const SizedBox(height: 10),
                TransportControls(
                  isPlaying: _isPlaying,
                  isRecording: _isRecording,
                  isClickTrackOn: _metronomeOn,
                  onPlay: _play,
                  onStop: _stop,
                  onStopLongPress: _resetTimer,
                  onRecord: _record,
                  onClickTap: _onClickTransportTap,
                  onClickLongPress: _showClickTrackSettings,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _initAudioSession() async {
    final session = await as_sess.AudioSession.instance;
    const cfg = as_sess.AudioSessionConfiguration(
      avAudioSessionCategory: as_sess.AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          as_sess.AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: as_sess.AVAudioSessionMode.defaultMode,
      avAudioSessionRouteSharingPolicy:
          as_sess.AVAudioSessionRouteSharingPolicy.defaultPolicy,
      androidAudioAttributes: as_sess.AndroidAudioAttributes(
        contentType: as_sess.AndroidAudioContentType.music,
        flags: as_sess.AndroidAudioFlags.none,
        usage: as_sess.AndroidAudioUsage.media,
      ),
      androidAudioFocusGainType: as_sess.AndroidAudioFocusGainType.gain,
    );
    await session.configure(cfg);
    if (kOrpheusAudioSessionSetActiveOnInit) {
      await session.setActive(true);
    }
    debugPrint('Orpheus Deck: Audio session configured '
        'setActiveOnInit=$kOrpheusAudioSessionSetActiveOnInit '
        'playAndRecord json=${jsonEncode(cfg.toJson())}');
    try {
      final live = await as_sess.AudioSession.instance;
      debugPrint(
          'Orpheus Deck: AudioSession active id=${identityHashCode(live)} '
          'isConfigured=${live.isConfigured} androidUsage=${live.configuration?.androidAudioAttributes?.usage}');
    } catch (e, st) {
      debugPrint('Orpheus Deck: AudioSession post-config log err $e\n$st');
    }
  }
}

class _ExportsBrowseHost extends StatefulWidget {
  const _ExportsBrowseHost({required this.recorder});
  final _RecorderScreenState recorder;

  @override
  State<_ExportsBrowseHost> createState() => _ExportsBrowseHostState();
}

class _ExportsBrowseHostState extends State<_ExportsBrowseHost> {
  int _reloadNonce = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black,
      shape: Border.all(color: Colors.white, width: 2),
      title: const Text(
        'EXPORT HISTORY',
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: 360,
        child: FutureBuilder<_ExportBrowseSnapshot>(
          key: ValueKey(_reloadNonce),
          future: widget.recorder._loadExportsBrowseSnapshot(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting &&
                !snap.hasData) {
              return const Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              );
            }
            if (snap.hasError) {
              return const Text(
                'EXPORTS SAVED TO MUSIC/ORPHEUS DECK',
                style: TextStyle(
                  color: Colors.white54,
                  fontFamily: 'monospace',
                  fontSize: 10,
                  height: 1.35,
                ),
              );
            }
            final data = snap.data!;
            if (data.entries.isEmpty) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'NO EXPORTS IN HISTORY',
                    style: TextStyle(
                      color: Colors.white54,
                      fontFamily: 'monospace',
                      fontSize: 11,
                    ),
                  ),
                  if (data.footerHintText != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      data.footerHintText!,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontFamily: 'monospace',
                        fontSize: 9,
                        height: 1.35,
                      ),
                    ),
                  ],
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ListView.separated(
                    itemCount: data.entries.length,
                    separatorBuilder: (_, __) => const Divider(
                      color: Colors.white24,
                      height: 1,
                      thickness: 1,
                    ),
                    itemBuilder: (ctx, i) {
                      final e = data.entries[i];
                      final ts = _formatExportDateTime(e.createdAt);
                      final canDelete = (e.storageUri != null &&
                              e.storageUri!.startsWith('content://')) ||
                          (e.absolutePath != null &&
                              File(e.absolutePath!).existsSync());
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    e.filename,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'monospace',
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${e.kind} • $ts',
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontFamily: 'monospace',
                                      fontSize: 9,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () =>
                                      widget.recorder._shareExportEntry(e),
                                  style: TextButton.styleFrom(
                                    minimumSize: Size.zero,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text(
                                    'SHARE',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      widget.recorder._tryOpenExportLocation(e),
                                  style: TextButton.styleFrom(
                                    minimumSize: Size.zero,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    foregroundColor: Colors.white70,
                                  ),
                                  child: const Text(
                                    'OPEN',
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                if (canDelete)
                                  TextButton(
                                    onPressed: () async {
                                      await widget.recorder
                                          ._deleteExportBrowsedEntry(e);
                                      if (mounted) {
                                        setState(() => _reloadNonce++);
                                      }
                                    },
                                    style: TextButton.styleFrom(
                                      minimumSize: Size.zero,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      foregroundColor: Colors.white38,
                                    ),
                                    child: const Text(
                                      'DELETE',
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                if (data.footerHintText != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    data.footerHintText!,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontFamily: 'monospace',
                      fontSize: 9,
                      height: 1.35,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'CLOSE',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'monospace',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class DeckHeader extends StatelessWidget {
  final String statusLabel;

  /// Same value as recorder `_playbackMs` (tape transport clock).
  final int tapeTransportMs;
  final String projectName;
  final VoidCallback onProjectTap;
  final bool hasUndo;
  final VoidCallback onUndo;
  final String? engineSubtitleLine;
  final String deckVersionLine;
  final Widget? beatDots;

  const DeckHeader({
    super.key,
    required this.statusLabel,
    required this.tapeTransportMs,
    required this.projectName,
    required this.onProjectTap,
    this.hasUndo = false,
    required this.onUndo,
    this.engineSubtitleLine,
    this.deckVersionLine = kOrpheusPublicVersionLine,
    this.beatDots,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "ORPHEUS DECK",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: onProjectTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            border: Border.all(color: Colors.white54, width: 1),
                          ),
                          child: Text(
                            projectName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (hasUndo) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onUndo,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            border: Border.all(color: Colors.white, width: 1),
                          ),
                          child: const Text(
                            "UNDO",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'monospace',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'FOUR-TRACK AUDIO RECORDER // MK-I',
                  style: TextStyle(
                    color: Colors.white54,
                    fontFamily: 'monospace',
                    fontSize: 8,
                    letterSpacing: 1,
                  ),
                ),
                if (engineSubtitleLine != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    engineSubtitleLine!,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontFamily: 'monospace',
                      fontSize: 7,
                      letterSpacing: 0.4,
                      height: 1.25,
                    ),
                  ),
                ],
                const SizedBox(height: 2),
                Text(
                  deckVersionLine,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontFamily: 'monospace',
                    fontSize: 7,
                    letterSpacing: 0.4,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _tapeClockMmSs(tapeTransportMs),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                ),
              ),
              Row(
                children: [
                  Text(
                    (statusLabel == 'RECORDING' ||
                            statusLabel == 'OVERDUB' ||
                            statusLabel == 'EXPORTING')
                        ? "● $statusLabel"
                        : statusLabel,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'monospace',
                      fontWeight: statusLabel != 'IDLE'
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              if (beatDots != null) beatDots!,
            ],
          ),
        ],
      ),
    );
  }
}

class TrackStrip extends StatelessWidget {
  final int trackNumber;
  final String trackLabel;
  final bool isArmed;
  final bool isPlaying;
  final bool isRecording;
  final String? filePath;
  final List<OrpheusWaveformClipView> clipViews;
  final bool hasLaneAudio;

  /// Same recorder `_playbackMs` as reel / header (transport playhead).
  final int tapeTransportMs;

  final double volume;
  final bool isMuted;
  final bool isSoloed;

  final VoidCallback onTitleTap;
  final VoidCallback onArmToggled;
  final VoidCallback onClear;
  final ValueChanged<double>? onVolumeChangeStart;
  final ValueChanged<double> onVolumeChanged;
  final VoidCallback onMuteToggled;
  final VoidCallback onSoloToggled;
  final VoidCallback onFxTap;
  final bool fxProLocked;

  const TrackStrip({
    super.key,
    required this.trackNumber,
    required this.trackLabel,
    required this.isArmed,
    required this.isPlaying,
    required this.isRecording,
    required this.filePath,
    required this.clipViews,
    required this.hasLaneAudio,
    required this.tapeTransportMs,
    required this.volume,
    required this.isMuted,
    required this.isSoloed,
    required this.onTitleTap,
    required this.onArmToggled,
    required this.onClear,
    this.onVolumeChangeStart,
    required this.onVolumeChanged,
    required this.onMuteToggled,
    required this.onSoloToggled,
    required this.onFxTap,
    required this.fxProLocked,
  });

  bool get _isWaveformActive {
    if (isRecording) {
      if (isArmed) return true;
      if (clipViews.isNotEmpty) return true;
      return false;
    }
    return isPlaying && clipViews.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final bool hasAudio = hasLaneAudio;
    final String clipId = hasAudio
        ? filePath!.split(RegExp(r'[/\\]')).last.replaceAll('.m4a', '')
        : "";

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onTitleTap,
                onLongPress: hasAudio && clipId.isNotEmpty
                    ? () {
                        showOrpheusOledToast(context, 'CLIP: $clipId');
                      }
                    : null,
                child: SizedBox(
                  width: 88,
                  child: Text(
                    trackLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: onArmToggled,
                child: Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isArmed ? Colors.white : Colors.black,
                    border: Border.all(color: Colors.white, width: 2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      "A",
                      style: TextStyle(
                        color: isArmed ? Colors.black : Colors.white,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: Colors.white54, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: WaveformDisplay(
                      clipViews: clipViews,
                      isLive: isRecording && isArmed,
                      playbackMs: tapeTransportMs,
                      tapeLengthMs: tapeLengthMs,
                      isActive: _isWaveformActive,
                    ),
                  ),
                ),
              ),
              if (hasAudio)
                GestureDetector(
                  onTap: onClear,
                  child: Container(
                    width: 36,
                    height: 36,
                    margin: const EdgeInsets.only(left: 12),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      border: Border.all(color: Colors.white54, width: 1),
                    ),
                    child: const Center(
                      child: Text(
                        "CLR",
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'monospace',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              GestureDetector(
                onTap: onFxTap,
                child: Container(
                  width: 28,
                  height: 18,
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(
                      color: fxProLocked ? Colors.white38 : Colors.white54,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'FX',
                      style: TextStyle(
                        color: fxProLocked ? Colors.white38 : Colors.white54,
                        fontFamily: 'monospace',
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: onMuteToggled,
                child: Container(
                  width: 24,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isMuted ? Colors.white : Colors.black,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: Center(
                    child: Text(
                      "M",
                      style: TextStyle(
                        color: isMuted ? Colors.black : Colors.white,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onSoloToggled,
                child: Container(
                  width: 24,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isSoloed ? Colors.white : Colors.black,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: Center(
                    child: Text(
                      "S",
                      style: TextStyle(
                        color: isSoloed ? Colors.black : Colors.white,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text("VOL",
                  style: TextStyle(
                      color: Colors.white54,
                      fontFamily: 'monospace',
                      fontSize: 10)),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 2,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape:
                        const RoundSliderOverlayShape(overlayRadius: 12),
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.white24,
                    thumbColor: Colors.white,
                  ),
                  child: Slider(
                    value: volume,
                    min: 0.0,
                    max: 1.0,
                    onChangeStart: onVolumeChangeStart,
                    onChanged: onVolumeChanged,
                  ),
                ),
              ),
              if (hasAudio) const SizedBox(width: 48),
            ],
          ),
        ],
      ),
    );
  }
}

/// Max-pool [src] down to [targetCount] bars for tape-lane painting.
List<double> _downsampleWaveformForLane(List<double> src, int targetCount) {
  if (src.isEmpty || targetCount <= 0) return const [];
  if (targetCount >= src.length) return src;
  final out = <double>[];
  final double chunk = src.length / targetCount;
  for (int i = 0; i < targetCount; i++) {
    final int start = (i * chunk).floor();
    final int end = min(((i + 1) * chunk).ceil(), src.length);
    double peak = 0;
    for (int j = start; j < end; j++) {
      if (src[j] > peak) peak = src[j];
    }
    out.add(peak);
  }
  return out;
}

class WaveformDisplay extends StatelessWidget {
  final List<OrpheusWaveformClipView> clipViews;
  final bool isLive;
  final int playbackMs;
  final int tapeLengthMs;
  final bool isActive;

  const WaveformDisplay({
    super.key,
    required this.clipViews,
    this.isLive = false,
    this.playbackMs = 0,
    required this.tapeLengthMs,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return CustomPaint(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          painter: WaveformPainter(
            clipViews: clipViews,
            isLive: isLive,
            playbackMs: playbackMs,
            tapeLengthMs: tapeLengthMs,
            isActive: isActive,
          ),
        );
      },
    );
  }
}

/// Fifteen-minute tape lane: one waveform block per clip view (TC-D).
class WaveformPainter extends CustomPainter {
  final List<OrpheusWaveformClipView> clipViews;
  final bool isLive;
  final int playbackMs;
  final int tapeLengthMs;
  final bool isActive;

  WaveformPainter({
    required this.clipViews,
    required this.isLive,
    required this.playbackMs,
    required this.tapeLengthMs,
    required this.isActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double midY = h / 2;
    final int tapeLen = max(1, tapeLengthMs);

    final Paint baselinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.14)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(0, midY), Offset(w, midY), baselinePaint);

    // Subtle minute ticks — tape feel, not a DAW grid.
    for (int m = 1; m < 15; m++) {
      final double x = w * (m / 15.0);
      canvas.drawLine(
        Offset(x, midY - 2),
        Offset(x, midY + 2),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.10)
          ..strokeWidth = 1,
      );
    }

    for (var i = 0; i < clipViews.length; i++) {
      final view = clipViews[i];
      final bool viewIsLive = isLive && i == clipViews.length - 1;
      _paintWaveformBlock(
        canvas: canvas,
        w: w,
        h: h,
        midY: midY,
        tapeLen: tapeLen,
        tapeStartMs: view.tapeStartMs,
        clipDurationMs: view.clipDurationMs,
        amplitudes: view.amplitudes,
        dimmed: !isActive && !viewIsLive,
      );
    }

    // Shared tape playhead — all lanes, idle/play/record/seek.
    final double playheadX = (playbackMs / tapeLen).clamp(0.0, 1.0) * w;
    canvas.drawLine(
      Offset(playheadX, 0),
      Offset(playheadX, h),
      Paint()
        ..color = Colors.white.withValues(alpha: isActive ? 1.0 : 0.72)
        ..strokeWidth = 1.5,
    );
  }

  void _paintWaveformBlock({
    required Canvas canvas,
    required double w,
    required double h,
    required double midY,
    required int tapeLen,
    required int tapeStartMs,
    required int clipDurationMs,
    required List<double> amplitudes,
    required bool dimmed,
  }) {
    final int effectiveClipMs = clipDurationMs > 0
        ? clipDurationMs
        : (amplitudes.isEmpty ? 0 : amplitudes.length * 50);

    if (effectiveClipMs <= 0 || amplitudes.isEmpty) {
      return;
    }

    final double xStart = (tapeStartMs / tapeLen) * w;
    final double xEnd = ((tapeStartMs + effectiveClipMs) / tapeLen) * w;
    final double clipLeft = xStart.clamp(0.0, w);
    final double clipRight = xEnd.clamp(clipLeft, w);
    final double clipW = clipRight - clipLeft;

    if (clipW < 1.0) {
      return;
    }

    final Paint wavePaint = Paint()
      ..color = dimmed ? Colors.white24 : Colors.white
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final int maxBars = max(1, (clipW / 3).floor());
    final List<double> bars = _downsampleWaveformForLane(amplitudes, maxBars);
    final double step = clipW / bars.length;

    for (int i = 0; i < bars.length; i++) {
      final double amp = bars[i];
      if (amp <= 0.0005) continue;
      double barHeight = amp * h * 0.92;
      if (barHeight < 1.0) barHeight = 1.0;
      final double x = clipLeft + (i + 0.5) * step;
      canvas.drawLine(
        Offset(x, midY - barHeight / 2),
        Offset(x, midY + barHeight / 2),
        wavePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    if (oldDelegate.clipViews.length != clipViews.length ||
        oldDelegate.playbackMs != playbackMs ||
        oldDelegate.isActive != isActive ||
        oldDelegate.isLive != isLive) {
      return true;
    }
    for (var i = 0; i < clipViews.length; i++) {
      final oldView = oldDelegate.clipViews[i];
      final view = clipViews[i];
      if (oldView.tapeStartMs != view.tapeStartMs ||
          oldView.clipDurationMs != view.clipDurationMs ||
          oldView.amplitudes.length != view.amplitudes.length) {
        return true;
      }
    }
    return false;
  }
}

class TransportControls extends StatelessWidget {
  final bool isPlaying;
  final bool isRecording;
  final bool isClickTrackOn;
  final VoidCallback onPlay;
  final VoidCallback onStop;
  final VoidCallback onStopLongPress;
  final VoidCallback onRecord;
  final VoidCallback onClickTap;
  final VoidCallback? onClickLongPress;

  const TransportControls({
    super.key,
    required this.isPlaying,
    required this.isRecording,
    required this.isClickTrackOn,
    required this.onPlay,
    required this.onStop,
    required this.onStopLongPress,
    required this.onRecord,
    required this.onClickTap,
    this.onClickLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TransportButton(
            label: "PLAY",
            icon: Icons.play_arrow,
            isActive: isPlaying && !isRecording,
            onTap: onPlay,
          ),
          TransportButton(
            label: "STOP",
            icon: Icons.stop,
            isActive: false,
            onTap: onStop,
            onLongPress: onStopLongPress,
          ),
          TransportButton(
            label: "REC",
            icon: Icons.fiber_manual_record,
            isActive: isRecording,
            onTap: onRecord,
          ),
          TransportButton(
            label: "CLICK",
            icon: Icons.graphic_eq,
            isActive: isClickTrackOn,
            onTap: onClickTap,
            onLongPress: onClickLongPress,
          ),
        ],
      ),
    );
  }
}

class TransportButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const TransportButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    this.onLongPress,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: 70,
        height: 60,
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.black,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.black : Colors.white,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10,
                fontFamily: 'monospace',
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
