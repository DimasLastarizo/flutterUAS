import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kursuskilat/screens/app_theme.dart';
import 'package:kursuskilat/screens/splash_screens.dart';

class MyStoreApp extends StatelessWidget {
  const MyStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<AppTheme>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'kursuskilat',
      theme: theme.materialTheme,
      home: const SplashScreen(),
    );
  }
}