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

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseCrashlytics.instance.log("Higgs-Boson detected! Bailing out");

    // Get the user identifier from CacheHelper
    String? userIdentifier = CacheHelper.getData(key: AppConstants.trackVehicleNumber);
    if (userIdentifier != null) {
      // Set the user identifier for Crashlytics
      FirebaseCrashlytics.instance.setUserIdentifier(userIdentifier);
    } else {
      // Handle the case when userIdentifier is null
      // For example, you could use a default user identifier or log a message
    }
    var now = DateTime.now();
    var formatter = DateFormat('dd-MM-yyyy');
    String formattedDate = formatter.format(now);
    final controller = Get.put(MapController());
    return SafeArea(
        child: Scaffold(
      body: Obx(() => controller.state == ViewState.busy
          ? const Center(
              child: SpinKitFadingCube(
                color: Color(0xff008d36),
                size: 50.0,
              ),
            )
          : controller.directionsModel?.districtLocations == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: Dimensions.height * 0.25,
                      child: Stack(
                        children: [
                          Container(
                            height: Dimensions.height * 0.2,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                                color: Color(0xff008d36),
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(70),
                                    bottomRight: Radius.circular(70))),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          "اهلا : ${CacheHelper.getData(key: AppConstants.name)}",
                                          style: robotoRegular.copyWith(
                                              color: Colors.white,
                                              fontSize: 14)),
                                      Row(
                                        children: [
                                          Text(
                                              "${CacheHelper.getData(key: AppConstants.trackVehicleNumber)}",
                                              style: robotoRegular.copyWith(
                                                  color: Colors.white,
                                                  fontSize: 14)),
                                          Text(
                                              "${CacheHelper.getData(key: AppConstants.trackVehicleDevice)}",
                                              style: robotoRegular.copyWith(
                                                  color: Colors.white,
                                                  fontSize: 14)),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.access_time,
                                              color: Colors.white),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            controller.time.value,
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                          Row(
                                            children: [
                                              const Icon(Icons.date_range,
                                                  color: Colors.white),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Text(formattedDate,
                                                  style: const TextStyle(
                                                      color: Colors.white))
                                            ],
                                          ),
                                        ],
                                      ),
                                      Text(
                                          "البلديه : ${CacheHelper.getData(key: AppConstants.cityName)}",
                                          style: robotoRegular.copyWith(
                                              color: Colors.white,
                                              fontSize: 16)),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            CacheHelper.clearData();
                                            Get.offAll(
                                                () => const SignInScreen());
                                          },
                                          icon: Image.asset(Images.logIcon)),
                                      Obx(() => ConnectivityController.to.connectionStatus.value != 0
                                          ? Row(
                                              children: [
                                                Image.asset(
                                                  Images.online,
                                                  color: Colors.white,
                                                  width: 25,
                                                ),
                                                const Text(
                                                  "online",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                )
                                              ],
                                            )
                                          : Column(
                                              children: [
                                                Image.asset(
                                                  Images.offline,
                                                  color: Colors.white,
                                                  width: 25,
                                                ),
                                                const Text(
                                                  "offline",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                )
                                              ],
                                            )),
                                      Obx(() =>
                                          controller.serversEnabledBool.value
                                              ? Row(
                                                  children: const [
                                                    Icon(
                                                      Icons.location_on,
                                                      color: Colors.white,
                                                    ),
                                                    Text(
                                                      "GpsEnabled",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  ],
                                                )
                                              : Row(
                                                  children: const [
                                                    Icon(
                                                      Icons.location_off,
                                                      color: Colors.white,
                                                    ),
                                                    Text(
                                                      "DisEnabled",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    )
                                                  ],
                                                )),
                                      const Text(
                                        AppConstants.appVersion,
                                        style: TextStyle(color: Colors.white),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            left: 0,
                            child: Image.asset(
                              Images.logo,
                              height:  Dimensions.height * 0.13,
                            ),
                          )
                        ],
                      ),
                    ),
                    Lottie.asset(Images.noData),
                    Text("لاتوجد مسارات متاحه",
                        style: robotoRegular.copyWith(
                            color: const Color(0xff008d36), fontSize: 18)),
                  ],
                )
              : Column(
                  children: [
                    SizedBox(
                      height: Dimensions.height * 0.25,
                      child: Stack(
                        children: [
                          Container(
                            height: Dimensions.height * 0.2,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                                color: Color(0xff008d36),
                                borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(70),
                                    bottomRight: Radius.circular(70))),
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          "اهلا : ${CacheHelper.getData(key: AppConstants.name)}",
                                          style: robotoRegular.copyWith(
                                              color: Colors.white,
                                              fontSize: 14)),
                                      Row(
                                        children: [
                                          Text(
                                              "${CacheHelper.getData(key: AppConstants.trackVehicleNumber)}",
                                              style: robotoRegular.copyWith(
                                                  color: Colors.white,
                                                  fontSize: 14)),
                                          Text(
                                              "${CacheHelper.getData(key: AppConstants.trackVehicleDevice)}",
                                              style: robotoRegular.copyWith(
                                                  color: Colors.white,
                                                  fontSize: 14)),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const Icon(Icons.access_time,
                                              color: Colors.white),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            controller.time.value,
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                          Row(
                                            children: [
                                              const Icon(Icons.date_range,
                                                  color: Colors.white),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Text(formattedDate,
                                                  style: const TextStyle(
                                                      color: Colors.white))
                                            ],
                                          ),
                                        ],
                                      ),
                                      Text(
                                          "البلديه : ${CacheHelper.getData(key: AppConstants.cityName)}",
                                          style: robotoRegular.copyWith(
                                              color: Colors.white,
                                              fontSize: 16)),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      IconButton(
                                          onPressed: () {
                                            CacheHelper.clearData();
                                            Get.offAll(
                                                () => const SignInScreen());
                                          },
                                          icon: Image.asset(Images.logIcon)),
                                      Obx(() => ConnectivityController
                                                  .to.connectionStatus.value !=
                                              0
                                          ? Row(
                                              children: [
                                                Image.asset(
                                                  Images.online,
                                                  color: Colors.white,
                                                  width: 25,
                                                ),
                                                const Text(
                                                  "online",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                )
                                              ],
                                            )
                                          : Column(
                                              children: [
                                                Image.asset(
                                                  Images.offline,
                                                  color: Colors.white,
                                                  width: 25,
                                                ),
                                                const Text(
                                                  "offline",
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                )
                                              ],
                                            )),
                                      Obx(() =>
                                          controller.serversEnabledBool.value
                                              ? Row(
                                                  children: const [
                                                    Icon(
                                                      Icons.location_on,
                                                      color: Colors.white,
                                                    ),
                                                    Text(
                                                      "GpsEnabled",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    )
                                                  ],
                                                )
                                              : Row(
                                                  children: const [
                                                    Icon(
                                                      Icons.location_off,
                                                      color: Colors.white,
                                                    ),
                                                    Text(
                                                      "DisEnabled",
                                                      style: TextStyle(
                                                          color: Colors.white),
                                                    )
                                                  ],
                                                )),
                                      Row(
                                        children: [
                                          Icon(Icons.note,color: Colors.white),
                                          const SizedBox(width: 9,),
                                          const Text(
                                            AppConstants.appVersion,
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ],
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            left: 0,
                            child: Image.asset(
                              Images.logo,
                              height:  Dimensions.height * 0.13,
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: Dimensions.height * 0.04,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          if (controller.bookingId.value == 0) {
                            Get.defaultDialog(
                                radius: 6,
                                title: "يجب حجز المسار اولا",
                                titleStyle: const TextStyle(
                                    color: Colors.red, fontSize: 20),
                                content: Lottie.asset(Images.error, height: 90),
                                confirm: SizedBox(
                                  width: 120,
                                  child: TextButton(
                                      onPressed: () async {
                                        controller.bookMission();
                                      },
                                      style: TextButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xff008d36)),
                                      child: const Text(
                                        "حجز",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      )),
                                ));
                          } else if (controller.latitudeContinue.value != 0.0 &&
                              controller.longitudeContinue.value != 0.0 &&
                              controller.distanceContinue.value > 70) {
                            Get.defaultDialog(
                                radius: 6,
                                title:
                                    "انت بعيد عن نقطه التوقف بمسافه\n ${controller.distanceContinue.value.toStringAsFixed(2)} م ",
                                titleStyle: const TextStyle(
                                    color: Colors.amber, fontSize: 18),
                                content: const Text(""),
                                confirm: SizedBox(
                                  width: 150,
                                  child: TextButton(
                                      onPressed: () async {
                                        controller.openMap(
                                            latLng: LatLng(
                                                controller
                                                    .latitudeContinue.value,
                                                controller
                                                    .longitudeContinue.value));
                                      },
                                      style: TextButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xff008d36)),
                                      child: const Text(
                                        "اذهب لنقطه الاستكمال",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      )),
                                ));
                          } else if (controller.userDistance.value > 500 &&
                              controller.distanceContinue.value == 0.0) {
                            Get.defaultDialog(
                                radius: 6,
                                title:
                                    "انت بعيد عن بدايه المسار بمسافه ${controller.userDistance.value.toStringAsFixed(2)}",
                                titleStyle: const TextStyle(
                                    color: Colors.green, fontSize: 18),
                                content: const Text(""),
                                confirm: SizedBox(
                                  width: 150,
                                  child: TextButton(
                                      onPressed: () async {
                                        controller.openMap(
                                            latLng: LatLng(
                                                controller
                                                    .directionsModel!
                                                    .districtLocations!
                                                    .first
                                                    .lat!,
                                                controller
                                                    .directionsModel!
                                                    .districtLocations!
                                                    .first
                                                    .long!));
                                      },
                                      style: TextButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xff008d36)),
                                      child: const Text(
                                        "اذهب لنقطه البدايه",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16),
                                      )),
                                ));
                          } else {
                            Get.to(() => const MapScreen());
                          }
                        },
                        child: Card(
                          elevation: 2,
                          shadowColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(
                                color: Colors.grey,
                              )),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        "البلديه : ${controller.directionsModel?.CityName}",
                                        style: robotoRegular.copyWith(
                                            color: const Color(0xff008d36),
                                            fontSize: 16)),
                                    Text(
                                        "الحى : ${controller.directionsModel?.districtName}",
                                        style: robotoRegular.copyWith(
                                            color: const Color(0xff008d36),
                                            fontSize: 16)),

                                    Text(
                                        "المسافه :  ${controller.userDistance.value.toStringAsFixed(3)}",
                                        style: robotoRegular.copyWith(
                                            color: const Color(0xff008d36),
                                            fontSize: 16)),

                                    SizedBox(
                                      height: 16,
                                    ),

                                    Container(
                                      width: 100,
                                      height: 100,
                                      child: ListView.builder(
                                        itemCount: controller.directionModelItems?.directionsModels?.length ?? 0,
                                       shrinkWrap: true,
                                       physics:
                                       const BouncingScrollPhysics(),
                                       itemBuilder:
                                                  (_, x) {
                                                 controller.selectedOption.value =
    List.filled(controller.directionModelItems?.directionsModels?.length??0 , false);
                                                 print(controller
                                                     .directionModelItems?.directionsModels?.length);
    return Card(
    color: Colors.white,
    child:
    Container(
    decoration: BoxDecoration(
    border: Border.all(
    color: Theme
        .of(context)
        .primaryColor,
    ),
    // Set the desired frame color
    borderRadius:
    BorderRadius.circular(
    8.0),
    ),
    child: Row(
    children: [
    Obx(() =>
    Checkbox(
    value: controller
        .selectedOption[x],
    onChanged: (value) {
    controller
        .selectedOption[x] =
    value!;
    // CacheHelper.saveData(key: AppConstants.multiOptionAnswers, value: value);
    })),
      Text(

          "المسارات : ${controller.directionModelItems?.directionsModels?[x].routeNumber??""}",

          style: robotoRegular.copyWith(
              color: const Color(0xff008d36),
              fontSize: 16)),

    ],
    ),

    ),

    );

    })
                                    ),

                                ]),
                                Column(
                                  children: [
                                    Obx(() => controller.bookValue.value
                                        ? const Center(
                                            child: CircularProgressIndicator(
                                              color: Color(0xff008d36),
                                            ),
                                          )
                                        : CustomButton(
                                            color: const Color(0xff008d36)
                                                .withOpacity(0.9),
                                            buttonText:
                                                controller.bookingId.value == 0
                                                    ? "حجز المسار"
                                                    : "استكمال المسار",
                                            onPressed: () {
                                              controller.bookingId.value == 0
                                                  ? {
                                                      Get.defaultDialog(
                                                          content:
                                                              const SizedBox(),
                                                          titleStyle:
                                                              const TextStyle(
                                                                  color: Colors
                                                                      .green),
                                                          buttonColor:
                                                              Colors.green,
                                                          title:
                                                              "هل تريد تأكيد الحجز ؟",
                                                          onConfirm: () {
                                                            controller
                                                                .bookMission();
                                                          },
                                                          onCancel: () {
                                                            Get.back();
                                                          },
                                                          cancelTextColor:
                                                              Colors.red,
                                                          confirmTextColor:
                                                              Colors.white,
                                                          textConfirm: "تأكيد",
                                                          textCancel: "لا")
                                                    }
                                                  : {
                                                      if (controller.longitudeContinue.value != 0.0 &&
                                                          controller
                                                                  .latitudeContinue
                                                                  .value !=
                                                              0.0 &&
                                                          controller
                                                                  .distanceContinue
                                                                  .value >
                                                              150)
                                                        {
                                                          Get.defaultDialog(
                                                              radius: 6,
                                                              title:
                                                                  "انت بعيد عن نقطه التوقف بمسافه\n ${controller.distanceContinue.value.toStringAsFixed(2)} م ",
                                                              titleStyle:
                                                                  const TextStyle(
                                                                      color: Colors
                                                                          .amber,
                                                                      fontSize:
                                                                          18),
                                                              content:
                                                                  const Text(
                                                                      ""),
                                                              confirm: SizedBox(
                                                                width: 150,
                                                                child:
                                                                    TextButton(
                                                                        onPressed:
                                                                            () async {
                                                                          controller.openMap(
                                                                              latLng: LatLng(controller.latitudeContinue.value, controller.longitudeContinue.value));
                                                                        },
                                                                        style: TextButton.styleFrom(
                                                                            backgroundColor: const Color(
                                                                                0xff008d36)),
                                                                        child:
                                                                            const Text(
                                                                          "اذهب لنقطه الاستكمال",
                                                                          style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: 16),
                                                                        )),
                                                              )),
                                                        }
                                                      else if (controller
                                                                  .userDistance
                                                                  .value >
                                                              500 &&
                                                          controller
                                                                  .distanceContinue
                                                                  .value ==
                                                              0.0)
                                                        {
                                                          Get.defaultDialog(
                                                              radius: 6,
                                                              title:
                                                                  "انت بعيد عن بدايه المسار بمسافه ${controller.userDistance.value.toStringAsFixed(2)}",
                                                              titleStyle:
                                                                  const TextStyle(
                                                                      color: Colors
                                                                          .green,
                                                                      fontSize:
                                                                          18),
                                                              content:
                                                                  const Text(
                                                                      ""),
                                                              confirm: SizedBox(
                                                                width: 150,
                                                                child:
                                                                    TextButton(
                                                                        onPressed:
                                                                            () async {
                                                                          controller.openMap(
                                                                              latLng: LatLng(controller.directionsModel!.districtLocations!.first.lat!, controller.directionsModel!.districtLocations!.first.long!));
                                                                        },
                                                                        style: TextButton.styleFrom(
                                                                            backgroundColor: const Color(
                                                                                0xff008d36)),
                                                                        child:
                                                                            const Text(
                                                                          "اذهب لنقطه البدايه",
                                                                          style: TextStyle(
                                                                              color: Colors.white,
                                                                              fontSize: 16),
                                                                        )),
                                                              )),
                                                        }
                                                      else
                                                        {
                                                          Get.to(() =>
                                                              const MapScreen()),
                                                        }
                                                    };
                                            },
                                            width: Dimensions.width * 0.3,
                                            height: Dimensions.height * 0.05,
                                          )),
                                    Obx(() => controller.bookingId.value == 0
                                        ? SizedBox(
                                            width: 120,
                                            child: TextButton(
                                              onPressed: () {
                                                controller.onInit();
                                              },
                                              style: TextButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xff008d36)
                                                        .withOpacity(0.9),
                                              ),
                                              child: const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(Icons.refresh,
                                                      color: Colors.white),
                                                  Text("تحديث",
                                                      style: TextStyle(
                                                          color: Colors.white)),
                                                ],
                                              ),
                                            ))
                                        : const SizedBox()),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Obx(() => (controller.latitudeContinue.value == 0.0 &&
                            controller.longitudeContinue.value == 0.0)
                        ? Expanded(
                            child: GoogleMap(
                                zoomControlsEnabled: true,
                                markers: {...controller.markers},
                                polylines:
                                    Set<Polyline>.of(controller.polyline),
                                gestureRecognizers: {}
                                  ..add(Factory<PanGestureRecognizer>(
                                      () => PanGestureRecognizer()))
                                  ..add(Factory<ScaleGestureRecognizer>(
                                      () => ScaleGestureRecognizer()))
                                  ..add(Factory<TapGestureRecognizer>(
                                      () => TapGestureRecognizer()))
                                  ..add(Factory<VerticalDragGestureRecognizer>(
                                      () => VerticalDragGestureRecognizer())),
                                myLocationEnabled: true,

                                initialCameraPosition: CameraPosition(
                                    target: LatLng(controller.position.latitude,
                                        controller.position.longitude),
                                    zoom: 18)),
                          )
                        : Expanded(
                            child: GoogleMap(
                                zoomControlsEnabled: true,
                                markers: {...controller.markersContinue},
                                polylines:
                                    Set<Polyline>.of(controller.polyline),
                                gestureRecognizers: {}
                                  ..add(Factory<PanGestureRecognizer>(
                                      () => PanGestureRecognizer()))
                                  ..add(Factory<ScaleGestureRecognizer>(
                                      () => ScaleGestureRecognizer()))
                                  ..add(Factory<TapGestureRecognizer>(
                                      () => TapGestureRecognizer()))
                                  ..add(Factory<VerticalDragGestureRecognizer>(
                                      () => VerticalDragGestureRecognizer())),
                                myLocationEnabled: true,
                                onMapCreated: (map) {
                                  map.showMarkerInfoWindow(controller
                                      .markersContinue.first.markerId);
                                },

                                initialCameraPosition: CameraPosition(
                                    target: LatLng(
                                        controller.latitudeContinue.value,
                                        controller.longitudeContinue.value),
                                    zoom: 18)),
                          )),
                    // TextButton(
                    //   onPressed: () => throw Exception(),
                    //   child: const Text("Throw Test Exception"),
                    // ),
                  ]

                )),

    ));
  }

}
