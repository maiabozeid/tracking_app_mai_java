import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:tracking_app/component/custom_button.dart';
import 'package:tracking_app/util/dimensions.dart';
import 'package:tracking_app/util/styles.dart';

class PermissionDialog extends StatelessWidget {
  const PermissionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.PADDING_SIZE_LARGE),
        child: SizedBox(
          width: 300,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.add_location_alt_rounded,
                color: Color(0xff008d36), size: 100),
            const SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
            Text(
              "لقد رفضت إذن الموقع إلى الأبد. يجب عليك السماح بإذن الموقع لإضافة عنوان جديد.",
              textAlign: TextAlign.justify,
              style: robotoMedium.copyWith(
                fontSize: Dimensions.fontSizeLarge,
              ),
            ),
            const SizedBox(height: Dimensions.PADDING_SIZE_LARGE),
            Row(children: [
              Expanded(
                child: TextButton(
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(
                            width: 2, color: Color(0xff008d36))),
                    minimumSize: Size(1, 50),
                  ),
                  child: Text("لا", style: TextStyle(color: Color(0xff008d36))),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: Dimensions.PADDING_SIZE_SMALL),
              Expanded(
                  child: CustomButton(
                      color: Color(0xff008d36),
                      buttonText: "نعم",
                      onPressed: () async {
                        await Geolocator.openAppSettings();

                        Get.back();
                      })),
            ]),
          ]),
        ),
      ),
    );
  }
}
