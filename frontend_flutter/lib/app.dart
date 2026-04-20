import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/router.dart';
import 'core/theme.dart';
import 'providers/property_provider.dart';

class AiRentAdvisorApp extends StatelessWidget {
  const AiRentAdvisorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PropertyProvider(),
      child: MaterialApp.router(
        title: 'AI Rent Advisor',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        routerConfig: appRouter,
      ),
    );
  }
}
