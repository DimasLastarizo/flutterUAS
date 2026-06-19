import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:kursuskilat/config/supabase_config.dart';

import 'package:kursuskilat/providers/app_data_provider.dart';

import 'package:kursuskilat/screens/app_theme.dart';

import 'package:kursuskilat/screens/auth_page.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final supabaseUrl = SupabaseConfig.resolveUrl();
  debugPrint('Supabase URL: $supabaseUrl');
  await Supabase.initialize(
    url: supabaseUrl,
    // ignore: deprecated_member_use
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppTheme()),

        ChangeNotifierProvider(create: (_) => UserProvider()),

        ChangeNotifierProvider(create: (_) => AppDataProvider()),
      ],

      child: const MyStoreApp(),
    ),
  );
}
