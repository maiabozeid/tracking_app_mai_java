import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:tracking_app/component/custom_button.dart';
import 'package:tracking_app/controller/connectivity_controller.dart';
import 'package:tracking_app/controller/map_controller.dart';
import 'package:tracking_app/enum/view_state.dart';
import 'package:tracking_app/helper/cache_helper.dart';
import 'package:tracking_app/screen/auth/sign_in_screen.dart';
import 'package:tracking_app/screen/map_screen/map_screen.dart';
import 'package:tracking_app/util/app_constants.dart';
import 'package:tracking_app/util/dimensions.dart';
import 'package:tracking_app/util/images.dart';
import 'package:tracking_app/util/styles.dart';

import '../../component/custom_listTile.dart';

class MainScreenBooking extends StatelessWidget {
  const MainScreenBooking({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MapController());

    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(Icons.arrow_back_ios),
            ),
            centerTitle: true,
            title: Image.asset(
              Images.logo,
              width: Dimensions.width * 0.15,
              height: Dimensions.height * 0.06,
            ),
          ),
          body: Obx(() {
            if (controller.state == ViewState.busy) {
              return const Center(
                child: SpinKitFadingCube(
                  color: Color(0xff008d36),
                  size: 50.0,
                ),
              );
            } else if (controller.directionsModel== null) {
              return const SizedBox(); // You can return an empty SizedBox for no data
            } else {
              // If data is available, render a ListView.builder
              return ListView.builder(
              itemCount: controller.directionsModel?.length,
    itemBuilder: (context, index) {
    final directionsModel = controller.directionsModel?[index];
    final districtLocations = directionsModel?.districtLocations;

    print("Route Number: ${directionsModel?.routeNumber}");
    print("Number of districtLocations: ${districtLocations?.length}");

    return Column(
    children: [
    // Text("Route Number: ${directionsModel?.routeNumber?.toString()}"),
    for (var location in districtLocations!)
    ListTile(
    title: Text("District ID: ${location.districtId?.toString()}"),
    subtitle: Text("Route Number: ${location.routeNumber?.toString()}"),
    ),
    ],
    );
    },
    );


            }
          })),
    );
  }
}