import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'demo/echo_demo_bridge.dart';
import 'nexus_home/nexus_home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  SystemChrome.setPreferredOrientations(<DeviceOrientation>[DeviceOrientation.portraitUp]);
  runApp(const NexusApp());
}

class NexusApp extends StatelessWidget {
  const NexusApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'NEXUS',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          fontFamily: 'Sora',
          scaffoldBackgroundColor: const Color(0xFF02040A),
        ),
        // Swap EchoDemoBridge for your bridge that wraps the existing STT/TTS/AI.
        home: NexusHome(bridge: EchoDemoBridge()),
      );
}
