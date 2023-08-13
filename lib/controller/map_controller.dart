import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:tracking_app/component/permission_dialog.dart';
import 'package:tracking_app/controller/base_controller.dart';
import 'package:tracking_app/enum/view_state.dart';
import 'package:tracking_app/helper/cache_helper.dart';
import 'package:tracking_app/helper/polyutil_helper.dart';
import 'package:tracking_app/helper/sound_helper.dart';
import 'package:tracking_app/model/info_model.dart';
import 'package:tracking_app/model/path_model.dart';
import 'package:tracking_app/screen/home_screen/home_screen.dart';
import 'package:tracking_app/services/map_services.dart';
import 'package:tracking_app/util/app_constants.dart';
import 'package:tracking_app/util/images.dart';

class MapController extends BaseController {
  static MapController to = Get.find();
  final services = MapServices();
  final util = PolyUtilHelper();
  final soundHelper = SoundHelper();
  late Position position;
  StreamSubscription<Position>? positionStreamSubscription;
  StreamSubscription<Position>? positionStream;
  final currentLocationMarker = const Marker(
    markerId: MarkerId('currentLocation'),
    position: LatLng(0, 0),
  ).obs;
  final markers = <Marker>{}.obs;
  final markersContinue = <Marker>{}.obs;
  final polyline = <Polyline>{}.obs;
  final streamPoint = <LatLng>[].obs;
  final pathPoint = <LatLng>[].obs;
  final polylineCoordinates = <LatLng>[].obs;
  Completer<GoogleMapController> completer = Completer();
  DirectionsModel? directionsModel;
  final statusId = 0.obs;
  final missionValue = 0.obs;
  final bookingId = 0.obs;
  final userDistance = 0.0.obs;
  final infoList = <InfoModel>[].obs;
  Timer? timer;
  final latitude = 0.0.obs;
  final longitude = 0.0.obs;
  final locationMarker = true.obs;
  final bookValue = false.obs;
  late PolylinePoints polylinePoints;
  final latitudeContinue = 0.0.obs;
  final longitudeContinue = 0.0.obs;
  final distanceContinue = 0.0.obs;
  Stream<DateTime>? _timeStream;
  StreamSubscription<DateTime>? timeSubscription;
  final time = "".obs;
  final serversEnabledBool = false.obs;

  @override
  Future<void> onInit() async {
    // TODO: implement onInit
    super.onInit();
    setState(ViewState.busy);
    markers.clear();
    pathPoint.clear();
    polyline.clear();
    polylineCoordinates.clear();
    await determinePosition();
    await getPaths();
    _timeStream = Stream<DateTime>.periodic(
        const Duration(seconds: 1), (i) => DateTime.now());
    timeSubscription = _timeStream?.listen((value) {
      time.value = DateFormat.jm().format(DateTime.parse(value.toString()));
    });
    setState(ViewState.idle);
  }

  getPaths() async {
    //directionsModel = await testData();
    directionsModel = await services.getPaths(position: position);
    print(directionsModel?.districtLocations?.length);
    if (directionsModel?.districtLocations != null) {
      await createPolyline();
      await distanceBetweenLocations();
      await drawPolyLineMission();
      await getObjectZero();
      CacheHelper.saveData(
          key: AppConstants.bookingId, value: directionsModel?.status);
      if (directionsModel?.status == 3 || directionsModel?.status == 4) {
        CacheHelper.saveData(key: AppConstants.missionVaValue, value: 3);
      } else {
        CacheHelper.saveData(key: AppConstants.missionVaValue, value: 0);
      }
    }
    missionValue.value =
        CacheHelper.getData(key: AppConstants.missionVaValue) ?? 0;

    bookingId.value = CacheHelper.getData(key: AppConstants.bookingId) ?? 0;

    print(missionValue.value);
  }

