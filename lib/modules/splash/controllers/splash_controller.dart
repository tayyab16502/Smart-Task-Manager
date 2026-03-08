import 'package:flutter/material.dart';
import '../../dashboard/views/dashboard_screen.dart';

class SplashController {
  late AnimationController mainController;
  late Animation<double> fadeAnimation;
  late Animation<double> slideAnimation;
  late Animation<double> scaleAnimation;

  void init(TickerProvider vsync, BuildContext context) {
    mainController = AnimationController(vsync: vsync, duration: const Duration(milliseconds: 3000))..forward();

    fadeAnimation = CurvedAnimation(parent: mainController, curve: const Interval(0.2, 0.6, curve: Curves.easeIn));
    slideAnimation = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(parent: mainController, curve: const Interval(0.2, 0.6, curve: Curves.easeOut)),
    );
    scaleAnimation = CurvedAnimation(parent: mainController, curve: const Interval(0.0, 0.5, curve: Curves.elasticOut));

    Future.delayed(const Duration(milliseconds: 4500), () {
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const DashboardScreen(),
            transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  void dispose() {
    mainController.dispose();
  }
}