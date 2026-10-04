import '../secure_config_manager.dart';
import 'advanced_device_service.dart';
import 'maya_settings_service.dart';
import 'live_voice_service.dart';

class MayaHealthService {
  final SecureConfigManager _config = SecureConfigManager();
  final MayaSettingsService _settings = MayaSettingsService();

  Future<Map<String, dynamic>> snapshot() async {
    final providers = await _config.getAvailableBackends();
    final accessibility = await AdvancedDeviceService.isAccessibilityEnabled();
    final settings = await _settings.snapshot();
    final issues = <String>[];
    if (providers['gemini'] != true) {
      issues.add(
        'Gemini key missing: Live voice and Gemini vision/TTS are unavailable.',
      );
    }
    if (!accessibility) {
      issues.add(
        'Accessibility disabled: lock, screen actions, and confirmed UI automation are unavailable.',
      );
    }
    if (providers['telegram'] != true) {
      issues.add('Telegram bot token is not configured.');
    }
    return {
      'success': true,
      'liveModelPrimary': LiveVoiceService.primaryModel,
      'accessibility': accessibility,
      'providers': providers,
      'privacyShield': settings['privacyShield'] == true,
      'actionLedger': settings['actionLedger'] == true,
      'issueCount': issues.length,
      'issues': issues,
      'limits': [
        'Secure keyguard cannot be bypassed.',
        'External integrations require their own accounts or API keys.',
        'Android force-stop can stop app-process services.',
      ],
    };
  }
}
