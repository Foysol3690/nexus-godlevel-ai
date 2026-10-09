import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'feature_extractor.dart';

typedef FeatureCallback = void Function(int channel, Float32List features);

/// Runs [FeatureExtractor] in a long-lived background isolate. PCM chunks are
/// handed over as TransferableTypedData (zero-copy) and small feature vectors
/// come back, so the UI isolate never performs FFT work.
class AnalyzerWorker {
  AnalyzerWorker._(this._isolate, this._receive, this._send);

  final Isolate _isolate;
  final ReceivePort _receive;
  final SendPort _send;

  static Future<AnalyzerWorker> spawn(FeatureCallback onFeatures) async {
    final receive = ReceivePort();
    final isolate = await Isolate.spawn<SendPort>(
      _entry,
      receive.sendPort,
      debugName: 'nexus-audio-analyzer',
    );
    final ready = Completer<SendPort>();
    receive.listen((message) {
      if (message is SendPort) {
        ready.complete(message);
      } else if (message is List && message.length == 2) {
        onFeatures(message[0] as int, message[1] as Float32List);
      }
    });
    return AnalyzerWorker._(isolate, receive, await ready.future);
  }

  void process(int channel, Uint8List pcm16, int sampleRate) {
    _send.send(<Object>[
      channel,
      sampleRate,
      TransferableTypedData.fromList(<TypedData>[pcm16]),
    ]);
  }

  void dispose() {
    _receive.close();
    _isolate.kill(priority: Isolate.immediate);
  }

  static void _entry(SendPort replyTo) {
    final inbox = ReceivePort();
    replyTo.send(inbox.sendPort);
    final extractors = <int, FeatureExtractor>{};
    inbox.listen((message) {
      if (message is! List || message.length != 3) return;
      final channel = message[0] as int;
      final rate = message[1] as int;
      final bytes = (message[2] as TransferableTypedData).materialize().asUint8List();
      final extractor = extractors.putIfAbsent(
        channel,
        () => FeatureExtractor(sampleRate: rate),
      )..setSampleRate(rate);
      final features = extractor.process(bytes);
      replyTo.send(<Object>[channel, Float32List.fromList(features)]);
    });
  }
}
