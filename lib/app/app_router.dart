import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jhyapp/app/app_routes.dart';
import 'package:jhyapp/app/router_transitions.dart';
import 'package:jhyapp/models/drink_catalog_item.dart';
import 'package:jhyapp/models/drink_draft.dart';
import 'package:jhyapp/views/add_drink/add_drink_view.dart';
import 'package:jhyapp/views/calendar_view.dart';
import 'package:jhyapp/views/drink_detail_view.dart';
import 'package:jhyapp/views/home_view.dart';
import 'package:jhyapp/views/landing_page.dart';
import 'package:jhyapp/views/stats_view.dart';

import '../views/add_drink/new_drink_view.dart';
import '../views/add_drink/review_drink_view.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Profile Page'));
  }
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.home,

  routes: [
    GoRoute(
      path: AppRoutes.addDrink,
      pageBuilder: (context, state) {
        return slideFromRightTransition(
          key: state.pageKey,
          child: const AddDrinkView(),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.newDrink,
      pageBuilder: (context, state) {
        final initialDrink = state.extra is DrinkCatalogItem
            ? state.extra as DrinkCatalogItem
            : null;
        return slideFromRightTransition(
          key: state.pageKey,
          child: NewDrinkView(initialDrink: initialDrink),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.reviewDrink,
      pageBuilder: (context, state) {
        final draft = state.extra is DrinkDraft
            ? state.extra as DrinkDraft
            : null;
        return slideFromRightTransition(
          key: state.pageKey,
          child: ReviewDrinkView(draft: draft ?? DrinkDraft.empty()),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.drinkDetail,
      pageBuilder: (context, state) {
        final drink = state.extra as Map<String, dynamic>;
        return slideFromRightTransition(
          key: state.pageKey,
          child: DrinkDetailView(drink: drink),
        );
      },
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return LandingPage(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomeView(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.calendar,
              builder: (context, state) => const CalendarView(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.stats,
              builder: (context, state) => const StatsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: AppRoutes.profile,
              builder: (context, state) => const ProfilePage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
