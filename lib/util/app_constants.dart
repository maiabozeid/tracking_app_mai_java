class AppConstants {
  static const String appName = 'Paths App';
  static const String appVersion = 'v2.6';
   // static const String baseUrl = 'http://192.168.0.122:5000/api';

   static const String baseUrl = 'https://apiapp.co4qu.com/api';

  static const String login = '/Account/Loginapp';
  static const String getPaths = '/DriverPaths/GetAvailablePaths2?';
  static const String bookPath = '/DriverPaths/AddDriverPath';
  static const String startMission = '/DriverPaths/StartPath';
  static const String endMission = '/DriverPaths/EndTemporaryPath';
  static const String end = '/DriverPaths/EndPath';
  static const String addVehicleInfos = '/VehiclesInfos/AddVehicleInfos';
  static const String continueMission = '/DriverPaths/StartFromTemporaryPath';
  static const String completeTask = '/DistrictLocations/CompleteTask/';
  static const String addHistoryVehicleInfo =
      '/VehiclesInfos/AddHistoryVehicleInfo';

  // Shared Key
  static const String missionVaValue = "MissionVaValue";
  static const String bookingId = "bookingId";
  static const String tapped = "tapped";
  static const String theme = 'theme';
  static const String expireOn = 'expireOn';
  static const String trackVehicleNumber = 'trackVehicleNumber';
  static const String cityName = 'cityName';
  static const String trackVehicleDevice = 'trackVehicleDevice';
  static const String role = 'role';
  static const String length = 'length';
  static const String token = 'multivendor_token';
  static const String countryCode = 'country_code';
  static const String languageCode = 'language_code';
  static const String name = "Name";
  static const String apiKey = "AIzaSyBGOAVKbeA0MiN6NfGm8Z0y5LtE7cgdCo4";

// static List<LanguageModel> languages = [
//   LanguageModel(
//       imageUrl: Images.english,
//       languageName: 'English',
//       countryCode: 'US',
//       languageCode: 'en'),
//   LanguageModel(
//       imageUrl: Images.arabic,
//       languageName: 'عربى',
//       countryCode: 'SA',
//       languageCode: 'ar'),
// ];
}
