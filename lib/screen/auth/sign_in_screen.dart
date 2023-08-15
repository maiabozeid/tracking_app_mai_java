import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tracking_app/component/custom_button.dart';
import 'package:tracking_app/component/fixed_text_field.dart';
import 'package:tracking_app/helper/cache_helper.dart';
import 'package:tracking_app/screen/auth/controller/signin_controller.dart';
import 'package:tracking_app/util/app_constants.dart';
import 'package:tracking_app/util/dimensions.dart';
import 'package:tracking_app/util/images.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({Key? key}) : super(key: key);

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
    final controller = Get.put(SignInController());
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FEFE),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(Images.logo, width: Dimensions.width * 0.4),
                SizedBox(
                  height: Dimensions.height * 0.02,
                ),
                const Text(
                  " وزارة الشؤون البلدية والقروية   ",
                  style: TextStyle(
                    color: Color(0xff005133),
                    fontSize: 20,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  "أمانة منطقة الرياض ",
                  style: TextStyle(
                    color: Color(0xff005133),
                    fontSize: 20,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: Dimensions.height * 0.04,
                ),
                Obx(() => FixedTextField(
                      errorLabel: controller.email.error,
                      function: (email) {
                        controller.changeUserName(email);
                      },
                      prefixIcon:
                          const Icon(Icons.email, color: Color(0xff008d36)),
                      label: "البريد الالكترونى".tr,
                    )),
                SizedBox(
                  height: Dimensions.height * 0.02,
                ),
                Obx(() => FixedTextField(
                      errorLabel: controller.password.error,
                      obSecure: controller.isSecure.value,
                      function: (password) {
                        controller.changePassword(password);
                      },
                      suffixIcon: IconButton(
                          onPressed: () {
                            controller.isSecure.value =
                                !controller.isSecure.value;
                          },
                          icon: Icon(
                              controller.isSecure.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: const Color(0xff008d36))),
                      prefixIcon:
                          const Icon(Icons.lock, color: Color(0xff008d36)),
                      label: "الرقم السرى".tr,
                    )),
                SizedBox(
                  height: Dimensions.height * 0.04,
                ),
                Obx(() => controller.loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xff008d36),
                        ),
                      )
                    : CustomButton(
                        color: const Color(0xff008d36).withOpacity(0.99),
                        onPressed: () {
                          controller.signIn();
                          // FirebaseCrashlytics.instance.log("Higgs-Boson detected! Bailing out");
                          // String? userIdentifier = CacheHelper.getData(key: AppConstants.token);
                          // if (userIdentifier != null) {
                          //   FirebaseCrashlytics.instance.setUserIdentifier(userIdentifier);
                          // } else {
                          //   // Handle the case when userIdentifier is null
                          //   // For example, you could use a default user identifier or log a message
                          // }
                        },
                        width: Dimensions.width * 0.8,
                        radius: Dimensions.RADIUS_DEFAULT,
                        buttonText: "تسجيل الدخول".tr,
                      ),

                ),
                 SizedBox(
                   height: Dimensions.height * 0.04,
                 ),


                 Padding(
                   padding: const EdgeInsets.symmetric(
                     horizontal: 10,),
                   child: Container(

                     width: Dimensions.width * 0.4,
                     height: Dimensions.height * 0.04,
                     decoration: BoxDecoration(
                         color: Color(0xff008d36),
                       borderRadius: BorderRadius.circular(10)),

                     child: Row(

                       mainAxisAlignment: MainAxisAlignment.center,
                       children: [
                         const Text(
                          AppConstants.appVersion,
                          style: TextStyle( color:Colors.white,
                         backgroundColor: Color(0xff008d36),
                         fontSize: 17,
                         fontFamily: 'Montserrat',
                         fontWeight: FontWeight.w500,

                ),),
                         SizedBox(width: 10,)
                       ],
                     ),
                   ),
                 ),

              ],
            ),
          ),
        ),

      ),
    );
  }
}
