import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:agent_prompt/core/theme/app_theme.dart';
import 'package:agent_prompt/core/theme/theme_provider.dart';
import 'package:agent_prompt/core/router/app_router.dart';

class AgentPromptApp extends ConsumerWidget {
  const AgentPromptApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(appRouterProvider);

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp.router(
          title: 'AgentPrompt',
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: AppTheme.lightTheme(lightDynamic),
          darkTheme: AppTheme.darkTheme(darkDynamic),
          routerConfig: router,
        );
      },
    );
  }
}