  testData() {
    directionsModel = DirectionsModel(
        status: 3,
        routeNumber: 1,
        districtId: 1,
        districtName: "birket",
        districtLocations: [
          DistrictLocations(
            districtId: 1,
            routeNumber: 1,
            description: "s",
            objectId: 1,
            lat: 30.629651,
            long: 31.079462,
          ),
          DistrictLocations(
            districtId: 1,
            routeNumber: 1,
            description: "c",
            objectId: 1,
            lat: 30.629709,
            long: 31.079129,
          ),
          DistrictLocations(
            districtId: 1,
            routeNumber: 1,
            description: "l",
            objectId: 1,
            lat: 30.629787,
            long: 31.078822,
          ),
          DistrictLocations(
            districtId: 1,
            routeNumber: 1,
            description: "c",
            objectId: 1,
            lat: 30.629967,
            long: 31.078968,
          ),
          DistrictLocations(
            districtId: 1,
            routeNumber: 1,
            description: "l",
            objectId: 1,
            lat: 30.630093,
            long: 31.079094,
          ),
          // DistrictLocations(
          //   districtId: 1,
          //   routeNumber: 1,
          //   description: "l",
          //   objectId: 0,
          //   lat: 30.630093,
          //   long: 31.079094,
          // ),
          DistrictLocations(
            districtId: 1,
            routeNumber: 1,
            description: "c",
            objectId: 1,
            lat: 30.630061,
            long: 31.079404,
          ),
          DistrictLocations(
            districtId: 1,
            routeNumber: 1,
            description: "l",
            objectId: 1,
            lat: 30.630029,
            long: 31.079700,
          ),
          DistrictLocations(
            districtId: 1,
            routeNumber: 1,
            description: "e",
            objectId: 1,
            lat: 30.629874,
            long: 31.079663,
          ),
        ]);
    return directionsModel;
  }

  distanceBetweenLocations() {
    userDistance.value = util.distanceBetweenPoints(
          position.latitude,
          position.longitude,
          directionsModel?.districtLocations?.first.lat ?? 0.0,
          directionsModel?.districtLocations?.first.long ?? 0.0,
        ) *
        1000;
    print("userDistance${userDistance.value}");
  }

  checkUserInLocation() {
    if (userDistance.value > 70 || distanceContinue.value > 70) {
      Get.defaultDialog(
          barrierDismissible: false,
          radius: 6,
          title: distanceContinue.value > 70
              ? "اذهب الى نقطه الاستكمال"
              : "اذهب الى بدايه المسار",
          content: SizedBox(
            width: 120,
            child: TextButton(
                onPressed: () {
                  positionStream = Geolocator.getPositionStream(
                          locationSettings: const LocationSettings(
                              accuracy: LocationAccuracy.high))
                  // timeout(Duration(seconds: 10))
                      .listen((event) {
                    if (util.distanceBetweenPoints(
                                event.latitude,
                                event.longitude,
                                directionsModel?.districtLocations?.first.lat ??
                                    0.0,
                                directionsModel
                                        ?.districtLocations?.first.long ??
                                    0.0) *
                            1000 >=
                        70) {
                      CacheHelper.saveData(
                          key: AppConstants.missionVaValue, value: 0);
                      missionValue.value =
                          CacheHelper.getData(key: AppConstants.missionVaValue);
                    } else {
                      CacheHelper.getData(key: AppConstants.missionVaValue) == 3
                          ? {
                              CacheHelper.saveData(
                                  key: AppConstants.missionVaValue, value: 3),
                              missionValue.value = CacheHelper.getData(
                                  key: AppConstants.missionVaValue)
                            }
                          : {
                              CacheHelper.saveData(
                                  key: AppConstants.missionVaValue, value: 1),
                              missionValue.value = CacheHelper.getData(
                                  key: AppConstants.missionVaValue)
                            };
                    }
                    animateTo(event.latitude, event.longitude,
                        bearing: event.heading);
                  });
                  Get.back();
                },
                style: TextButton.styleFrom(
                    backgroundColor: const Color(0xff008d36)),
                child: const Text(
                  "تأكيد",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                )),
          ));
    } else {
      CacheHelper.getData(key: AppConstants.missionVaValue) == 3
          ? {
              CacheHelper.saveData(key: AppConstants.missionVaValue, value: 3),
              missionValue.value =
                  CacheHelper.getData(key: AppConstants.missionVaValue)
            }
          : {
              CacheHelper.saveData(key: AppConstants.missionVaValue, value: 1),
              missionValue.value =
                  CacheHelper.getData(key: AppConstants.missionVaValue)
            };
    }
  }

