import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:jhyapp/constants/colors.dart';
import 'package:jhyapp/constants/logos.dart';
import 'package:jhyapp/constants/textstyle.dart';
import 'package:sizer/sizer.dart';

class AppNavigationBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const AppNavigationBar({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    final selectedIndex = navigationShell.currentIndex;

    return BottomAppBar(
      color: backgroundClr,
      shape: const CircularNotchedRectangle(),
      notchMargin: 7,
      child: SizedBox(
        height: 7.h,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: _NavItem(
                asset: AppLogos.home,
                label: 'Home',
                active: selectedIndex == 0,
                onTap: () => navigationShell.goBranch(0),
              ),
            ),
            Expanded(
              child: _NavItem(
                asset: AppLogos.calendar,
                label: 'Calendar',
                active: selectedIndex == 1,
                onTap: () => navigationShell.goBranch(1),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _NavItem(
                asset: AppLogos.stats,
                label: 'Stats',
                active: selectedIndex == 2,
                onTap: () => navigationShell.goBranch(2),
              ),
            ),
            Expanded(
              child: _NavItem(
                asset: AppLogos.user,
                label: 'Profile',
                active: selectedIndex == 3,
                onTap: () => navigationShell.goBranch(3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String asset;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.asset,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(asset, width: 24, height: 24),
          Text(label, style: subtitleStyle.copyWith(color: active ? lightblueClr : greyClr, fontSize: 12.sp)),
        ],
      ),
    );
  }
}
