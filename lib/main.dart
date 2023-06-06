import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tracking_app/screen/splash/splash_screen.dart';
import 'helper/get_di.dart' as di;
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
      ((X509Certificate cert, String host, int port) {
        final isValidHost =
        ["192.168.0.199"].contains(host); // <-- allow only hosts in array
        return isValidHost;
      });
  }
}
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();

  Map<String, Map<String, String>> languages = await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      locale: Locale("ar"),
      fallbackLocale: Locale("ar"),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
