class AppConstants {
  AppConstants._();

  static const String appName = 'AgentPrompt';
  static const String appTagline = 'AI-Powered Prompt Engineering';

  static const int dailyCredits = 10;
  static const int generateCost = 5;
  static const int editCost = 2;
  static const int addRequirementsCost = 2;

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://agentprompt.vercel.app',
  );

  static const Duration splashDuration = Duration(milliseconds: 2500);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 600);

  static const int maxPromptLength = 50000;
  static const int minDescriptionLength = 50;
  static const int promptsPageSize = 20;

  static const List<String> projectTypes = [
    'Android App',
    'iOS App',
    'Web App',
    'Website',
    'SaaS',
    'AI Tool',
    'Desktop Application',
    'Backend API',
    'Game',
    'Chrome Extension',
    'Other',
  ];

  static const List<String> statusMessages = [
    'Analyzing requirements...',
    'Structuring architecture...',
    'Defining specifications...',
    'Optimizing for development...',
    'Finalizing prompt...',
  ];
}
