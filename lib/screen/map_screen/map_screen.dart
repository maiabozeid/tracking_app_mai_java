import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tracking_app/component/custom_button.dart';
import 'package:tracking_app/controller/map_controller.dart';
import 'package:tracking_app/enum/view_state.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MapController>(builder: (controller) {
      return SafeArea(
        child: Scaffold(
            body: Obx(
          () => controller.state == ViewState.busy
              ? const Center(
                  child: SpinKitFadingCube(
                    color: Color(0xff008d36),
                    size: 50.0,
                  ),
                )
              : Stack(
                  children: [
                    GoogleMap(
                      myLocationEnabled: controller.locationMarker.value,
                      mapType: MapType.normal,
                      initialCameraPosition: CameraPosition(
                          zoom: 16,
                          target: LatLng(controller.position.latitude,
                              controller.position.longitude)),
                      polylines: Set<Polyline>.of(controller.polyline),
                      markers: <Marker>{
                        ...controller.markers,
                        controller.currentLocationMarker.value
                      },
                      onMapCreated: (map) async {
                        controller.completer.complete(map);
                        await controller.checkUserInLocation();
                      },
                    ),
                    Positioned(
                        bottom: 20,
                        right: 20,
                        left: 20,
                        child: Obx(
                          () => controller.missionValue.value == 0
                              ? const SizedBox()
                              : CustomButton(
                                  color: controller.missionValue.value == 1
                                      ? const Color(0xff008d36).withOpacity(0.9)
                                      : controller.missionValue.value == 2
                                          ? Colors.red
                                          : controller.missionValue.value == 3
                                              ? Colors.amber
                                              : controller.missionValue.value ==
                                                      4
                                                  ? Colors.red
                                                  : Colors.transparent,
                                  buttonText: controller.missionValue.value == 1
                                      ? "ابداء المهمه"
                                      : controller.missionValue.value == 2
                                          ? "ايقاف مؤقت"
                                          : controller.missionValue.value == 3
                                              ? "استكمال المسار"
                                              : controller.missionValue.value ==
                                                      4
                                                  ? "انهاء المهمه"
                                                  : "",
                                  onPressed: () {
                                    controller.functionButton();
                                  },
                                ),
                        ))
                  ],
                ),
        )),
      );
    });
  }
}
