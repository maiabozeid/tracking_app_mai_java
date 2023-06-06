import 'package:get/get.dart';
import 'package:get_it/get_it.dart';
import 'package:tracking_app/controller/connectivity_controller.dart';
import 'package:tracking_app/controller/map_controller.dart';
import 'package:tracking_app/helper/cache_helper.dart';
import 'package:tracking_app/helper/dio_integration.dart';

final instance = GetIt.instance;

Future<Map<String, Map<String, String>>> init() async {
  await CacheHelper.init();
  DioUtilNew.getInstance();
  Get.lazyPut(() => MapController(), fenix: true);
  Get.lazyPut(() => ConnectivityController(), fenix: true);

  // Get.lazyPut(() => LocalizationController(), fenix: true);
  // Controller
  // Get.lazyPut(() => ThemeController(sharedPreferences: Get.find()));

  // Retrieving localized data
  Map<String, Map<String, String>> languages = {};
  // for (LanguageModel languageModel in AppConstants.languages) {
  //   String jsonStringValues = await rootBundle
  //       .loadString('assets/language/${languageModel.languageCode}.json');
  //   Map<String, dynamic> mappedJson = jsonDecode(jsonStringValues);
  //   Map<String, String> json = {};
  //   mappedJson.forEach((key, value) {
  //     json[key] = value.toString();
  //   });
  //   languages['${languageModel.languageCode}_${languageModel.countryCode}'] =
  //       json;
  // }
  return languages;
}
