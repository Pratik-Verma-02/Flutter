import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:agent_prompt/core/router/route_names.dart';
import 'package:agent_prompt/providers/auth_provider.dart';
import 'package:agent_prompt/features/splash/splash_screen.dart';
import 'package:agent_prompt/features/auth/login_screen.dart';
import 'package:agent_prompt/features/auth/signup_screen.dart';
import 'package:agent_prompt/features/auth/forgot_password_screen.dart';
import 'package:agent_prompt/features/home/home_screen.dart';
import 'package:agent_prompt/features/home/main_shell.dart';
import 'package:agent_prompt/features/prompt_wizard/prompt_wizard_screen.dart';
import 'package:agent_prompt/features/prompt_result/generating_screen.dart';
import 'package:agent_prompt/features/prompt_result/prompt_result_screen.dart';
import 'package:agent_prompt/features/saved_prompts/saved_prompts_screen.dart';
import 'package:agent_prompt/features/saved_prompts/prompt_detail_screen.dart';
import 'package:agent_prompt/features/profile/profile_screen.dart';
import 'package:agent_prompt/features/settings/settings_screen.dart';
import 'package:agent_prompt/models/prompt_request_model.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: RouteNames.splash,
    redirect: (context, state) {
      final isAuthenticated = authState.valueOrNull != null;
      final isSplash = state.matchedLocation == RouteNames.splash;
      final isAuthRoute = [
        RouteNames.login,
        RouteNames.signup,
        RouteNames.forgotPassword,
      ].contains(state.matchedLocation);

      if (isSplash) return null;
      if (!isAuthenticated && !isAuthRoute) return RouteNames.login;
      if (isAuthenticated && isAuthRoute) return RouteNames.home;
      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        pageBuilder: (context, state) => _fadePage(const SplashScreen(), state),
      ),
      GoRoute(
        path: RouteNames.login,
        pageBuilder: (context, state) => _slidePage(const LoginScreen(), state),
      ),
      GoRoute(
        path: RouteNames.signup,
        pageBuilder: (context, state) => _slidePage(const SignupScreen(), state),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        pageBuilder: (context, state) => _slidePage(const ForgotPasswordScreen(), state),
      ),
      GoRoute(
        path: RouteNames.promptWizard,
        pageBuilder: (context, state) => _slidePage(const PromptWizardScreen(), state),
      ),
      GoRoute(
        path: RouteNames.generating,
        pageBuilder: (context, state) {
          final request = state.extra as PromptRequestModel;
          return _fadePage(GeneratingScreen(request: request), state);
        },
      ),
      GoRoute(
        path: '${RouteNames.promptResult}/:id',
        pageBuilder: (context, state) {
          final promptId = state.pathParameters['id']!;
          final content = state.extra as String?;
          return _slidePage(
            PromptResultScreen(promptId: promptId, initialContent: content),
            state,
          );
        },
      ),
      GoRoute(
        path: '${RouteNames.promptDetail}/:id',
        pageBuilder: (context, state) {
          final promptId = state.pathParameters['id']!;
          return _slidePage(PromptDetailScreen(promptId: promptId), state);
        },
      ),
      GoRoute(
        path: RouteNames.settings,
        pageBuilder: (context, state) => _slidePage(const SettingsScreen(), state),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.home,
            pageBuilder: (context, state) => _fadePage(const HomeScreen(), state),
          ),
          GoRoute(
            path: RouteNames.savedPrompts,
            pageBuilder: (context, state) => _fadePage(const SavedPromptsScreen(), state),
          ),
          GoRoute(
            path: RouteNames.profile,
            pageBuilder: (context, state) => _fadePage(const ProfileScreen(), state),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
});

Page<dynamic> _fadePage(Widget child, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 250),
  );
}

Page<dynamic> _slidePage(Widget child, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}