  drawPolyLineMission() async {
    directionsModel?.districtLocations?.forEach((element) {
      if (element.objectId == 0) {
      } else {
        pathPoint.add(LatLng(element.lat ?? 0.0, element.long ?? 0.0));
        polyline.add(Polyline(
            polylineId: const PolylineId("2"),
            color: Colors.red,
            width: 6,
            points: pathPoint));
      }
    });
    final Uint8List markerStartEnd =
        await util.getBytesFromAsset(Images.startIcon, 80);
    BitmapDescriptor start = BitmapDescriptor.fromBytes(markerStartEnd);
    final Uint8List markerIconEnd =
        await util.getBytesFromAsset(Images.endIcon, 80);
    BitmapDescriptor end = BitmapDescriptor.fromBytes(markerIconEnd);
    markers.add(Marker(
        markerId: const MarkerId("1"),
        icon: start,
        position: LatLng(directionsModel?.districtLocations?.first.lat ?? 0.0,
            directionsModel?.districtLocations?.first.long ?? 0)));
    markers.add(Marker(
        markerId: const MarkerId("1"),
        icon: end,
        position: LatLng(directionsModel?.districtLocations?.last.lat ?? 0.0,
            directionsModel?.districtLocations?.last.long ?? 0)));
  }

  Future<Position?> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    serversEnabledBool.value = serviceEnabled;
    if (!serviceEnabled) {
      showDialog(
          context: Get.context!,
          barrierDismissible: false,
          builder: (context) => const PermissionDialog());

      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showDialog(
            context: Get.context!,
            barrierDismissible: false,
            builder: (context) => const PermissionDialog());

        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      showDialog(
          context: Get.context!,
          barrierDismissible: false,
          builder: (context) => const PermissionDialog());

      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    position = await Geolocator.getCurrentPosition();
    return position;
  }

  startMission() async {
    locationMarker.value = false;
    await startLocationTracking().then((value) {
      timer = Timer.periodic(const Duration(seconds: 2), (timer) {
        if (latitude.value == 0.0 && longitude.value == 0.0) {
        } else {
          getIndexPoint(LatLng(latitude.value, longitude.value));
          infoList.add(InfoModel(
              time: DateTime.now().toString(),
              districtId: directionsModel?.districtId,
              status: statusId.value,
              routeNumber: directionsModel?.routeNumber,
              latitude: latitude.value,
              longitude: longitude.value));
        }
      });
      timer = Timer.periodic(const Duration(seconds: 30), (timer) async {
        // print("length:${infoList.length} ");
        // for (var element in infoList) {
        //   print(element.toJson());
        // }
        // infoList.sort((a, b) => a.time!.compareTo(b.time!));
        await services.addVehicleInfo(data: infoList);
        infoList.clear();
      });
    });
  }

