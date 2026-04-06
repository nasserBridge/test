import 'package:bridgeapp/src/constants/colors.dart';
import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({
    super.key,
    required this.currentPage,
    required this.onTap,
  });

  final int currentPage;
  final ValueChanged<int> onTap;

  @override
  State<CustomBottomNavigationBar> createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _NavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              label: 'Home',
              index: 0,
              currentIndex: widget.currentPage,
              onTap: widget.onTap,
            ),
            _NavItem(
              icon: Icons.sync_alt,
              activeIcon: Icons.sync_alt,
              label: 'Bridge',
              index: 1,
              currentIndex: widget.currentPage,
              onTap: widget.onTap,
            ),
            _NavItem(
              icon: Icons.chat_bubble_outline,
              activeIcon: Icons.chat_bubble_rounded,
              label: 'Bridgette',
              index: 2,
              currentIndex: widget.currentPage,
              onTap: widget.onTap,
            ),
            _NavItem(
              icon: Icons.storefront_outlined,
              activeIcon: Icons.storefront_rounded,
              label: 'Marketplace',
              index: 3,
              currentIndex: widget.currentPage,
              onTap: widget.onTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool active = index == currentIndex;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap(index),
        child: SizedBox(
          height: 56,
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              if (active)
                Container(
                  height: 3,
                  width: 20,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    active ? activeIcon : icon,
                    color: active ? AppColors.primary : AppColors.textTertiary,
                    size: 22,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          active ? FontWeight.w600 : FontWeight.w400,
                      color: active
                          ? AppColors.primary
                          : AppColors.textTertiary,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
