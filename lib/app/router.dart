import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/library/library_screen.dart';
import '../features/library/style_detail_screen.dart';
import '../features/notes/note_detail_screen.dart';
import '../features/notes/note_form_screen.dart';
import '../features/notes/notes_home_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/stats/stats_screen.dart';
import 'shell/placeholder_screens.dart';
import 'shell/scribe_shell.dart';

/// Builds the app router (DESIGN_SPEC §7, minus `/login`: local-first).
///
/// The `ShellRoute` owns the drawer for `/notes`, `/library`, `/stats` and
/// `/settings`; everything else is pushed on the root navigator so it
/// covers the shell and uses back/close instead of the drawer.
GoRouter createScribeRouter({String initialLocation = '/notes'}) {
  final rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  return GoRouter(
    navigatorKey: rootKey,
    initialLocation: initialLocation,
    routes: [
      ShellRoute(
        builder: (context, state, child) =>
            ScribeShell(currentPath: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: '/notes',
            pageBuilder: (context, state) =>
                _shellPage(state, const NotesHomeScreen()),
            routes: [
              // Before ':id' so "new" is never read as a note id.
              GoRoute(
                path: 'new',
                parentNavigatorKey: rootKey,
                pageBuilder: (context, state) => slideUpPage(
                  state,
                  NoteFormScreen(
                    initialStyleId: state.uri.queryParameters['style'],
                  ),
                ),
              ),
              GoRoute(
                path: ':id',
                parentNavigatorKey: rootKey,
                builder: (context, state) =>
                    NoteDetailScreen(noteId: state.pathParameters['id']!),
                routes: [
                  GoRoute(
                    path: 'edit',
                    parentNavigatorKey: rootKey,
                    pageBuilder: (context, state) => slideUpPage(
                      state,
                      NoteFormScreen(noteId: state.pathParameters['id']),
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/library',
            pageBuilder: (context, state) =>
                _shellPage(state, const LibraryScreen()),
            routes: [
              GoRoute(
                path: ':styleId',
                parentNavigatorKey: rootKey,
                builder: (context, state) => StyleDetailScreen(
                  styleId: state.pathParameters['styleId']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/stats',
            pageBuilder: (context, state) =>
                _shellPage(state, const StatsScreen()),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) =>
                _shellPage(state, const SettingsScreen()),
          ),
        ],
      ),
      GoRoute(
        path: '/account',
        builder: (context, state) => const AccountPlaceholderScreen(),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const AboutPlaceholderScreen(),
      ),
    ],
  );
}

/// Top-level destinations swap without a transition (DESIGN_SPEC §9: no
/// entry animations; the drawer's own motion is enough).
Page<void> _shellPage(GoRouterState state, Widget child) =>
    NoTransitionPage<void>(key: state.pageKey, child: child);

/// Full-screen dialog that slides up from the bottom (the note form).
Page<void> slideUpPage(GoRouterState state, Widget child) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      fullscreenDialog: true,
      transitionDuration: const Duration(milliseconds: 250),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final offset = Tween(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(animation);
        return SlideTransition(position: offset, child: child);
      },
    );
