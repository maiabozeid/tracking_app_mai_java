import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracking_app/helper/cache_helper.dart';
import 'package:tracking_app/screen/splash/splash_screen.dart';
import 'package:tracking_app/util/app_constants.dart';
import 'firebase_options.dart';
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


  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Pass all uncaught "fatal" errors from the framework to Crashlytics
  bool weWantFatalErrorRecording = true;
  FlutterError.onError = (errorDetails) async {
    await FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance
        .recordError(error, stack, fatal: true, reason: true);
    return true;
  };

  Isolate.current.addErrorListener(RawReceivePort((pair) async {
    Map<String, Map<String, String>> languages = await di.init();

    final List<dynamic> errorAndStacktrace = pair;
    await FirebaseCrashlytics.instance.recordError(
      errorAndStacktrace.first,
      errorAndStacktrace.last,
      fatal: true,
    );
  }).sendPort);
  String? userIdentifier ;
  // = CacheHelper.getData(key: AppConstants.token);
  if (userIdentifier != null) {
    FirebaseCrashlytics.instance.setUserIdentifier("1234");
  } else {
    // Handle the case when userIdentifier is null
    // For example, you could use a default user identifier or log a message
  };
  print(AppConstants.token);
  Map<String, Map<String, String>> languages = await di.init();
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
