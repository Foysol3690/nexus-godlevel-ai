import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'config_screen.dart';
import 'jarvis_home_screen.dart';
import 'maya_boot_screen.dart';
import 'overlay_entry.dart' as overlay_entry;
import 'secure_config_manager.dart';

@pragma('vm:entry-point')
void overlayMain() => overlay_entry.overlayMain();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Color(0xFF02050A),
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  final config = SecureConfigManager();
  var isConfigured = false;
  try {
    isConfigured = await config.isConfigured().timeout(const Duration(seconds: 4), onTimeout: () => false);
  } catch (_) { isConfigured = false; }
  runApp(MayaApp(isConfigured: isConfigured));
}

class MayaApp extends StatefulWidget {
  final bool isConfigured;
  const MayaApp({super.key, required this.isConfigured});
  @override State<MayaApp> createState() => _MayaAppState();
}

class _MayaAppState extends State<MayaApp> {
  late bool _isConfigured;
  bool _bootComplete = false;
  @override void initState() { super.initState(); _isConfigured = widget.isConfigured; }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MAYA NEXØRA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark, useMaterial3: true, fontFamily: 'MayaSans',
        scaffoldBackgroundColor: const Color(0xFF02050A),
        colorScheme: const ColorScheme.dark(primary: Color(0xFF00D9FF), secondary: Color(0xFFFF7A18), tertiary: Color(0xFFE6223D), surface: Color(0xFF090A11)),
      ),
      home: !_bootComplete
          ? MayaBootScreen(onComplete: () { if (mounted) setState(() => _bootComplete = true); })
          : _isConfigured ? const JarvisHomeScreen() : ConfigScreen(onConfigComplete: () { setState(() => _isConfigured = true); }),
    );
  }
}