  Future<void> startLocationTracking() async {
    positionStreamSubscription = Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.high,
                distanceFilter: 1
            ))
        // .timeout(Duration(seconds: 10),

        .listen((position) {
      latitude.value = position.latitude;
      longitude.value = position.longitude;
      streamPoint.add(LatLng(position.latitude, position.longitude));
      myMarker(position, position.heading);
      animateTo(position.latitude, position.longitude,
          bearing: position.heading);
      drawPolyLine(points: streamPoint);
      checkLocation(LatLng(position.latitude, position.longitude));
    });
    LocationAccuracy.high;
  }

  checkLocation(LatLng latLng) {
    bool isNearPolyline = util.isLocationOnPath(
      latLng,
      pathPoint,
      tolerance: 70,
    );
    if (isNearPolyline) {
      CacheHelper.saveData(key: AppConstants.missionVaValue, value: 2);
      missionValue.value =
          CacheHelper.getData(key: AppConstants.missionVaValue);
      // print("object");
      statusId.value = 1;
      for (int i = 0; i < directionsModel!.districtLocations!.length; i++) {
        if (directionsModel!.districtLocations![i].description != null) {
          playSound(
              directionsModel!.districtLocations![i].description!,
              latLng,
              directionsModel!.districtLocations![i].lat ?? 0.0,
              directionsModel!.districtLocations![i].long ?? 0.0);
        }
      }
    } else {
      statusId.value = 4;
    }
  }

  getObjectZero() {
    directionsModel?.districtLocations?.forEach((element) {
      if (element.objectId == 0) {
        latitudeContinue.value = element.lat!;
        longitudeContinue.value = element.long!;
        // print(element.lat);
        // print(element.long);
        // print(element.objectId);
        // print(element.description);
        distanceContinue.value = util.distanceBetweenPoints(
                position.latitude,
                position.longitude,
                latitudeContinue.value,
                longitudeContinue.value) *
            1000;
        print("distance:${distanceContinue.value} ");
        markersContinue.add(Marker(
            markerId: MarkerId(
              "${element.objectId}",
            ),
            onTap: () async {
              await openMap(
                  latLng:
                      LatLng(latitudeContinue.value, longitudeContinue.value));
            },
            infoWindow: const InfoWindow(
              title: ' نقطه الاستكمال',
            ),
            position: LatLng(latitudeContinue.value, longitudeContinue.value)));
        // print("true");
      }
    });
  }

  getIndexPoint(LatLng latLng) async {
    LatLng? closestPoint = await util.getClosestPoint(latLng, pathPoint);
    // print('Closest point: $closestPoint');
    if (closestPoint != null) {
      int? index = pathPoint.indexWhere((element) => element == closestPoint);
      // print('Index: $index');
      await services.sendPoints(
          districtId: directionsModel?.districtId,
          routeNumber: directionsModel?.routeNumber,
          objectId: directionsModel?.districtLocations![index].objectId);
    }
  }

  playSound(String char, LatLng event, double lat, double long) async {
    switch (char) {
      case "s":
        if (Geolocator.distanceBetween(
                event.latitude, event.longitude, lat, long) <=
            20) {
          soundHelper.playerAudioStart();
          break;
        }
        break;
      case "r":
        final Uint8List markerIconEnd =
            await util.getBytesFromAsset(Images.turnRight, 80);
        BitmapDescriptor navigate = BitmapDescriptor.fromBytes(markerIconEnd);
        if (Geolocator.distanceBetween(
                event.latitude, event.longitude, lat, long) <=
            20) {
          markers.add(
            Marker(
                markerId: MarkerId("$lat"),
                position: LatLng(lat, long),
                icon: navigate),
          );
          soundHelper.playerAudioReturnRight();
          break;
        } else {
          markers.removeWhere((element) => element.markerId.value == "$lat");
        }
        break;
      case "l":
        final Uint8List markerIconEnd =
            await util.getBytesFromAsset(Images.left, 80);
        BitmapDescriptor navigate = BitmapDescriptor.fromBytes(markerIconEnd);
        if (Geolocator.distanceBetween(
                event.latitude, event.longitude, lat, long) <=
            20) {
          markers.add(
            Marker(
                markerId: MarkerId("$lat"),
                position: LatLng(lat, long),
                icon: navigate),
          );
          soundHelper.playerAudioReturnLeft();
          break;
        } else {
          markers.removeWhere((element) => element.markerId.value == "$lat");
        }
        break;
      case "u":
        final Uint8List markerIconEnd =
            await util.getBytesFromAsset(Images.returnImage, 80);
        BitmapDescriptor navigate = BitmapDescriptor.fromBytes(markerIconEnd);
        if (Geolocator.distanceBetween(
                event.latitude, event.longitude, lat, long) <=
            20) {
          markers.add(
            Marker(
                markerId: MarkerId("$lat"),
                position: LatLng(lat, long),
                icon: navigate),
          );
          soundHelper.playerAudioUTurn();
          break;
        } else {
          markers.removeWhere((element) => element.markerId.value == "$lat");
        }
        break;
      case "ub":
        final Uint8List markerIconEnd =
            await util.getBytesFromAsset(Images.turnBack, 80);
        BitmapDescriptor navigate = BitmapDescriptor.fromBytes(markerIconEnd);
        if (Geolocator.distanceBetween(
                event.latitude, event.longitude, lat, long) <=
            20) {
          markers.add(
            Marker(
                markerId: MarkerId("$lat"),
                position: LatLng(lat, long),
                icon: navigate),
          );
          soundHelper.playerAudioTurnBack();
          break;
        } else {
          markers.removeWhere((element) => element.markerId.value == "$lat");
        }
        break;
      case "c":
        final Uint8List markerIconEnd =
            await util.getBytesFromAsset(Images.goStraight, 80);
        BitmapDescriptor navigate = BitmapDescriptor.fromBytes(markerIconEnd);
        if (Geolocator.distanceBetween(
                event.latitude, event.longitude, lat, long) <=
            20) {
          markers.add(
            Marker(
                markerId: MarkerId("$lat"),
                position: LatLng(lat, long),
                icon: navigate),
          );
          soundHelper.playerAudioStraight();
          break;
        } else {
          markers.removeWhere((element) => element.markerId.value == "$lat");
        }
        break;
      case "ss":
        // final Uint8List markerIconEnd =
        //     await util.getBytesFromAsset(Images.goStraight, 80);
        // BitmapDescriptor navigate = BitmapDescriptor.fromBytes(markerIconEnd);
        if (Geolocator.distanceBetween(
                event.latitude, event.longitude, lat, long) <=
            20) {
          // markers.add(
          //   Marker(
          //       markerId: MarkerId("$lat"),
          //       position: LatLng(lat, long),
          //       icon: navigate),
          // );
          soundHelper.playerNewStart();
          break;
        } else {
          // markers.removeWhere((element) => element.markerId.value == "$lat");
        }
        break;
      case "rr":
        final Uint8List markerIconEnd =
            await util.getBytesFromAsset(Images.turnRight, 80);
        BitmapDescriptor navigate = BitmapDescriptor.fromBytes(markerIconEnd);
        if (Geolocator.distanceBetween(
                event.latitude, event.longitude, lat, long) <=
            20) {
          markers.add(
            Marker(
                markerId: MarkerId("$lat"),
                position: LatLng(lat, long),
                icon: navigate),
          );
          soundHelper.playerAudioReturnRight();
          break;
        } else {
          markers.removeWhere((element) => element.markerId.value == "$lat");
        }
        break;
      case "ll":
        final Uint8List markerIconEnd =
            await util.getBytesFromAsset(Images.left, 80);
        BitmapDescriptor navigate = BitmapDescriptor.fromBytes(markerIconEnd);
        if (Geolocator.distanceBetween(
                event.latitude, event.longitude, lat, long) <=
            20) {
          markers.add(
            Marker(
                markerId: MarkerId("$lat"),
                position: LatLng(lat, long),
                icon: navigate),
          );
          soundHelper.playerAudioReturnLeft();
          break;
        } else {
          markers.removeWhere((element) => element.markerId.value == "$lat");
        }
        break;
      case "rl":
        final Uint8List markerIconEnd =
            await util.getBytesFromAsset(Images.leftAndRight, 80);
        BitmapDescriptor navigate = BitmapDescriptor.fromBytes(markerIconEnd);
        if (Geolocator.distanceBetween(
                event.latitude, event.longitude, lat, long) <=
            20) {
          markers.add(
            Marker(
                markerId: MarkerId("$lat"),
                position: LatLng(lat, long),
                icon: navigate),
          );
          soundHelper.playerAudioReturnLeft();
          break;
        } else {
          markers.removeWhere((element) => element.markerId.value == "$lat");
        }
        break;
      case "lr":
        final Uint8List markerIconEnd =
            await util.getBytesFromAsset(Images.leftAndRight, 80);
        BitmapDescriptor navigate = BitmapDescriptor.fromBytes(markerIconEnd);
        if (Geolocator.distanceBetween(
                event.latitude, event.longitude, lat, long) <=
            20) {
          markers.add(
            Marker(
                markerId: MarkerId("$lat"),
                position: LatLng(lat, long),
                icon: navigate),
          );
          soundHelper.playerAudioReturnRight();
          break;
        } else {
          markers.removeWhere((element) => element.markerId.value == "$lat");
        }
        break;
      case "e":
        if (Geolocator.distanceBetween(
                event.latitude, event.longitude, lat, long) <=
            20) {
          print(Geolocator.distanceBetween(
              event.latitude, event.longitude, lat, long));
          soundHelper.playerAudioFinish();
          CacheHelper.saveData(key: AppConstants.missionVaValue, value: 4);
          missionValue.value =
              CacheHelper.getData(key: AppConstants.missionVaValue);
          break;
        } else {
          // CacheHelper.saveData(key: AppConstants.missionVaValue, value: 0);
          // // SharedPref.setSelectedMissionValue(0);
          // missionValue.value =
          //     CacheHelper.getData(key: AppConstants.missionVaValue);
        }
        break;
    }
  }

  stopMission() async {
    await services.stopMission();
  }

  pauseMission() async {
    await services.continueMission();
  }

  endMission() async {
    await services.end();
  }

  bookMission() async {
    try {
      bookValue.value = true;
      await services.bookPath(
          routeNumber: directionsModel?.routeNumber,
          districtId: directionsModel?.districtId,
          lat: directionsModel?.districtLocations?.first.lat,
          long: directionsModel?.districtLocations?.first.long);
      bookValue.value = false;
      CacheHelper.saveData(key: AppConstants.bookingId, value: 1);
      bookingId.value = CacheHelper.getData(key: AppConstants.bookingId);
    } catch (e) {
      bookValue.value = false;
    }
  }

  Future<void> animateTo(double latitude, double longitude,
      {double? bearing}) async {
    final googleMapController = await completer.future;
    googleMapController
        .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(
              latitude,
              longitude,
            ),
            bearing: bearing ?? 90,
            zoom: 18,
            tilt: 30)));
  }

  drawPolyLine({List<LatLng>? points}) {
    polyline.add(Polyline(
        polylineId: const PolylineId("1"),
        width: 4,
        color: Colors.green,
        points: points ?? []));
  }

  myMarker(Position event, double rotate) async {
    final Uint8List markerIconEnd =
        await util.getBytesFromAsset(Images.track, 50);
    BitmapDescriptor end = BitmapDescriptor.fromBytes(markerIconEnd);
    currentLocationMarker.value = Marker(
      markerId: MarkerId("$event"),
      rotation: rotate,
      flat: true,
      anchor: const Offset(0.5, 0.5),
      position: LatLng(event.latitude, event.longitude),
      infoWindow: const InfoWindow(
        title: "موقعك الحالى",
        snippet: "موقعك الحالى",
      ),
      icon: end,
    );
  }

  functionButton() async {
    switch (missionValue.value) {
      case 1:
        CacheHelper.saveData(key: AppConstants.tapped, value: true);
        CacheHelper.saveData(key: AppConstants.missionVaValue, value: 2);
        missionValue.value =
            CacheHelper.getData(key: AppConstants.missionVaValue);
        positionStream?.cancel();
        services.startMission(
            lat: "${directionsModel!.districtLocations!.first.lat}",
            long: "${directionsModel!.districtLocations!.first.long}");
        startMission();
        break;
      case 2:
        Get.defaultDialog(
            radius: 6,
            title: "ايقاف مؤقت",
            titleStyle: const TextStyle(color: Colors.red, fontSize: 18),
            content: const Text(""),
            confirm: SizedBox(
              width: 120,
              child: TextButton(
                  onPressed: () async {
                    timeSubscription?.cancel();
                    timer?.cancel();
                    positionStream?.cancel();
                    positionStreamSubscription?.cancel();
                    await stopMission();
                    CacheHelper.saveData(
                        key: AppConstants.missionVaValue, value: 3);
                    missionValue.value =
                        CacheHelper.getData(key: AppConstants.missionVaValue);
                    soundHelper.player.dispose();
                    completer = Completer();
                    latitude.value = 0.0;
                    longitude.value = 0.0;
                    Get.offAll(() => const HomeScreen());
                  },
                  style: TextButton.styleFrom(
                      backgroundColor: const Color(0xff008d36)),
                  child: const Text(
                    "تأكيد",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  )),
            ));
        break;
      case 3:
        CacheHelper.saveData(key: AppConstants.missionVaValue, value: 2);
        missionValue.value =
            CacheHelper.getData(key: AppConstants.missionVaValue);
        pauseMission();
        startMission();
        positionStream?.cancel();
        break;
      case 4:
        // positionStream?.cancel();
        // positionStreamSubscription?.cancel();
        // timer?.cancel();
        // completer = Completer();
        // soundHelper.player.dispose();
        // CacheHelper.saveData(key: AppConstants.bookingId, value: 0);
        // bookingId.value = CacheHelper.getData(key: AppConstants.bookingId);
        Get.defaultDialog(
            radius: 6,
            title: 'انهاء المهمه'.tr,
            titleStyle: const TextStyle(color: Colors.red, fontSize: 18),
            content: const Text(""),
            confirm: SizedBox(
              width: 120,
              child: TextButton(
                  onPressed: () async {
                    timeSubscription?.cancel();
                    CacheHelper.saveData(
                        key: AppConstants.tapped, value: false);
                    soundHelper.player.dispose();
                    completer = Completer();
                    timer?.cancel();
                    positionStream?.cancel();
                    positionStreamSubscription?.cancel();
                    endMission();
                    CacheHelper.saveData(
                        key: AppConstants.missionVaValue, value: 0);
                    CacheHelper.saveData(key: AppConstants.bookingId, value: 0);
                    await services.completeTask(
                        districtId: directionsModel!.districtId!,
                        routeId: directionsModel!.routeNumber!);
                    latitude.value = 0.0;
                    longitude.value = 0.0;
                    Get.offAll(() => const HomeScreen());
                  },
                  style: TextButton.styleFrom(
                      backgroundColor: const Color(0xff008d36)),
                  child: const Text(
                    "انهاء",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  )),
            ));
    }
  }

  createPolyline() async {
    //
    polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      AppConstants.apiKey,
      PointLatLng(position.latitude, position.longitude),
      PointLatLng(directionsModel!.districtLocations!.first.lat!,
          directionsModel!.districtLocations!.first.long!),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }
    polyline.add(Polyline(
      polylineId: const PolylineId('2'),
      color: Colors.amber,
      points: polylineCoordinates,
      width: 4,
    ));
  }

  openMap({LatLng? latLng}) async {
    final availableMaps = await MapLauncher.installedMaps;
    for (var map in availableMaps) {
      map.showDirections(
        origin: Coords(position.latitude, position.longitude),
        directionsMode: DirectionsMode.driving,
        destination: Coords(latLng?.latitude ?? 0.0, latLng?.longitude ?? 0.0),
        // waypoints: waypoints
      );
    }
  }

  Future<void> myFunction() async {
    CacheHelper.getData(key: AppConstants.tapped) == false
        ? {
            timeSubscription?.cancel(),
            timer != null ? timer?.cancel() : {},
            positionStream?.cancel(),
            positionStreamSubscription?.cancel(),
            latitude.value = 0.0,
            longitude.value = 0.0,
          }
        : {
            timeSubscription?.cancel(),
            timer != null ? timer?.cancel() : {},
            positionStream?.cancel(),
            positionStreamSubscription?.cancel(),
            await stopMission(),
            CacheHelper.saveData(key: AppConstants.missionVaValue, value: 3),
            soundHelper.player.dispose(),
            completer = Completer(),
            latitude.value = 0.0,
            longitude.value = 0.0,
            // Do something here
          };
  }
}
// Future<List<DirectionsResponse>> getDirections(List<LatLng> points) async {
//   List<DirectionsResponse> responses = [];
//
//   for (int i = 0; i < points.length - 1; i++) {
//     final response = await _places.directionsWithLocation(
//       Location(points[i].latitude, points[i].longitude),
//       Location(points[i + 1].latitude, points[i + 1].longitude),
//       travelMode: TravelMode.driving,
//     );
//     responses.add(response);
//   }
//
//   return responses;
// }
