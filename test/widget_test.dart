import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexus_assistant/nexus_home/audio/feature_extractor.dart';
import 'package:nexus_assistant/nexus_home/core/nexus_layout.dart';
import 'package:nexus_assistant/nexus_home/nexus_home.dart';
import 'dart:math' as math;
import 'dart:typed_data';

class _NoMicBridge extends NexusVoiceBridge {
  @override
  bool get usesInternalMicrophone => false;
}

void main() {
  const ratios = <String, Size>{
    '16:9': Size(360, 640),
    '19.5:9': Size(390, 845),
    '20:9': Size(360, 800),
    '21:9': Size(360, 840),
    'narrow': Size(320, 640),
  };

  group('NexusLayout', () {
    for (final entry in ratios.entries) {
      test('keeps every element on screen at ${entry.key}', () {
        final size = entry.value;
        const pad = EdgeInsets.only(top: 24, bottom: 16);
        final l = NexusLayout.resolve(size, pad);
        expect(l.statusRect.top, greaterThanOrEqualTo(pad.top));
        expect(l.orbCenter.dx, closeTo(size.width / 2, 0.01));
        expect(l.orbCenter.dy - l.fieldRadius * 1.05, greaterThan(l.statusRect.bottom));
        expect(l.orbCenter.dy + l.fieldRadius, lessThan(l.captionTop));
        expect(l.captionTop + l.captionHeight, lessThan(l.micCenter.dy - l.micRadius));
        expect(l.waveRect.bottom, lessThan(size.height - pad.bottom));
        expect(l.micCenter.dy + l.micRadius * 1.55, lessThan(size.height - pad.bottom));
      });
    }
  });

  test('FeatureExtractor normalises silence low and a tone high', () {
    final fx = FeatureExtractor();
    Uint8List tone(double amp, double hz) {
      final data = ByteData(512 * 2);
      for (var i = 0; i < 512; i++) {
        data.setInt16(i * 2, (math.sin(2 * math.pi * hz * i / 16000) * amp * 32767).round(),
            Endian.little);
      }
      return data.buffer.asUint8List();
    }

    for (var i = 0; i < 20; i++) {
      fx.process(tone(0.0005, 200));
    }
    final quiet = fx.process(tone(0.0005, 200))[FeatureIndex.level];
    final loud = fx.process(tone(0.5, 200));
    expect(quiet, lessThan(0.2));
    expect(loud[FeatureIndex.level], greaterThan(0.6));
    expect(loud[FeatureIndex.bass], greaterThan(loud[FeatureIndex.treble]));
  });

  testWidgets('home screen renders every state without errors', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final controller = NexusStateController(bridge: _NoMicBridge());
    await tester.pumpWidget(MaterialApp(home: NexusHome(controller: controller)));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('NEXUS READY'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Start listening'));
    await tester.pump();
    for (var i = 0; i < 30; i++) {
      controller.feedInputLevel(0.5 + 0.5 * math.sin(i / 3));
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(controller.current, NexusAssistantState.listening);

    await tester.tap(find.bySemanticsLabel('NEXUS core'));
    await tester.pump(const Duration(milliseconds: 700));
    expect(controller.current, NexusAssistantState.processing);

    controller.setThinking();
    await tester.pump(const Duration(milliseconds: 700));
    controller.beginSpeaking();
    for (var i = 0; i < 30; i++) {
      controller.ttsWordPulse();
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(find.text('SPEAKING'), findsWidgets);
    controller.endSpeaking();
    await tester.pump(const Duration(seconds: 1));
    expect(controller.current, NexusAssistantState.idle);

    await tester.pumpWidget(const SizedBox());
    await controller.dispose();
  });
}
