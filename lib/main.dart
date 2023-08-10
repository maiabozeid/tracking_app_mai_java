import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tracking_app/controller/map_controller.dart';
import 'package:tracking_app/helper/cache_helper.dart';
import 'package:tracking_app/screen/splash/splash_screen.dart';
import 'package:tracking_app/util/app_constants.dart';
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
  runApp(const MyApp());
  // runZonedGuarded<Future<void>>(() async {
  //   WidgetsFlutterBinding.ensureInitialized();
  //   HttpOverrides.global = MyHttpOverrides();
  //   runApp(const MyApp());
  // }, (error, stackTrace) {
  //   // Custom function to be called on app crash
  //   // handleAppCrash();
  //   // MapController.to.myFunction();
  // });
  Map<String, Map<String, String>> languages = await di.init();
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
