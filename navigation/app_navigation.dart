import 'package:bridgeapp/src/features/authentication/controllers/profile_controller.dart';
import 'package:bridgeapp/src/features/authentication/controllers/timer_controller.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/controllers/accounts_controller.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/screens/aggregation_screen.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/account_aggregation/header_bar.dart';
import 'package:bridgeapp/src/features/authentication/screens/accounts/widgets/common/menu_hamburger.dart';
import 'package:bridgeapp/src/features/authentication/screens/bridgette_ai/screens/bridgette_ai.dart';
import 'package:bridgeapp/src/features/authentication/screens/marketplace/marketplace_navigation.dart';
import 'package:bridgeapp/src/features/authentication/screens/transfers/transfer_page.dart';
import 'package:bridgeapp/src/repository/user_repository/user_repository.dart';
import 'package:bridgeapp/src/features/authentication/controllers/nav_listener.dart';
import 'package:flutter/material.dart';
import 'package:bridgeapp/src/features/authentication/screens/navigation/custom_navbar.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:async';

class AppNavigation extends StatefulWidget {
  const AppNavigation({super.key});

  @override
  State<AppNavigation> createState() => AppNavigationState();
}

class AppNavigationState extends State<AppNavigation> {
  late AppLifecycleController _appLifecycleController;
  final _accController = Get.put(AccountsController());
  final _navListeners = Get.put(NavListeners());
  late StreamSubscription<bool> _streamAppBar;
  late StreamSubscription<int> _streamPop;
  int _currentIndex = 0;
  bool _showAppBar = true;
  final GlobalKey _mainNavBarKey = GlobalKey();

  // Navigation keys to manage independent navigator states per tab
  final List<GlobalKey<NavigatorState>> _navigationKeys = List.generate(
    4,
    (index) => GlobalKey<NavigatorState>(),
  );

  @override
  void initState() {
    super.initState();
    _appLifecycleController = AppLifecycleController(
      onTimeout: () {
        ProfileController.instance.logoutDelete();
      },
    );

    _streamAppBar = _navListeners.appBarStream.listen((data) {
      setState(() {
        _showAppBar = data;
      });
    });

    _streamPop = _navListeners.popStream.listen((data) {
      setState(() {
        popTapped(data);
      });
    });
  }

  @override
  void dispose() {
    _appLifecycleController.dispose();
    _streamAppBar.cancel();
    _streamPop.cancel();
    super.dispose();
  }

  void popTapped(int index) {
    _navListeners.isOnMain(true);

    // Force the previous tab to fully reset UI state
    setState(() {
      _navigationKeys[_currentIndex] = GlobalKey<NavigatorState>();
      _currentIndex = index;
    });
  }

  void _onTabTapped(int index) {
    HapticFeedback.lightImpact();
    if (_currentIndex != index) {
      _navListeners.isOnMain(true);

      _navigationKeys[_currentIndex]
          .currentState
          ?.popUntil((route) => route.isFirst);

      if (index == 0) {
        UserRepository.instance.getUserDetails();
      }

      if (index == 1) {
        _navListeners.demoBool.value = true;
      }

      if (index == 2) {
        _navListeners.isOnMain(false);
        // The controller will be created inside BridgetteAI when it's first opened.
      }

      setState(() {
        _navigationKeys[_currentIndex] = GlobalKey<NavigatorState>();
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MenuHamburger(),
      drawerEnableOpenDragGesture: false, // 👈 disables swipe-to-open
      appBar: _showAppBar ? HeaderBar() : null, // ✅ Hides AppBar on subpages
      body: IndexedStack(
        index: _currentIndex,
        children: [
          Navigator(
            key: _navigationKeys[0],
            onGenerateRoute: (settings) => MaterialPageRoute(
              builder: (_) => AggregationScreen(),
              // builder: (_) => BridgetteAI(),
              settings: settings,
            ),
          ),
          Navigator(
            key: _navigationKeys[1],
            onGenerateRoute: (settings) => MaterialPageRoute(
              builder: (_) => const TransfersPage(),
              settings: settings,
            ),
          ),
          // / 🧠 LAZY INIT BridgetteAI ONLY when selected
          _currentIndex == 2
              ? Navigator(
                  key: _navigationKeys[2],
                  onGenerateRoute: (settings) => MaterialPageRoute(
                    builder: (_) => BridgetteAI(
                      mainNavBarKey: _mainNavBarKey,
                    ),
                    settings: settings,
                  ),
                )
              : const SizedBox.shrink(), // placeholder
          _currentIndex == 3
              ? Navigator(
                  key: _navigationKeys[3],
                  onGenerateRoute: (settings) => MaterialPageRoute(
                    builder: (_) => MarketplaceNavigation(),
                    settings: settings,
                  ),
                )
              : const SizedBox.shrink(), // placeholder
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        key: _mainNavBarKey,
        currentPage: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
