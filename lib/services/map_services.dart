import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:tracking_app/component/custom_snackbar.dart';
import 'package:tracking_app/helper/dio_integration.dart';
import 'package:tracking_app/model/info_model.dart';
import 'package:tracking_app/model/path_model.dart';
import 'package:tracking_app/util/app_constants.dart';
import 'package:tracking_app/util/utility.dart';

class MapServices {
  final dio = DioUtilNew.dio;

  getPaths({Position? position}) async {
    try {
      final response = await dio!.get(
          "${AppConstants.getPaths}ULat=${position?.latitude}&ULong=${position?.longitude}");

      if (response != null && response.statusCode == 200) {
        // print("DirectionModelItems: $response");
        // print("DirectionModelItems: $response.statusCode");
        // Handle a successful response
        final data = response.data;
        if (data is List) {
          // Parse the data if it's a list of directions
          final directionsList = List<DirectionsModel>.from(
            data.map((x) => DirectionsModel.fromJson(x)),
          );
          print("API Response: ${response.toString()}");
          print("API Response: ${response.statusCode}");

          // Process the directions list as needed
          // print("DirectionModelItems: $directionsList");
          return directionsList;
        }
        // ... other code ...
      } else {
        // Handle the case when the response is null or when the status code is not 200
        print("Error: The response is null or has a status code other than 200");
      }
    } catch (e) {
      // Handle exceptions here (e.g., network errors, timeouts)
      print("Error: $e");
    }
  }

  bookPath({int? routeNumber, int? districtId, double? lat, long}) async {
    try {
      final response = await dio!.post(AppConstants.bookPath, data: {"routeNumber": routeNumber,
        "districtId": districtId, "lat": lat, "long": long
      });
      if (response.statusCode == 200) {
        print(response.statusCode);

        Utility.displaySuccessAlert("تم حجز المسار بنجاح", Get.context!);
      } else if (response.statusCode == 400) {
        showCustomSnackBar(isError: true, message: "هذا المسار محجوز من قبل");
      } else {
        showCustomSnackBar(isError: true, message: "توجد مشكله فى السيرفر");
      }
    } catch (e) {}
  }

  startMission({String? lat, long}) async {
    try {
      final response = await dio!.put(AppConstants.startMission,
          queryParameters: {"lng": long, "lat": lat});
      print(response.statusCode);
      if (response.statusCode == 200) {}
    } catch (e) {}
  }

  stopMission() async {
    try {
      final response = await dio!.put(AppConstants.endMission);
      if (response.statusCode == 200) {
        print(response.statusCode);

        Utility.displaySuccessAlert("تم ايقاف المسار مؤقتا", Get.context!);
      } else {
        showCustomSnackBar(isError: true, message: "توجد مشكله فى السرفر");
      }
    } catch (e) {}
  }

  continueMission() async {
    try {
      final response = await dio!.put(AppConstants.continueMission);
      if (response.statusCode == 200) {
        print(response.statusCode);
      }
    } catch (e) {}
  }

  completeTask({int? districtId, int? routeId}) async {
    try {
      final response =
          await dio!.post("${AppConstants.completeTask}$districtId/$routeId");
      if (response.statusCode == 200) {
        print(response.statusCode);
      }
    } catch (e) {}
  }

  end() async {
    try {
      final response = await dio!.put(AppConstants.end);
      if (response.statusCode == 200) {
        print(response.statusCode);
      }
    } catch (e) {}
  }

  sendPoints({int? routeNumber, int? districtId, int? objectId}) async {
    try {
      final response =
          await dio!.post(AppConstants.addHistoryVehicleInfo, data: {
        "objectId": objectId,
        "districtId": districtId,
        "routNumber": routeNumber,
      });
      if (response.statusCode == 200) {
        print(response.statusCode);
      }
    } catch (e) {}
  }

  addVehicleInfo({List<InfoModel>? data}) async {
    try {
      final response =
          await dio!.post(AppConstants.addVehicleInfos, data: data);
      // print(response.data);
      if (response.statusCode == 200) {
        print(response.statusCode);
      }
    } catch (e) {}
  }
}
