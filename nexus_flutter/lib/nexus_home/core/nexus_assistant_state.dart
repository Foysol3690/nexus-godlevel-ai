/// The five assistant phases the home screen can visualise.
enum NexusAssistantState {
  idle,
  listening,
  processing,
  thinking,
  speaking;

  String get headline => switch (this) {
        NexusAssistantState.idle => 'NEXUS READY',
        NexusAssistantState.listening => 'LISTENING',
        NexusAssistantState.processing => 'PROCESSING',
        NexusAssistantState.thinking => 'THINKING',
        NexusAssistantState.speaking => 'SPEAKING',
      };

  String get hint => switch (this) {
        NexusAssistantState.idle => 'TAP THE CORE OR SAY "MAYA"',
        NexusAssistantState.listening => 'TAP THE CORE TO SEND',
        NexusAssistantState.processing => 'ROUTING SIGNAL',
        NexusAssistantState.thinking => 'SYNTHESIZING RESPONSE',
        NexusAssistantState.speaking => 'TAP TO INTERRUPT',
      };

  String get orbStatus => switch (this) {
        NexusAssistantState.idle => 'ONLINE',
        NexusAssistantState.listening => 'LISTENING',
        NexusAssistantState.processing => 'ROUTING',
        NexusAssistantState.thinking => 'THINKING',
        NexusAssistantState.speaking => 'SPEAKING',
      };
}
