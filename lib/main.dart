import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' hide Size;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:locora/core/config/app_config.dart';
import 'package:locora/core/routing/app_router.dart';
import 'package:locora/shared/theme/app_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  MapboxOptions.setAccessToken(AppConfig.fromEnvironment().mapboxToken);
  runApp(const ProviderScope(child: LocoraApp()));
}

class LocoraApp extends StatelessWidget {
  const LocoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1280, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Locora',
          theme: ThemeData(
            colorScheme: AppColors.lightColorScheme,
            textTheme: GoogleFonts.interTextTheme(),
          ),
          routerConfig: appRouter,
        );
      },
    );
  }
}
