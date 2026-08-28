import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/login_page.dart';

class BankingApp extends StatelessWidget {
  const BankingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'IBT Digital Banking',
      theme: AppTheme.lightTheme,

      scrollBehavior: const NoOverscrollBehavior(),

      home: const LoginPage(),
    );
  }
}

class NoOverscrollBehavior extends MaterialScrollBehavior {
  const NoOverscrollBehavior();

  @override
  Widget buildOverscrollIndicator(
      BuildContext context,
      Widget child,
      ScrollableDetails details,
      ) {
    return child;
  }
}