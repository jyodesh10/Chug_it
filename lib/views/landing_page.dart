import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:jhyapp/app/app_routes.dart';
import 'package:jhyapp/constants/colors.dart';
import 'package:jhyapp/constants/logos.dart';
import 'package:jhyapp/views/app_navigation_bar.dart';
import 'package:sizer/sizer.dart';

class LandingPage extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation floatingActionButtonLocation;
  final Color backgroundColor;

  const LandingPage({
    super.key,
    required this.navigationShell,
    this.floatingActionButton,
    this.floatingActionButtonLocation = FloatingActionButtonLocation.centerDocked,
    this.backgroundColor = const Color(0xFF171A1D),
  });

  @override
  Widget build(BuildContext context) {
    final fab = floatingActionButton ?? SizedBox(
      height: 15.w,
      width: 15.w,
      child: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.addDrink),
        backgroundColor: darkblueClr,
        shape: const CircleBorder(),
        child: SvgPicture.asset(AppLogos.beer, width: 22, height: 35),
      ),
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(child: navigationShell),
      floatingActionButton: fab,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomNavigationBar: AppNavigationBar(
        navigationShell: navigationShell,
      ),
    );
  }
}
